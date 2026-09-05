import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

g = 9.81
scale = 0.001451  # m/px

# ------------------------------
# EQUATION FUNCTIONS
# ------------------------------

def xt(xi, vix, t):
    return xi + vix * t

def yt(yi, viy, t, g):
    return yi + viy * t - 0.5 * g * (t**2)

def vxt(vix):
    return vix

def vyt(viy, t, g):
    return viy - g * t

def speed(vx, vy):
    return np.sqrt(vx**2 + vy**2)

def peak_height_ideal(yi, viy, g):
    return yi + (viy**2) / (2*g)

def flight_time_ideal(yi, viy, g):
    # solves y(t) = 0 for t, positive root
    return (viy + np.sqrt(viy**2 + 2*g*yi)) / g

def deviation(y_actual, y_ideal):
    return y_actual - y_ideal


# ------------------------------
# LOAD DATA
# ------------------------------

d = pd.read_csv("first_bounce_clean.csv")

# convert pixels to meters if not already done
d['xm'] = d['cx'] * scale
d['ym'] = d['cy'] * scale

# NOTE: cy in pixels usually increases downward (image coordinates),
# so you likely need to flip it so height increases upward:
d['ym'] = -(d['ym'] - d['ym'].max())


# ------------------------------
# FIT REAL DATA -> GET INITIAL CONDITIONS
# ------------------------------

coeffs_y = np.polyfit(d['time'], d['ym'], 2)
a, viy, yi = coeffs_y

coeffs_x = np.polyfit(d['time'], d['xm'], 1)
vix, xi = coeffs_x

g_fit = -2 * a
print(f"g from fit: {g_fit:.3f} (expect close to 9.81)")
print(f"v0y: {viy:.3f} m/s, v0x: {vix:.3f} m/s")
print(f"y0: {yi:.3f} m, x0: {xi:.3f} m")


# ------------------------------
# GENERATE IDEAL (NO DRAG) CURVE
# ------------------------------

t = d['time']
y_ideal = yt(yi, viy, t, g)
x_ideal = xt(xi, vix, t)


# ------------------------------
# COMPARISON METRICS
# ------------------------------

y_max_actual = d['ym'].max()
y_max_ideal = peak_height_ideal(yi, viy, g)

t_flight_ideal = flight_time_ideal(yi, viy, g)
t_flight_actual = d['time'].max()

dev = deviation(d['ym'], y_ideal)

print(f"\nPeak height - actual: {y_max_actual:.3f} m | ideal: {y_max_ideal:.3f} m")
print(f"Flight time - actual: {t_flight_actual:.3f} s | ideal: {t_flight_ideal:.3f} s")
print(f"Max deviation: {dev.abs().max():.4f} m")


# ------------------------------
# GRAPHS
# ------------------------------

# height vs time: actual vs ideal
plt.figure(figsize=(10, 5))
plt.plot(d['time'], d['ym'], color='black', linewidth=2, label='actual (with air resistance)')
plt.plot(t, y_ideal, color='red', linewidth=2, linestyle='--', label='ideal (no air resistance)')
plt.axhline(0, color='gray', linestyle=':', alpha=0.5)
plt.xlabel('Time (s)')
plt.ylabel('Height (m)')
plt.title('Height vs Time: Actual vs Ideal')
plt.legend()
plt.grid()
plt.show()

# deviation vs time
plt.figure(figsize=(10, 5))
plt.plot(d['time'], dev, color='purple', linewidth=2)
plt.axhline(0, color='gray', linestyle=':', alpha=0.5)
plt.xlabel('Time (s)')
plt.ylabel('Deviation (m) [actual - ideal]')
plt.title('Deviation Between Actual and Ideal Trajectory')
plt.grid()
plt.show()

# trajectory shape: actual vs ideal
plt.figure(figsize=(10, 5))
plt.plot(d['xm'], d['ym'], color='black', linewidth=2, label='actual')
plt.plot(x_ideal, y_ideal, color='red', linewidth=2, linestyle='--', label='ideal')
plt.xlabel('X position (m)')
plt.ylabel('Height (m)')
plt.title('Trajectory Shape: Actual vs Ideal')
plt.legend()
plt.grid()
plt.show()

print(d.head())
print(d['time'].min(), d['time'].max())
plt.plot(d['time'], d['ym'])
plt.show()