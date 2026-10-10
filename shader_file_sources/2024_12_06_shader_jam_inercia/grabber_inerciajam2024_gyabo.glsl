#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


float beat;

float map(vec3 p) {
//  return length(mod(p, 2.0) - 1.0) - 0.5;
  vec4 base = texture( texInerciaLogo2024, mod(-p.xz * 0.1, 1.0));
  vec4 agsadt = texture( texInerciaLogo2024, mod(-p.xz * 0.1, 1.0));
  float x = sin(p.x);
  float y = (p.y);
  float z = sin(p.z);
  vec3 ip = p * 24.0;
  float r = cos(x) + cos(y) + cos(z);
  r -= cos( cos(ip.x) * cos(ip.y) * cos(ip.z) ) * 0.5 ;
  r -= sin( cos(ip.x) * cos(ip.y) * cos(ip.z) )  * 0.5 + beat / 100.0;
  vec3 ap = p;
  ap.x += cos(p.z) * ap.x * sin(fGlobalTime);
  ap.z += sin(p.z) * ap.z * cos(fGlobalTime);
  
  r = min(r, length(mod(ap.xz + 0.2, 2.0) - 1.0) - 0.05);
  r = min(r, length(mod(ap.zy + 2.4, 2.0) - 1.0) - 0.05);
  r = min(r, length(mod(ap.xy + 1.7, 2.0) - 1.0) - 0.05);
  r = min(r, 0.01 * beat + base.z * base.x + 1.5 - dot(abs(p), vec3(0.0, 1.0, 0.0)));
  return r;
  
  
}

vec2 rot(vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  return vec2(
    p.x * c - p.y * s,
    p.x * s + p.y * c);
}

vec3 getnor(vec3 p) {
  float t = map(p);
  vec2 d = vec2(0.01, 0.0);
  return normalize(vec3(
    t - map(p + d.xyy),
    t - map(p + d.yxy),
    t - map(p + d.yyx)));
}


float raycast(vec3 eye, vec3 dir, float th) {
  float dt = 15.0;
  float t = 0.0;
  for(int i = 0 ; i < 175 && dt > 0.01; i++) {
    vec3 temp = eye  + dir * t;
    if(map(temp) < th) {
        t - dt;
      dt *= 0.1;
    }
    t += dt;
  }
  return t;
}

void main(void)
{
  vec2 auv = vec2(2.0 * gl_FragCoord.xy - v2Resolution.xy) / min(v2Resolution.x, v2Resolution.y);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

  vec3 pos = vec3(fGlobalTime * 1.0, 0, fGlobalTime * 3.0);
  vec3 dir = normalize(vec3(auv, 1.0));
  float at = smoothstep(0.25, 0.75, fract(fGlobalTime) * (138.0 / 60.0));
  float mt = floor(fGlobalTime * (138.0 / 60.0));
  
  dir.xz = rot(dir.xz, fGlobalTime * 0.02);
  dir.zy = rot(dir.zy, fGlobalTime * 0.02);
  //dir.xz = rot(dir.xz, mt + at);
  //dir.zy = rot(dir.zy, mt + at);
  
  dir /= 1.0;
  float t = 0.0;

  for (int i = 0; i < 170; i++) {
      t += map(pos + dir * t);
  }
  //t = raycast(pos, dir, 0.7);

  vec3 ip = pos + dir * t;
  vec3 N = getnor(ip);
  vec3 light = normalize(vec3(1.0, -0.5, 1.0));
  float normal = dot(light, N);
  
  beat = 0.5 * texture( texFFT, uv.x ).r * 100 + 1;
  vec4 base = texture( texInerciaLogo2024, uv * vec2(1.0,-1.0) );
  vec4 iro = vec4(vec3(2.0, 1.0, 5.5) * normal, 1);
  out_color = beat * iro * getnor(ip).xyzz * 1.0 + t * 0.01 * vec4(5.0, 3.0, 1.0, 1.0);
}