precision highp float;

#define TIME_SCALE_BEGIN 3.6
#define DST 0.5
#define CHROMATIC_ABERRATION_Q 0.09

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - DST * iResolution.xy) / iResolution.x + DST;
    float radius = length(uv - DST) - iTime / TIME_SCALE_BEGIN;
    float angle = atan(uv.y - DST, uv.x - DST);
    uv += smoothstep(0.1, 0.2, radius) * smoothstep(0.3, 0.2, radius) * smoothstep(0.0, 1.0, radius) * vec2(cos(angle), sin(angle));
    float maxStrength = clamp(sin(iTime / TIME_SCALE_BEGIN), CHROMATIC_ABERRATION_Q, CHROMATIC_ABERRATION_Q);
    vec3 colour = vec3(texture(iChannel0, uv));
    colour.r = texture(iChannel0, vec2(uv.x + maxStrength, uv.y + maxStrength)).r;
    fragColor = vec4(colour + (vec4(1.0, 0.8, 0.7, 1.0) * smoothstep(0.2, 0.0, radius) * 1.999 - iTime / TIME_SCALE_BEGIN * 0.84).xyz, 1.0);
}