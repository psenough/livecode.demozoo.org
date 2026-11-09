#version 420 core

uniform float fGlobalTime;
uniform vec2 v2Resolution;
uniform float fFrameTime;

uniform sampler1D texFFT;
uniform sampler1D texFFTSmoothed;
uniform sampler1D texFFTIntegrated;
uniform sampler2D texPreviousFrame;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color;

float shape(vec2 p)
{
    p *= 3.0;
    p.y += 0.3;
    float x = p.x;
    float y = p.y;
    return pow(x*x + y*y - 0.5, 0.5) - x*x*y*y*y;
}

mat2 r2(float a)
{
    float c = sin(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdShape3D(vec3 p, float s)
{
    vec2 q = p.xy / s;
    float h = shape(q);
    float d2 = h * 2 * s;
    float dz = abs(p.z) - s * 2;
    return max(d2, dz);
}

float map(vec3 p)
{
    float t = fGlobalTime;
    float g = 3;
    vec3 q = p;

    q.z = mod(q.z + t * 3.0, 30.0) - 15.0;
    q.x = mod(q.x + g * 0.5, g) - g * 0.5;
    q.y = mod(q.y + g * 0.5, g) - g * 0.5;

    float idz = floor((p.z + t * 3.0 + 15.0) / g);
    float a = t * 2 + idz * 2;

    q.xy *= r2(a);

    float fft = texture(texFFTSmoothed, fract(idz * 0.05)).r;
    float s = 0.2 + fft * 0.2;

    return sdShape3D(q, s);
}

vec3 getNormal(vec3 p)
{
    vec2 e = vec2(0.02, 0.5);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

void main(void)
{
    vec2 uv = (gl_FragCoord.xy * 2.0 - v2Resolution.xy) / v2Resolution.y;

    vec3 ro = vec3(0.0, 0.0, -5.0);
    vec3 rd = normalize(vec3(uv, 1.8));

    ro.xy *= r2(sin(fGlobalTime * 0.2) * 0.3);
    rd.xy *= r2(sin(fGlobalTime * 0.2) * 0.3);

    float t = 0.5;
    float d = 0.0;
    bool hit = false;

    for (int i = 0; i < 128; i++)
    {
        vec3 p = ro + rd * t;
        d = map(p);
        if (d < 0.002)
        {
            hit = true;
            break;
        }
        t += d * 0.7;
        if (t > 60.0) break;
    }

    vec3 col = vec3(0, 0, 1);

    if (hit)
    {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        vec3 l = normalize(vec3(-1, 1, -0.4));

        float diff = max(dot(n, l), 0.0);
        float spec = pow(max(dot(reflect(-l, n), -rd), 0.0), 24.0);

        float fft = texture(texFFT, clamp(length(p) * 0.04, 0.0, 1.0)).r;

        vec3 base = vec3(1.0, 0.2, 0.35);
        col = base * (0.3 + diff * 0.7) + spec * 0.5;
        col += fft * 1.5 * base;

        float fog = exp(-t * 0.05);
        col *= fog;
    }

    out_color = vec4(col, 1.0);
}


