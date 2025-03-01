#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

layout (location=0) uniform float uSteps;
layout (location=1) uniform vec2 uSize;

layout (location=0) uniform sampler2D uTexture;

layout (location=0) out vec4 fragColor;

void main()
{
    vec2 uv=FlutterFragCoord().xy/uSize.xy;
    vec4 col=texture(uTexture,uv);
    fragColor=vec4(floor(col.rgb*value)/value,col.a);
}