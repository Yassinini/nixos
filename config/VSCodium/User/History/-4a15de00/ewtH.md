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

## Checklist

### Code part
- [x] Thresholder
- [x] Tracking object
- [x] Frame counter & Timer
- [ ] Store (time, x, y) data to CSV
- [ ] Plot the trajectory of ball
- [ ] Plot trajectory with vs without air resistance on graph with matplotlib

### Footage part
- [ ] Set up environment for shooting
- [ ] Make launcher
- [ ] Test thresholder + ball + background
- [ ] Final test before theory

### Theoretical part
- [ ] Derive kinematics equations for ideal trajectory
- [ ] Add air resistance/drag term to model
- [ ] Fit theoretical curve to real data (scipy)
- [ ] Compare measured vs theoretical (residuals/R^2)

### Uncertainty part
- [ ] Pixel-to-meter conversion uncertainty
- [ ] Frame rate to time uncertainty
- [ ] Repeat trials for mean +/- standard deviation
- [ ] Propagate uncertainty into position/velocity