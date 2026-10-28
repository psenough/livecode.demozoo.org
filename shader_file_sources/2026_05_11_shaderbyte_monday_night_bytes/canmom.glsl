#version 430 core

//hello fieldfx!
//let's see if we can do "we have Empires at home"

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = radians(180.0);

const float PERIOD = 0.75;
const float CAMPERIOD = 15.0;

//pcg3d: https://github.com/markjarzynski/PCG3D
uvec3 hash(uvec3 v) {
    v = v * 1664525u + 1013904223u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    v ^= v >> 16u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    return v;
}

const float U32_MAX = float(0xffffffffu);
const float POS_OFFSET = float(0xfeu);
vec3 hash_float(vec3 v) {
    uvec3 vu = uvec3(v + POS_OFFSET);
    return hash(vu) * (1.0 / U32_MAX);
}

int CIRCLE_RADIUS = 64;

void splat_diamond(ivec2 UV, float size, vec3 colour) {
    float sf = float(CIRCLE_RADIUS) * size;
    int steps = 2 + max(min(int(sf), 16), 0);
    float inter = sf - floor(sf);
    float brightness = min(128.0 / float(steps), 128.0);
    uvec3 col = uvec3(brightness * colour);
    uvec3 icol = uvec3(0.5 * brightness * colour * inter);
    int ts = 2 * steps;
    for (int i = -steps; i < steps; i++) {
        int jmin = -steps + abs(i);
        int jmax = -jmin;
        imageAtomicAdd(computeTex[0], UV + ivec2(i, jmin - 1), icol.x);
        imageAtomicAdd(computeTex[1], UV + ivec2(i, jmin - 1), icol.y);
        imageAtomicAdd(computeTex[2], UV + ivec2(i, jmin - 1), icol.z);
        imageAtomicAdd(computeTex[0], UV + ivec2(i, jmax), icol.x);
        imageAtomicAdd(computeTex[1], UV + ivec2(i, jmax), icol.y);
        imageAtomicAdd(computeTex[2], UV + ivec2(i, jmax), icol.z);
        for (int j = jmin; j < jmax; j++) {
            imageAtomicAdd(computeTex[0], UV + ivec2(i, j), col.x);
            imageAtomicAdd(computeTex[1], UV + ivec2(i, j), col.y);
            imageAtomicAdd(computeTex[2], UV + ivec2(i, j), col.z);
        }
    }
}

void main(void) {
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    float fft_time = 0.15 * texture(texFFTIntegrated, 0.15).r + mod(0.15 * fGlobalTime, CAMPERIOD);

    vec3 cam_pos = vec3(cos(fft_time), 1.5 * sin(fft_time), 0.45 + 0.05 * sin(texture(texFFTIntegrated, 0.3).r));

    float time = fGlobalTime;

    cam_pos *= vec3(1.0 + step(mod(time + 0.25 * CAMPERIOD, 4.0 * CAMPERIOD), 0.25 * CAMPERIOD), 1.0, 3.0 - step(mod(time, CAMPERIOD), 0.5 * CAMPERIOD) - 1.5 * step(mod(time, CAMPERIOD), 0.75 * CAMPERIOD));

    float cam_distance_from_centre = length(cam_pos);

    vec3 cam_dir = normalize(-cam_pos);
    vec3 cam_x = normalize(cross(vec3(0, 0, 1), cam_dir));
    vec3 cam_y = normalize(cross(cam_x, cam_dir));

    vec3 ray_dir = normalize(cam_dir + uv.x * cam_x - uv.y * cam_y);

    //out_color.xyz = draw_flowers(cam_pos, ray_dir).xyz;

    vec2 frame_uv = gl_FragCoord.xy / v2Resolution;
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            out_color += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution - vec2(i, j) * 0.002) / 9.0 * 0.5;
        }
    }

    vec3 pixel_hash = hash_float(vec3(vec2(gl_FragCoord.xy), 0)) - vec3(0.5);
    float time_band = 5.0 * texture(texFFTIntegrated, pixel_hash.z).r;
    float c = cos(time_band);
    float s = sin(time_band);
    vec3 splat_pos = vec3(2.0 * vec2(c, s) * pixel_hash.x, texture(texFFTSmoothed, pixel_hash.x));

    float projected_x = dot(splat_pos, cam_x);
    float projected_y = -dot(splat_pos, cam_y);
    float depth = dot(splat_pos, cam_dir);

    float dof_size = 0.1 * abs(depth);

    ivec2 UV = ivec2(gl_FragCoord.xy);
    float aspect_ratio = v2Resolution.x / v2Resolution.y;
    ivec2 draw_pixel = ivec2(v2Resolution.xy * (vec2(0.5) + vec2(projected_x / aspect_ratio, projected_y)));

    splat_diamond(draw_pixel, dof_size, pixel_hash / (0.2 + 0.5 * pixel_hash.y));

    out_color += 0.00001 * vec4(imageLoad(computeTexBack[2], UV).r, imageLoad(computeTexBack[0], UV).r, imageLoad(computeTexBack[1], UV).r, 0.0);

    out_color = tanh(1.5 * out_color);
}
