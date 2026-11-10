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
    // Broader wave span (波的範圍大: wave width scaled to 0.12)
    float waveWidth = max(maxRadius * 0.12, 42.0);
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
    // Stronger refractive displacement (偏移程度大: max displacement = 0.070)
    const float maxDisplacement = 0.070;
    // Aspect-ratio correction to keep physical distortion isotropic
    vec2 dispDir = vec2(dir.x, dir.y * (uSize.x / uSize.y));
    vec2 displacement = -dispDir * (waveStrength * maxDisplacement);

    // 4. Chromatic Aberration (Prism Dispersion)
    vec2 uvR = clamp(uv + displacement * 0.96, vec2(0.0), vec2(1.0));
    vec2 uvG = clamp(uv + displacement * 1.02, vec2(0.0), vec2(1.0));
    vec2 uvB = clamp(uv + displacement * 1.08, vec2(0.0), vec2(1.0));

    float r = texture(uTexture, uvR).r;
    float g = texture(uTexture, uvG).g;
    float b = texture(uTexture, uvB).b;
    vec4 colOriginal = texture(uTexture, uv);

    vec3 color = vec3(r, g, b);

    // 5. Specular Highlight & EDR Origin Glow Sphere
    // (a) Wave crest sheen (波的光暈微亮: soft sheen + micro ridge glint)
    float crestSheen = waveStrength * 0.32;
    float sharpRidge = pow(wave, 10.0) * decay * attack;
    float crestGlint = sharpRidge * 0.28;
    float waveGlow = crestSheen + crestGlint; // Peak reaches ~0.60

    // (b) Origin EDR white blurred glow sphere (點擊出發點的白色模糊光球)
    // - Starts with radius >= 300px (起碼有 300px 的半徑大小)
    // - Expands to nearly 2.0x size as it dissipates in place (原地散去並擴散至 500px+)
    // - Uses EDR selectively: hot center exceeds 1.0 (reaching ~2.20), while broad halo smoothly fades below 1.0
    float minDim = min(uSize.x, uSize.y);
    float initialOrbRadius = max(minDim * 0.35, 300.0);
    float currentOrbRadius = initialOrbRadius * (1.0 + 0.85 * uProgress);
    float normalizedDist = dist / currentOrbRadius;

    // Soft broad halo (feathered gradient covering the 300-550px orb, < 1.0 so no flat white blowout)
    float softHalo = exp(-2.2 * pow(normalizedDist, 2.0)) * 0.65;
    // Concentrated EDR nucleus (> 1.0 only at the inner core for true EDR glow brilliance)
    float hotCore = exp(-8.0 * pow(normalizedDist, 2.0)) * 1.55;

    // Fade out smoothly over time
    float orbFade = smoothstep(0.0, 0.03, uProgress) * pow(1.0 - uProgress, 1.25);
    // Total point light: center hits ~2.20 (EDR boost), surrounding halo stays soft and feathered
    float orbLight = (softHalo + hotCore) * orbFade;

    // Additive white highlights onto texture
    color += vec3(waveGlow + orbLight) * colOriginal.a;

    // 6. Preserve original alpha from uTexture
    fragColor = vec4(color, colOriginal.a);
}
