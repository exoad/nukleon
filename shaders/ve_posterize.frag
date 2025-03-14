#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform float uSteps;
uniform vec2 uSize;

uniform sampler2D uTexture;

out vec4 fragColor;

void main()
{
    vec2 uv=FlutterFragCoord().xy/uSize.xy;
    vec4 col=texture(uTexture,uv);
    fragColor=vec4(floor(col.rgb*uSteps)/uSteps,col.a);
}