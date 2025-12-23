#version 440

// Input / output
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

// Texture samplers
layout(binding = 0) uniform sampler2D source;
layout(binding = 1) uniform sampler2D blurSource;

// Constants
#define PI 3.14159265359
#define TWO_PI (2.0 * PI)

// Uniforms
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
    
    float glassBevel;
    float glassMaxRefractionDistance;
    float glassHairlineWidthPixels;
    float glassHairlineReflectionDistance;
};

float sdRoundedBox(in vec2 p, in vec2 b, in vec4 r) {
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

vec4 blurBufferLookup(vec2 point) {
    return texture(blurSource, point);
}

vec3 sdgBox(in vec2 p, in vec2 b, in vec4 ra) {
    float rx = (p.x > 0.0) ? ra.y : ra.x;
    float ry = (p.y > 0.0) ? ra.w : ra.z;
    float r = min(rx, ry);
    vec2 rvec = vec2(rx, ry);

    vec2 w = abs(p) - (b - rvec);
    vec2 s = vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
    float g = max(w.x, w.y);
    vec2 q = max(w, vec2(0.0));
    float l = length(q);

    float dist;
    vec2 grad;
    if (g > 0.0) {
        dist = l - r;
        grad = (l > 1e-6) ? (q / l) * s : vec2(0.0);
    } else {
        dist = g - r;
        grad = (w.x > w.y) ? vec2(s.x, 0.0) : vec2(0.0, s.y);
    }
    return vec3(dist, grad.x, grad.y);
}

float normAngle(float a) {
    a = mod(a, TWO_PI);
    return (a < 0.0) ? a + TWO_PI : a;
}

float angDistAbs(float a, float b) {
    float d = abs(a - b);
    d = mod(d + PI, TWO_PI) - PI;
    return abs(d);
}

void main() {
    vec2 res = iResolution.xy;
    vec2 fragCoord = qt_TexCoord0 * iResolution;
    vec2 centerPx = iResolution * 0.5;
    vec2 p = fragCoord - centerPx;

    vec3 base = baseColor.rgb; // from your uniform

    // halfBox in pixels
    vec2 halfBox = boxSize * 0.5;

    // corner radii in pixels
    vec4 radius = cornerRadii;

    vec3 sdG = sdgBox(p, halfBox, radius);
    float distMain = sdG.x;
    vec2 gradMain  = normalize(vec2(sdG.y, sdG.z));
    vec2 refDir    = -gradMain;

    float theta = normAngle(atan(p.y, p.x));

    vec2 oppositeDir = -normalize(lightDir);
    float lightAngle = normAngle(atan(oppositeDir.y, oppositeDir.x));

    float angle1 = normAngle(glowTheta1 + lightAngle);
    float angle2 = normAngle(glowTheta2 + lightAngle);

    float distGlow = sdG.x;

    float edgeBand = 1.0 - smoothstep(0.0, glowEdgeBand, abs(distGlow));

    float dAng1 = angDistAbs(theta, angle1);
    float dAng2 = angDistAbs(theta, angle2);

    float aMask1 = 1.0 - smoothstep(0.0, glowAngWidth, dAng1);
    float aMask2 = 1.0 - smoothstep(0.0, glowAngWidth, dAng2);

    float angMask = clamp(aMask1 + aMask2, 0.0, 1.0);
    float glow = angMask * edgeBand * glowIntensity;

    vec2 uv = fragCoord / iResolution; // normalized [0,1]

    vec3 color = texture(source, uv).rgb;

    if (distMain < 0.0)
    {
        float pxDist = -distMain * (res.y * 0.5); // convert SDF units to pixels
        float cov = smoothstep(0.0, glassBevel, pxDist);
        vec2 d = vec2(dFdx(distMain), dFdy(distMain));

        float refPct = pow(clamp(1.0 + distMain / glassBevel, 0.0, 1.0), 4.0);
        vec2 offset = glassMaxRefractionDistance * refPct * refDir;

        vec2 uvOffset = uv + offset / iResolution.xy;
        vec3 refracted = blurBufferLookup(uvOffset).rgb;


        color = mix(color, refracted, cov);
        color = mix(color, base, cov*baseColor.a);

        float hairCov = cov * (1.0 - smoothstep(glassHairlineWidthPixels,
                                                glassHairlineWidthPixels + 1.0,
                                                pxDist));
        vec2 uvHair = (fragCoord - glassHairlineReflectionDistance * refDir) / iResolution;
        vec3 hairSample = blurBufferLookup(uvHair).rgb;
        color += hairCov * hairSample;
    }

    color += glow * glowColor;

    fragColor = vec4(color, 1.0);
}
