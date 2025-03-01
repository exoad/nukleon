#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform float uAmount;
uniform vec2 uSize;

uniform sampler2D uTexture;

out vec4 fragColor;

void main()
{
    vec2 uv=FlutterFragCoord().xy/uSize.xy;
    vec2 u=uAmount/uSize.xy*0.5;
    u=smoothstep(vec2(0),u,1.0-abs(uv*2.0-1.0));
    fragColor=col*texture(uTexture,uv)*u.x*u.y;
}