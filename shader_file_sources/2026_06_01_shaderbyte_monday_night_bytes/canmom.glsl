#version 430 core

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

bool flower_test(inout vec3 abs_pos, vec3 cell_centre, float size, float hash, vec3 ray_dir, inout vec4 colour) {
    float hit_flower = 0.0;
    vec3 ray_pos;
    for (int i = 0; i < 20; i++) {
        ray_pos = (abs_pos - cell_centre) / (size);
        //if (length(ray_pos) > 0.5/size) {return false;}
        float layer = floor(length(ray_pos) * 10.0);
        float longitude = atan(ray_pos.y, ray_pos.x) + (3.0 - 3.0 * hash) * texture(texFFTIntegrated, layer / 10.0).r;
        float latitude = atan(ray_pos.z, length(ray_pos.xy)) / PI + 0.5;
        if (latitude < (0.8 - 0.15 * layer) + 0.4 * abs(fract((2.0 + layer) * longitude / PI) - 0.5)) {
            hit_flower = layer / 10.0;
            break;
        }
        abs_pos += 0.005 * ray_dir * size;
    }

    if (hit_flower > 0.0) {
        colour = vec4(mix(vec3(0.8, 0.1, 0.4) * 0.6, vec3(1.0, 0.3, 1.0), hit_flower + 1.5 * ray_pos.z), 1.0);
        return true;
    } else {
        return false;
    }
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

const uint MAX_DEPTH = 3;

void main() {
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
    uint depth = 0;
    float ray_length = 0.0;
  
    out_color = vec4(vec3(0.001, 0.008, 0.04), 1.0);
  float fft_time = 0.15 * texture(texFFTIntegrated, 0.15).r + mod(0.15 * (1.0 + 3.0*float(depth)) * fGlobalTime, CAMPERIOD);
  
    vec3 cam_pos = vec3(cos(fft_time), 1.5 * sin(fft_time), 0.45 + 0.05 * sin(texture(texFFTIntegrated, 0.3).r));
    
    while (depth < MAX_DEPTH)
    {
    
    //float fft_time = 0.0;

    //float time = 0.5*CAMPERIOD;
    float time = fGlobalTime;

    cam_pos *= vec3(1.0 + step(mod(time + 0.25 * CAMPERIOD, 4.0 * CAMPERIOD), 0.25 * CAMPERIOD), 1.0, 3.0 - step(mod(time, CAMPERIOD), 0.5 * CAMPERIOD) - 1.5 * step(mod(time, CAMPERIOD), 0.75 * CAMPERIOD));

    vec3 cam_dir = normalize(-cam_pos);
    cam_pos += vec3(0.0, fft_time, 0.0);
    vec3 cam_x = normalize(cross(vec3(0, 0, 1), cam_dir));
    vec3 cam_y = normalize(cross(cam_x, cam_dir));

    vec3 ray_dir = normalize(cam_dir + uv.x * cam_x - uv.y * cam_y);

    float dist = 1.0 / 0.0;
    vec3 ray_pos = cam_pos;
    bool hit_sphere = false;
    float size = 2.0;
    vec3 sign_dir = sign(ray_dir);
    
    //increase for more raymarch layers of shark
    for (int i = 0; i < 24; i++) {      
        vec3 h = quadtree_hash(ray_pos.xy, size);
        float adjusted_size = size * 2.0 * PERIOD;
        float pulse_size = size * (1.0 + 2.0 * texture(texFFTSmoothed, h.z)).r;
        vec3 cell_centre = vec3(adjusted_size * (floor(ray_pos.xy / adjusted_size)), 0.0) + vec3(vec2(PERIOD * size), 0.5 * pulse_size) + vec3(0.0,0.0,0.5*sin(h.r*time));
        //needs to be more blue
      //for shark
      //for memdmp
      //for all weird transfem constructs on the wired
      //more blue
        vec3 relative = ray_pos - cell_centre;
        //test for the sphere in this cell
        float radius = 0.5 * pulse_size;
        float b = dot(relative, ray_dir);
        vec3 qc = relative - b * ray_dir;
        float hypotenuse = radius * radius - dot(qc, qc);
        if (hypotenuse >= 0.0) {
            hypotenuse = sqrt(hypotenuse);
            float t = -b - hypotenuse;
            //if we're not inside a flower, advance to the flower
            if (t > 0.0) {
                ray_pos = ray_pos + t * ray_dir;
              ray_length += t;
                //we can only have hit a sphere
                //there is only shark
                //so let's get teh coordinates on shark
                float u = atan(relative.y, relative.x);
                float v = acos(relative.z);
                uv = vec2(u,v);
                depth += 1;
                float lambertian = dot(normalize(relative),vec3(cos(depth),sin(depth),0.0));
                
                out_color.xyz += vec3(0.4,0.1,0.8)*vec3(lambertian)/ray_length;
                //out_color = vec4(h*vec3(clamp(dot(vec3(1.0,0.0,0.0),relative/size),0.0,1.0)+0.1),1.0);
                break;
            }
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
        }
        
    }
    out_color.xyz= 10.0*out_color.xyz / ray_length;

    vec2 frame_uv = gl_FragCoord.xy / v2Resolution;
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            out_color += texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution - vec2(i, j) * 0.002) / 9.0 * vec4(0.1,0.1,0.1,1.0);
        }
    }

    out_color = tanh(1.5 * out_color);
  }
}