#version 430 core

//advection along a curl field

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

// http://www.jcgt.org/published/0009/03/02/
vec3 hash(uvec3 v) {

    v = v * 1664525u + 1013904223u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return vec3(v) * (1.0/float(0xffffffffu));
}

//borrowing noise with derivatives from Inigo Quilez
//https://www.shadertoy.com/view/4dffRH
//thanks Inigo we would be nowhere without you <3
vec4 noised( in vec3 x )
{
  // grid
  uvec3 i = uvec3(floor(x));

  vec3 f = fract(x);
  
  // quintic interpolant
  vec3 u = f*f*f*(f*(f*6.0-15.0)+10.0);
  vec3 du = 30.0*f*f*(f*(f-2.0)+1.0);  
  
  // gradients
  vec3 ga = hash( i+ivec3(0,0,0) );
  vec3 gb = hash( i+ivec3(1,0,0) );
  vec3 gc = hash( i+ivec3(0,1,0) );
  vec3 gd = hash( i+ivec3(1,1,0) );
  vec3 ge = hash( i+ivec3(0,0,1) );
vec3 gf = hash( i+ivec3(1,0,1) );
  vec3 gg = hash( i+ivec3(0,1,1) );
  vec3 gh = hash( i+ivec3(1,1,1) );
  
  // projections
  float va = dot( ga, f-vec3(0.0,0.0,0.0) );
  float vb = dot( gb, f-vec3(1.0,0.0,0.0) );
  float vc = dot( gc, f-vec3(0.0,1.0,0.0) );
  float vd = dot( gd, f-vec3(1.0,1.0,0.0) );
  float ve = dot( ge, f-vec3(0.0,0.0,1.0) );
  float vf = dot( gf, f-vec3(1.0,0.0,1.0) );
  float vg = dot( gg, f-vec3(0.0,1.0,1.0) );
  float vh = dot( gh, f-vec3(1.0,1.0,1.0) );

  // interpolations
  float k0 = va-vb-vc+vd;
  vec3  g0 = ga-gb-gc+gd;
  float k1 = va-vc-ve+vg;
  vec3  g1 = ga-gc-ge+gg;
  float k2 = va-vb-ve+vf;
  vec3  g2 = ga-gb-ge+gf;
  float k3 = -va+vb+vc-vd+ve-vf-vg+vh;
  vec3  g3 = -ga+gb+gc-gd+ge-gf-gg+gh;
  float k4 = vb-va;
  vec3  g4 = gb-ga;
  float k5 = vc-va;
  vec3  g5 = gc-ga;
  float k6 = ve-va;
  vec3  g6 = ge-ga;
  
  return vec4( va + k4*u.x + k5*u.y + k6*u.z + k0*u.x*u.y + k1*u.y*u.z + k2*u.z*u.x + k3*u.x*u.y*u.z,    // value
               ga + g4*u.x + g5*u.y + g6*u.z + g0*u.x*u.y + g1*u.y*u.z + g2*u.z*u.x + g3*u.x*u.y*u.z +   // derivatives
               du * (vec3(k4,k5,k6) + 
                     vec3(k0,k1,k2)*u.yzx +
                     vec3(k2,k0,k1)*u.zxy +
                     k3*u.yzx*u.zxy ));
}
  
float advect(ivec2 UV, ivec2 vel) {
  uint s = imageLoad(computeTexBack[0], UV).r;
  if (s>2) {
    imageAtomicAdd(computeTex[0], UV+vel, s/5);
  }
  return float(s)/(6*256.0);
}
  
void main(void) {
  float fftTime = 0.4*texture(texFFTIntegrated, 0.1).x;
  float fft = texture(texFFTSmoothed, 0.2).x;
  //float fft = 0.0;
  vec4 n_up = noised(vec3((10.0)*gl_FragCoord.xy/(v2Resolution.y),fftTime));
  vec4 n_down = noised(vec3((10.0)*gl_FragCoord.xy/(v2Resolution.y),-fftTime));
  vec3 curl = cross(n_up.yzw, n_down.yzw);
  
  ivec2 UV = ivec2(gl_FragCoord.xy);
  vec2 uv =2.0*gl_FragCoord.xy/v2Resolution.y - vec2(v2Resolution.x/v2Resolution.y,1.0);
  float s = 0.0;
  ivec2 vel = ivec2(curl.xy * 10.0);
  s = advect(UV, vel)+advect(UV, vel+ivec2(1,1))+advect(UV, vel-ivec2(1,1))+advect(UV, vel+ivec2(-1,1))+advect(UV, vel+ivec2(1,-1));
  if (dot(uv, uv) < fft) {
    imageStore(computeTex[0], UV, uvec4(128));
    //s+=0.2;
  }
  //s = step(dot(uv, uv),0.25);
  
  vec3 previous_frame;
  for(int i = -1; i<=1; i++) {
    for(int j = -1; j<=1; j++) {
      previous_frame += texture(texPreviousFrame, 0.98*(gl_FragCoord.xy + vec2(i,j))/v2Resolution + vec2(0.01)).xyz;
    }
  }  
  
  out_color = vec4(vec3(s)+vec3(0.04,0.08,0.10)*previous_frame+vec3(0.01,0.01,0.001)*previous_frame.yzx,1.0);
  //out_color = vec4(n_up);
}