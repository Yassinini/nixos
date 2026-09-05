## Use OpenCV object detection to answer:
- To what extent does air resistance cause deviation between the theoretical and measured trajectory of a projectile?

## Materials
- Ping Pong ball
- Launcher at a repeatable angle

## Theoritical model
- Track pixels and frame to time and measure the speed of the ball
- Use custom model to understand trajectory using kinematics equations (EXTRA add air resistance/drag term for model comparison)
- Overlay trajectory vs theoritical curve (graph) to understand the difference 

## Computing
- Python
- OpenCV
- Matplotlib
- Scipy

## Uncertainty Analysis
- Pixel-to-meter conversion uncertainty
- Frame rate --> time uncertainty

## Solution to Uncertainty
- Repeat all conditions 5+ times for mean +- standard deviation
- 