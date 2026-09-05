> ILL BE WORKING ON A FULL REPORT ON THIS LIKE A SCIENTIFIC PAPER STYLE THING CUZ I THINK IT'D BE VERY FUN SO AWAIT THAT (!!)
# Projectile physics

## Use OpenCV object detection to answer

>To what extent does air resistance cause deviation between the theoretical and measured trajectory of a projectile?

---

## Theoritical model
- Track pixels and frame to time and measure the speed of the ball

- Use custom model to understand trajectory using kinematics equations (EXTRA add air resistance/drag term for model comparison)

- Overlay trajectory vs theoritical curve (graph) to understand the difference 

## Materials
- Ping Pong ball
- Launcher at a repeatable angle
- Computing programs + computer vision 

## Computing
- OpenCV (detection, frame handling)
- numpy (data handling, calculations)
- matplotlib (plotting, visual comparison)
- scipy (curve fitting for theoretical model)

## Uncertainty Analysis
- Pixel-to-meter conversion uncertainty
- Frame rate --> time uncertainty
- Pixel uncertainty to motion blur: include error +- 2 pixels

## Solution to Uncertainty
- Repeat all conditions 5+ times for mean +- standard deviation
- Compare measured spread against theoritical spread using error equations

---

# Checklist

### Code part
- [x] Thresholder
- [x] Tracking object
- [x] Frame counter & Timer
- [x] Store (time, x, y) data to CSV
- [x] Plot the trajectory of ball ONCE
- [x] Plot the trajectory of ball x4 
- [x] Plot trajectory with air resistance on graph with matplotlib
- [x] Plot trajectory with vs without air resistance on graph with matplotlib

### Footage part
- [x] Set up environment for shooting
- [x] Make launcher
- [x] Test thresholder + ball + background
- [x] Final test before theory

### Theoretical part
- [x] Derive kinematics equations for ideal trajectory
- [x] Add air resistance/drag term to model
- [x] Fit theoretical curve to real data (scipy)
- [x] Compare measured vs theoretical (residuals/R^2)

### Uncertainty part
- [x] Pixel-to-meter conversion uncertainty
- [x] Frame rate to time uncertainty
- [x] Repeat trials for mean +/- standard deviation

### FINAL
- [x] Report paper


# IMPORTANT NOTE!!

## Inaccuracy
> - any inaccurate work is due to the lens distortion in the videos that were shot for testing, the methods aren't 100% foolproof but i did what i got to do
> - The physics file contains weird values like g constant (9.81m/s) being 16 m/s which is totally wrong and funny but this is mostly camera distortion limitation and i'll stop here for this project because i think the work done on earlier files, the handwritten code, is good enough for my goals

## KEEP IN MIND
> All code written here is handwritten code EXCEPT  the physics file, the physics file was mostly AI assisted code. 

