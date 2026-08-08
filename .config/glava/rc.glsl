/* Module configuration - sets GLAVA to rendering in a circle */
#request mod circle

/* Window behavior and appearance */
#request setfloating   true
#request setdecorated  false
#request setfocused    false
#request setmaximized  false

/* Native transparency for Wayland / XWayland compositors */
#request setopacity    "native"
#request setmirror     false

/* OpenGL and GLSL engine requirements */
#request setversion 3 3
#request setshaderversion 330

/* Window properties */
#request settitle "GLava"
#request setgeometry 0 0 600 600
#request setbg 00000000

/* Window manager states (disabled for Hyprland floating mode) */
#request setxwintype "normal"
#request setclickthrough false

/* Audio backend configuration */
#request setsource "auto"
#request setswap 1
#request setinterpolate true
#request setframerate 0
#request setfullscreencheck false
#request setprintframes false

/* Audio buffer & FFT sampling settings */
#request setsamplesize 1024
#request setbufsize 4096
#request setsamplerate 22050

/* Deprecated parameters */
#request setforcegeometry false
#request setforceraised false
#request setbufscale 1
