#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

#define DST 0.5
#define CHROMATIC_ABERRATION_Q 0.09

uniform float uTimeScale;
uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uSize;
out vec4 fragColor;

void main()
{
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv = (fragCoord - DST * uSize.xy) / uSize.x + DST;
    float radius = length(uv - DST) - uTime / uTimeScale;
    float angle = atan(uv.y - DST, uv.x - DST);
    uv += smoothstep(0.3, 0.2, radius) * smoothstep(0.0, 1.0, radius) * vec2(cos(angle), sin(angle));
    float maxStrength = clamp(sin(uTime / uTimeScale), CHROMATIC_ABERRATION_Q, CHROMATIC_ABERRATION_Q);
    vec3 colour = vec3(texture(uTexture, uv));
    colour.r = texture(uTexture, vec2(uv.x + maxStrength * 1.45, uv.y + maxStrength * 1.45)).r;
    fragColor = vec4((colour.rgb * (1.0 - uTime / uTimeScale)) + (vec4(1.0, 0.8, 0.7, 1.0) * smoothstep(0.2, 0.0, radius) * 1.999 - uTime / uTimeScale * 0.84).rgb, 1.0);
}