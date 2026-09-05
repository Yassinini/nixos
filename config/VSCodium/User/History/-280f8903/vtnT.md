# Use OpenCV object detection to answer
## To what extent does air resistance cause deviation between the theoretical and measured trajectory of a projectile?

<br>
<br>

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