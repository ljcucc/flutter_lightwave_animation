#version 460 core
#include <flutter/runtime_effect.glsl>

// Viewport size in physical pixels
uniform vec2 uSize;

// Center of the wave in physical pixels
uniform vec2 uOrigin;

// Animation progress: 0.0 to 1.0 (Eased curve)
uniform float uProgress;

// Captured snapshot texture
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    // 1. Normalized Coordinates & Distance
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;

    vec2 delta = fragCoord - uOrigin;
    float dist = length(delta);
    vec2 dir = dist > 0.0001 ? delta / dist : vec2(0.0, 1.0);

    // 2. Shockwave Wavefront
    float maxRadius = length(uSize);
    // Bell curve wave width scaled to viewport
    float waveWidth = max(maxRadius * 0.07, 24.0);
    float currentRadius = uProgress * (maxRadius + waveWidth);

    // Wave profile: Gaussian-like bell curve for a smooth organic bulge
    float diff = dist - currentRadius;
    float wave = exp(-pow(diff / waveWidth, 2.0));

    // Temporal attenuation: decays as it travels outward
    float decay = smoothstep(1.0, 0.2, uProgress);
    // Smooth onset so the wave emerges gracefully without popping at frame 0
    float attack = smoothstep(0.0, 0.04, uProgress);
    float waveStrength = wave * decay * attack;

    // 3. Refractive UV Displacement
    // maxDisplacement is in UV coordinates: sleek, organic glass liquid ripple
    const float maxDisplacement = 0.035;
    // Aspect-ratio correction to keep physical distortion isotropic
    vec2 dispDir = vec2(dir.x, dir.y * (uSize.x / uSize.y));
    vec2 displacement = -dispDir * (waveStrength * maxDisplacement);

    // 4. Chromatic Aberration (Prism Dispersion)
    vec2 uvR = clamp(uv + displacement * 1.00, vec2(0.0), vec2(1.0));
    vec2 uvG = clamp(uv + displacement * 1.04, vec2(0.0), vec2(1.0));
    vec2 uvB = clamp(uv + displacement * 1.08, vec2(0.0), vec2(1.0));

    float r = texture(uTexture, uvR).r;
    float g = texture(uTexture, uvG).g;
    float b = texture(uTexture, uvB).b;
    vec4 colOriginal = texture(uTexture, uv);

    vec3 color = vec3(r, g, b);

    // 5. Specular Highlight / Glare
    // Add a subtle additive white sheen at the crest of the wave
    color += vec3(waveStrength * 0.18) * colOriginal.a;

    // 6. Preserve original alpha from uTexture
    fragColor = vec4(color, colOriginal.a);
}
