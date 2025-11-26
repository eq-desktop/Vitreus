#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

// uniforms
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 iResolution;
    vec2 boxSize;
    vec4 cornerRadii;
    vec3 glowColor;
    float glowIntensity;
    float glowEdgeBand;
    float glowAngWidth;
    float glowTheta1;
    float glowTheta2;
    vec4 baseColor;
    vec2 lightDir;
};

// Signed distance + gradient for rounded box
vec3 sdgBox(in vec2 p, in vec2 b, in vec4 ra) {
    ra.xy = (p.x > 0.0) ? ra.xy : ra.zw;
    float r = (p.y > 0.0) ? ra.x : ra.y;
    vec2 w = abs(p) - (b - r);
    vec2 s = vec2(p.x < 0.0 ? -1 : 1, p.y < 0.0 ? -1 : 1);
    float g = max(w.x, w.y);
    vec2 q = max(w, 0.0);
    float l = length(q);
    return vec3((g > 0.0) ? l - r : g - r, s * ((g > 0.0) ? q / l : ((w.x > w.y) ? vec2(1,0) : vec2(0,1))));
}

void main() {
    vec2 fragCoord = qt_TexCoord0 * iResolution;
    vec2 centerPx = iResolution * 0.5;
    vec2 p = fragCoord - centerPx;

    vec3 sd = sdgBox(p, boxSize, cornerRadii);
    float dist = sd.x;

    vec2 fragToCenter = p; // vector from center to pixel
    float theta = atan(fragToCenter.y, fragToCenter.x);
    if (theta < 0.0) theta += 6.28318530718;

    vec2 oppositeDir = -lightDir;
    float lightAngle = atan(oppositeDir.y, oppositeDir.x);
    if (lightAngle < 0.0) lightAngle += 6.28318530718;

    float angle1 = glowTheta1 + lightAngle;
    float angle2 = glowTheta2 + lightAngle;

    float dAng1 = abs(atan(sin(theta - angle1), cos(theta - angle1)));
    float dAng2 = abs(atan(sin(theta - angle2), cos(theta - angle2)));

    float angMask = smoothstep(glowAngWidth, 0.0, dAng1) +
                    smoothstep(glowAngWidth, 0.0, dAng2);
    angMask = clamp(angMask, 0.0, 1.0);

    float edgeBand = 1.0 - smoothstep(0.0, glowEdgeBand, abs(dist));
    float glow = angMask * edgeBand * glowIntensity;

    vec3 col = glowColor * glow;
    fragColor = vec4(col, baseColor.a);
}