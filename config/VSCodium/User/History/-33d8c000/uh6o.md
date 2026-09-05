## Abbreviations & Symbols

| Term  | Meaning                                |     |
| ----- | -------------------------------------- | --- |
| RQ    | Research Question                      |     |
| FWOIF | Frames With Object In Frame            |     |
| AVG   | Averaged trajectory dataset            |     |
| FPS   | Frames per second                      |     |
| h(t)  | Height as a function of time           |     |
| e     | Coefficient of restitution             |     |
| g     | Gravitational acceleration (9.81 m/s²) |     |
| v₀    | Initial velocity                       |     |
|       |                                        |     |

## To what extent does air resistance cause deviation between the theoretical and measured trajectory of a projectile?

To measure this we must go through a process of real world data collection, data processing and physics translations.

## Data Collection

For data collection, over 10 minutes of ping pong ball footage was taken, the ping pong ball was set up to fall from a fixed angle to generate a bounce that lost its energy over time.

After initialising the set up to drop the ball from a repeatable angle, the camera (in this case a mobile phone) is set up to take video of the ball.

- The ball falls ~100 cm to the floor, bounces back up and with a horizontal movement.

- The phone is set up in wide angle mode facing the set up fall of the ball.
---
## Data processing
The python program >main.py< utilises the OpenCV and NumPy libraries of python for collecting the videos and processing them.

### Video
- OpenCV recieves the video which it encodes as images. Runs through every image to process them
- The image is turned to greyscale for easier processing every frame, then a masking threshold is made 
>grey = cv.cvtColor(smol, cv.COLOR_BGR2GRAY)
_, mask = cv.threshold(grey, 180, 255, cv.THRESH_BINARY)
mask = cv.erode(mask, kernel, iterations=5)
mask = cv.dilate(mask, kernel, iterations=5)

- This makes the entire frame black with only the ball being white![[Pasted image 20260822021820.png|466]]

### Frames
- The program uses math and numpy to calculate the number of frames in the video, the number of frames per second is extracted and then reused to get the total duration in seconds.
- FORMAT:
> total frames: 47
fps: 59.72069092245498
time: 0.7869969230769231 
number of FWOIF: 20 (frames with object inframe)
number of unused frames: 27

- The program also tracks the ball as long as it exits in frame AND IS DETECTED, keeping it in the csv format for further data work
--> This isolates the ball's motion for further analysis
![[/projectileCV/attachs/frame.png]]

## Data work
1 - The data is filtered and normalised, keeping the base of all graphs at h=0 
![[/projectileCV/attachs/ALL_Bounces.jpeg]]

-- the graph shows 4 ball dropping trajectories which fit the **parabolic motion under constant gravitational acceleration** topic in physics

- Height under gravity:
$$h(t) = v_0 t - \frac{1}{2}g t^2$$

- Coefficient of restitution (bounce-to-bounce energy loss)
$$e = \sqrt{\frac{h_{n+1}}{h_n}}$$

## Averaging the graphs
- The next step is to find a graph that unifies all the past graphs into another graph AND its dataset, calling them the AVG
![[projectileCV/attachs/AVG_Bounce.png]]
--> The graph above represents the AVG graphing compared to the rest of the datasets graphed.

## Working with one
To work with the data we found, we must separate a parabola of the first bounce to use that for comparison
![[projectileCV/attachs/bolabounce.png]]

## More physics stuff (explained by AI cuz i didn't do it by hand)
## (the drag model)

### Why the ideal model isn't enough

The equation used earlier — `h(t) = v_0 t - (1/2)g t^2` — assumes the ball moves through a vacuum. In reality, air exerts a **drag force** on the ball opposing its motion, which grows with the square of velocity. This means the equations of motion can no longer be solved with simple algebra — they need **differential equations**, and in this case, a **numerical solution** rather than a clean analytical formula.

### Forces acting on the ball

Two forces act on the ping pong ball mid-flight:

$$F_{gravity} = -mg$$

$$F_{drag} = -\frac{1}{2} \rho C_d A v^2 \cdot \text{sign}(v)$$

Where:

| Symbol | Meaning |
|--------|---------|
| $\rho$ | Air density (≈1.225 kg/m³ at sea level) |
| $C_d$ | Drag coefficient (dimensionless, depends on shape) |
| $A$ | Cross-sectional area of the ball |
| $v$ | Instantaneous velocity |
| $m$ | Mass of the ball |

The `sign(v)` term matters because drag always opposes the *direction* of motion — it decelerates the ball whether it's moving up or down.

### Equation of motion

Combining both forces using Newton's second law ($F = ma$), the vertical motion becomes:

$$m\frac{dv}{dt} = -mg - \frac{1}{2}\rho C_d A v^2 \cdot \text{sign}(v)$$

This is a **nonlinear ODE** — unlike the no-drag case, it can't be integrated directly into a neat $h(t)$ formula. Instead, it needs to be solved **numerically**, stepping forward in tiny time increments.

### Numerical integration method

The model steps through time in small increments $\Delta t$, updating velocity and height at each step:

```python
v_new = v + a * dt
h_new = h + v * dt
```

where `a` is calculated from the net force (gravity + drag) at each timestep. This is essentially **Euler's method** (or a more refined version like Runge-Kutta, if the code uses `scipy.integrate.solve_ivp`) — repeatedly asking "given where the ball is and how fast it's moving right now, where will it be a tiny moment later?"

### Fitting the model to real data

`scipy.optimize.curve_fit` (or `solve_ivp` + a custom loss function) is used to find the value of $C_d$ that makes the simulated drag trajectory best match the measured trajectory — since $C_d$ isn't known precisely for a ping pong ball in this exact setup, it's treated as a **free parameter** and fitted rather than assumed.

### Comparing models

Once fitted, three curves can sit on the same graph:
1. **Measured trajectory** (from OpenCV tracking)
2. **Ideal model** (no drag, pure kinematics)
3. **Drag model** (fitted $C_d$, numerically solved)

The "extent" of air resistance's effect is then measured by how much closer the drag model tracks the real data compared to the ideal model — quantified using **residuals** (the gap between model and data at each point) or **R²** (how much of the variance in the real data is explained by each model).