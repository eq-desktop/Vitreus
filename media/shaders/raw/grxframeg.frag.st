const float u_glassBevel = 0.215;
const float u_glassMaxRefractionDistance = 0.20;
const float u_glassHairlineWidthPixels = 2.0;
const float u_glassHairlineReflectionDistance = 0.25;

vec4 blurBufferLookup(vec2 p) {
    return texture(iChannel0, p);
}

float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r ) {
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}
vec2  u_boxSize      = vec2(400.0, 300.0);
vec4  u_cornerRadii  = vec4(80.0);
vec3  u_glowColor    = vec3(1.0);
float u_glowIntensity= 1.2;
float u_glowEdgeBand = 1.2;
float u_glowAngWidth = 1.4;
float u_glowTheta1   = 0.0;
float u_glowTheta2   = 3.14159;
vec4  u_baseColor    = vec4(0.0, 0.0, 0.0, 1.0);
vec2  u_lightDir     = normalize(vec2(1.0, 0.2));

#define PI 3.14159265359
#define TWO_PI (2.0 * PI)


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
        // outside rounded rectangle (corner region or edge)
        dist = l - r;
        // avoid division by zero
        if (l > 1e-6) grad = (q / l) * s;
        else grad = vec2(0.0,0.0);
    } else {
        // inside rectangle (signed distance is negative)
        dist = g - r;
        // gradient points to the nearest edge (axis-aligned)
        if (w.x > w.y) grad = vec2(s.x, 0.0);
        else grad = vec2(0.0, s.y);
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

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 res = iResolution.xy;
    vec2 p = (2.0 * fragCoord - res) / res.y;

    float w = u_boxSize.x;
    float h = u_boxSize.y;
    float toUnit = 2.0 / res.y;
    vec2 halfBox = vec2(w, h) * 0.5 * toUnit;

    // Main distance for refraction + bevel
    float pxToUnit = 2.0 / iResolution.y;
    vec4 radiusUnit = u_cornerRadii * pxToUnit;
    vec4 radius = vec4(radiusUnit);
    radius = min(radius, min(halfBox.x, halfBox.y));
    float distMain = sdRoundedBox(p, halfBox, radius);

    // Glow SDF uses pixel-space angle
    vec2 pix = fragCoord - res * 0.5;
    float theta = normAngle(atan(pix.y, pix.x));

    // Light directions
    vec2 oppositeDir = -normalize(u_lightDir);
    float lightAngle = normAngle(atan(oppositeDir.y, oppositeDir.x));

    float angle1 = normAngle(u_glowTheta1 + lightAngle);
    float angle2 = normAngle(u_glowTheta2 + lightAngle);
    // px-position centered
    vec2 pp = fragCoord - res * 0.5;

    // compute pixel-space SDF for glow box
    vec3 sdG = sdgBox(pp, u_boxSize * 0.5, u_cornerRadii);
    float distGlow = sdG.x;

    // radial rim thickness in pixels
    float edgeBand = 1.0 - smoothstep(0.0, u_glowEdgeBand, abs(distGlow));

    float dAng1 = angDistAbs(theta, angle1);
    float dAng2 = angDistAbs(theta, angle2);

    float aMask1 = 1.0 - smoothstep(0.0, u_glowAngWidth, dAng1);
    float aMask2 = 1.0 - smoothstep(0.0, u_glowAngWidth, dAng2);

    float angMask = clamp(aMask1 + aMask2, 0.0, 1.0);

    // final sharp rim glow
    float glow = angMask * edgeBand * u_glowIntensity;

    // STARTING BACKGROUND COLOR
    vec3 color = texture(iChannel0, p).rgb;

    if (distMain < 0.0)
    {
        float pxDist = -distMain / (2.0 / res.y);

        vec2 d = vec2(dFdx(distMain), dFdy(distMain));
        vec2 refDir = -normalize(d);

        float refPct = pow(clamp(1.0 + distMain / u_glassBevel, 0.0, 1.0), 4.0);
        vec2 offset = u_glassMaxRefractionDistance * refPct * refDir;

        vec3 refracted = blurBufferLookup(p + offset).rgb;

        float cov = smoothstep(0.0, 1.0, pxDist);
        color = mix(color, refracted, cov);

        float hairCov =
            smoothstep(0.0, 1.0, pxDist) *
            (1.0 - smoothstep(u_glassHairlineWidthPixels,
                              u_glassHairlineWidthPixels + 1.0,
                              pxDist));

        vec3 hairSample = blurBufferLookup(p - u_glassHairlineReflectionDistance * refDir).rgb;
        color += hairCov * hairSample;
    }

    color += glow * u_glowColor;

    fragColor = vec4(color, 1.0);
}
