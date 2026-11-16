#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texLynn;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

float TAU = 6.28318530718;

#define fft(x) 2*sqrt(texture(texFFT, x).r)
#define ffti(x)texture(texFFTIntegrated, x).r

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Add(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}
vec3 Read(ivec2 u){       //read pixel from compute texture
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}

vec2 rotate(float theta, vec2 uv)
{
  float c = cos(theta);
  float s = sin(theta);
  
  return vec2(c * uv.x + s * uv.y, -s * uv.x + c * uv.y);
}

// Some useful functions
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float snoise(vec2 v) {

    // Precompute values for skewed triangular grid
    const vec4 C = vec4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,
                        // -1.0 + 2.0 * C.x
                        0.024390243902439);
                        // 1.0 / 41.0

    // First corner (x0)
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    vec2 i1 = vec2(0.0);
    i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - i1;
    vec2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    vec3 p = permute(
            permute( i.y + vec3(0.0, i1.y, 1.0))
                + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(
                        dot(x0,x0),
                        dot(x1,x1),
                        dot(x2,x2)
                        ), 0.0);

    m = m*m ;
    m = m*m ;

    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    // Compute final noise value at P
    vec3 g = vec3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
    return 130.0 * dot(m, g);
}


void main(void)
{
	vec2 screen_uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	screen_uv -= 0.5;
	vec2 ortho_uv = 0.5*screen_uv/vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 square_uv = clamp(ortho_uv*2+0.5,0,1);
  
  
  float r = length(4*ortho_uv);
  
  float theta = atan(ortho_uv.y, ortho_uv.x)/TAU;
  
  float loopDuration = 10.0;
  
  float loop = mod(texture(texFFTIntegrated,0).r, loopDuration)/loopDuration;
  
  float mirrored_theta = mod((theta+loop),1.0);
  mirrored_theta = 2*min(mirrored_theta, 1-mirrored_theta);
  
  float radial_fft = fft(mirrored_theta);
  
  r -= radial_fft;
  
  float outer_ring = 0.6;
  float inner_ring = 0.365;
  float blend_range = 0.005;
   
  float fft_bin = r < outer_ring ? 0.2 : 0.03;
  
  float speed_adjust = r < outer_ring ? -0.5 : 0.2;
  
  float inner_fft_bin = 0.4;
  float inner_speed_adjust = 4;
  
  float outer = smoothstep(inner_ring, inner_ring + blend_range, r);
  
  vec4 lynn = texture(texLynn,clamp(rotate(ffti(0.5),(square_uv-0.5))*4*vec2(1,-1)+0.5+vec2(cos(0.5*ffti(0)),sin(0.2*ffti(0))),0,1));
  
  vec2 noise_uv = ortho_uv * 20 + fGlobalTime * vec2(8, 15);
  
  float multi_octave_noise = snoise(noise_uv) + 0.75 * snoise(noise_uv * 2) + 0.25 * snoise(noise_uv * 4);
  
  float noise = 1.0 - 0.2*fft(0) * multi_octave_noise;
  
  noise += 0.2*(1-lynn.r);
  
  
  vec2 rot_uv_outer = noise * rotate(speed_adjust * ffti(fft_bin),square_uv-0.5)+0.5;
  vec2 rot_uv_inner =  noise * rotate(inner_speed_adjust * ffti(inner_fft_bin), square_uv-0.5)+0.5;
  
  vec4 revision_logo_outer = texture(texRevisionBW,rot_uv_outer);
  vec4 revision_logo_inner = texture(texRevisionBW, rot_uv_inner);
  
  vec4 blended = mix(revision_logo_inner, revision_logo_outer, outer);
  
  mat3 colour_rotator = mat3(  0.9442335,  0.3202702, -0.0764854,
  -0.2533504,  0.8550072,  0.4525220,
   0.2103249, -0.4079089,  0.8884671 );
  
  

  out_color = vec4(r < 1.0 ? 1.0 : 0.0);
  
  out_color *= blended;;
  //out_color *= inner_ring ? vec4(1,0,0,0) : vec4(1);
  
  //out_color *= vec4(rot_uv, 0, 0);
  
  //out_color *= vec4(square_uv-0.5,0,0);
  
  
  vec4 prev_frame = texture(texPreviousFrame, screen_uv * 1.01 + 0.5);
  
  float lynnTime = fGlobalTime;
  
  
  
  //out_color += 0.1*lynn;
  
  out_color += 0.9 * vec4(colour_rotator * prev_frame.xyz, 1);
  
  //out_color = lynn;
  
  vec2 grid = mod(ortho_uv*10*mix(noise,1.0,0.7), 1.0);
  float grid_brightness = max(0.01/grid.x, 0.01/grid.y);
  out_color += 0.1*vec4(grid_brightness);
}