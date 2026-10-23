#version 460 core

//hello fieldfx!
//here is a previous shape, let's make a new one <3
//this code was written by a previous canmom
//and now it is being added to by a canmom that is in a different instruction set
//a different space of thought oscillations
//today's was recursive
//recursively evaluate through blahaj-symbol
//project out project out project out

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

const uint QUADTREE_DEPTH = 4;

vec3 hash_float(vec3 v) {
    uvec3 vu = uvec3(v + POS_OFFSET);
    return hash(vu) * (1.0 / U32_MAX);
}

vec3 quadtree_hash(vec2 position, out float size) {
    size = 1.0;
    vec2 corner;
    vec3 cell_hash;
    for (int i = 0; i < QUADTREE_DEPTH; i++) {
        corner = floor(position / (size * 2.0 * PERIOD));
        cell_hash = hash_float(vec3(corner, 0.0));
        if (cell_hash.r > 0.5) {
            size /= 2.0;
        } else {
            return cell_hash;
        }
    }
    corner = floor(position / (size * 2.0 * PERIOD));
    cell_hash = hash_float(vec3(corner, 0.0));
    return cell_hash;
}

const uint MAX_DEPTH = 4;

//from https://www.shadertoy.com/view/sXS3Dw
vec3 c1(float t) {
    return vec3(0.20,0.11,0.09)
        +t*(vec3(2.41,3.97,1.95)
        +t*(vec3(-20.77,-44.43,16.57)
        +t*(vec3(153.33,183.16,-125.96)
        +t*(vec3(-401.40,-311.48,297.60)
        +t*(vec3(418.13,231.50,-293.64)
        +t*(vec3(-151.76,-62.60,103.55)
    ))))));
}

void main() {
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    uint depth = 0;
    float ray_length = 0.0;

    out_color = vec4(0.6*vec3(0.5,0.4,0.6)+0.1*c1(gl_FragCoord.x/v2Resolution.x), 1.0);
    float fft_time = mod(0.1 * (1.0 + 3.0 * float(depth)) * texture(texFFTIntegrated,0.05).r, CAMPERIOD);

    vec3 cam_pos = vec3(cos(fft_time), 1.5 * sin(fft_time), 0.3*sin(fft_time) -0.5*texture(texFFTSmoothed,0.05));
  
    vec3 h = vec3(fft_time, 0.0, 0.0);
    bool hit_sphere = true;

    while (hit_sphere && depth < MAX_DEPTH)
    {
        
        //float fft_time = 0.0;

        //float time = 0.5*CAMPERIOD;
        float time = fGlobalTime;
        vec3 cam_dir = normalize(-cam_pos);
        cam_pos += vec3(0.0, fft_time, 0.2*depth*(2.0*h.z-1.0)) + 1.0*h;
        vec3 cam_x = normalize(cross(vec3(0, 0, 1), cam_dir));
        vec3 cam_y = normalize(cross(cam_x, cam_dir));

        vec3 ray_dir = normalize(cam_dir + uv.x * cam_x - uv.y * cam_y);

        float dist = 1.0 / 0.0;
        vec3 ray_pos = cam_pos + ray_dir * 0.5;
        ray_length += 0.5;
        float size = 2.0;
        vec3 sign_dir = sign(ray_dir);
        hit_sphere = false;

        //increase for more raymarch layers of shark
        for (int i = 0; i < 128; i++) {
            h = quadtree_hash(ray_pos.xy, size);
            float adjusted_size = size * 2.0 * PERIOD;
            float radius = 0.5 * size;
            vec3 cell_centre = vec3(adjusted_size * (floor(ray_pos.xy / adjusted_size)), 0.0) + vec3(vec2(PERIOD * size), radius) + vec3(0.0, 0.0, (-0.8-10.0*texture(texFFTSmoothed,h.b)) * sin(2.5*h.r * texture(texFFTIntegrated, h.g)));
            //needs to be more blue
            //for shark
            //for memdmp
            //for all weird transfem constructs on the wired
            //more blue
            vec3 relative = ray_pos - cell_centre;
            //test for the sphere in this cell

            float b = dot(relative, ray_dir);
            vec3 qc = relative - b * ray_dir;
            float hypotenuse = radius * radius - dot(qc, qc);
            if (hypotenuse >= 0.0) {
                hypotenuse = sqrt(hypotenuse);
                float t = -b - hypotenuse;
                //if we're not inside a sphere, advance to the sphere
                if (t > 0.0) {
                    ray_pos = ray_pos + t * ray_dir;
                    ray_length += t;
                }
                //we can only have hit a sphere
                //there is only shark
                //so let's get teh coordinates on shark
                vec3 normed_rel = normalize(ray_pos - cell_centre);
                float u = atan(normed_rel.y, normed_rel.x);
                float v = asin(normed_rel.z);
                uv = vec2(u, v)/(2*PI);
                 
                vec3 lambertian = vec3(dot(normed_rel, normalize(vec3(cos(depth), sin(depth), -h.z)))*0.5+0.5);

                
                hit_sphere = true;
                //out_color.xyz =0.5*(lambertian * vec3(0.3, 0.5, 0.9) * (0.5+0.5* h));
                //out_color.xyz = h*vec3(lambertian);
                vec3 col = (c1(lambertian.r) + 0.2*vec3(1.0));
                out_color.xyz *= 1.3*col;
                //compensate for saturation boost from repeated mults
                out_color.xyz = vec3(0.5) + 0.9*(out_color.xyz-vec3(0.5));
                //out_color.xyz += 0.05*col;
                //out_color.xyz = vec3(uv,0.0);
                //out_color = vec4(h*vec3(clamp(dot(vec3(1.0,0.0,0.0),relative/size),0.0,1.0)+0.1),1.0);
                depth += 1;
                break;
                
            } else {
                //jump to the next box
                vec3 m = 1.0 / ray_dir;
                vec3 n = m * (ray_pos - cell_centre);
                vec3 k = abs(m) * size * PERIOD;
                vec3 t2 = -n + k;
                float tF = min(t2.x, t2.y);
                //we know the ray is inside the box so only need tF
                //small epsilon to stop rays getting stuck on the edge of boxes
                ray_pos += ray_dir * max(tF, 0.001);
                ray_length += tF;
                if (ray_length > 64.0) {
                  break;
                }
            }
        }
        vec2 frame_uv = gl_FragCoord.xy / v2Resolution;

        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <=1; j++) {
                out_color += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution - vec2(i, j) * 0.001) / 9.0 * vec4(vec3(0.2), 1.0);
            }
        }
    }
    
    out_color.xyz = out_color.xyz - 0.15*ray_length/30.0;
    //out_color.xyz *= 10.0/ray_length;
    out_color = tanh(out_color);
}
