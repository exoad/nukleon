#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    fragColor.rgb=texture(uTexture,FlutterFragCoord().xy/uSize.xy).rgb*mat3(
        .393,.769,.189,
        .349,.686,.168,
        .272,.534,.131
    );
    fragColor.a=1.0;
}