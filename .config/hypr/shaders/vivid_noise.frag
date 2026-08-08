#version 300 es
precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;

// Noise generator function
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // =========================================================================
    // TWEAK 1: VIBRANCY / SATURATION
    // =========================================================================
    float vibrancy_strength = 1.45; // Put your 1.45 vibrancy back here to pop the colors!

    float luma = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    pixColor.rgb = mix(vec3(luma), pixColor.rgb, vibrancy_strength);

    // =========================================================================
    // TWEAK 2: FROSTED GLASS NOISE
    // =========================================================================
    float grain_strength = 0.04;
    float grain = (rand(v_texcoord) - 0.8) * grain_strength;

    pixColor.rgb += vec3(grain, grain, grain);

    // Output directly to display
    fragColor = pixColor;
}
