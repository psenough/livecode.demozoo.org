#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

float fft = texture(texFFTIntegrated, 0.25).r;
const float PI = 3.14159265;

vec3 glow = vec3(0.0);


//SOME FUNCTIONS FROM HG_SDF

// Sign function that doesn't return 0
float sgn(float x) {
	return (x<0.0)?-1.0:1.0;
}

float fOpUnionSoft(float a, float b, float r) {
	float e = max(r - abs(a - b), 0.0);
	return min(a, b) - e*e*0.25/r;
}

//https://www.shadertoy.com/view/tdS3DG
float fEllipsoid( vec3 p, vec3 r ){
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float pupu(vec3 p){
  vec3 pp = p;
  float paa = sphere(p, 1.0);
  pp -= vec3(0.0, 1.0, 0.0);
  pp = abs(pp)-vec3(0.7, 0.0, 0.0);
  float korvat = fEllipsoid(pp, vec3(0.3,0.95,0.2));
  
  pp = p - vec3(0.0, -0.05, 0.99);
  float nena = sphere(pp, 0.15);
  paa = fOpUnionSoft(paa, nena, 0.04);
  
  pp = p-vec3(0.0, 0.1, 0.8);
  pp.x = abs(pp.x)-0.5;
  float silmat = sphere(pp, 0.12);
  paa = min(paa, silmat);
  
  return fOpUnionSoft(paa, korvat, 0.1);
}

float scene(vec3 p){
  vec3 pp = p;
  rot(pp.xz, time);  
  pp.xz = abs(pp.xz)-vec2(3.0, 3.0);
  rot(pp.xz, (time*135.0)/60.0);
  rot(pp.xy, fft);
  rot(pp.yx, fft + (time*135.0)/60.0);
  
  //pp = p;
  for(int i = 0; i < 8; ++i){
    pp = abs(pp)-vec3(0.2, 0.0, 0.5);
    rot(pp.xz, time);
    rot(pp.xy, fft);
    rot(pp.yx, (time*135.0)/60.0);
  }
  float puput = pupu(pp);
  float beams = box(pp, vec3(0.1, 0.1, FAR*2.0));
  beams = max(beams, 0.5);
  float spheres = box(pp, vec3(0.1, FAR, 0.1));
  spheres = max(spheres, 0.5);
  
  vec3 g = vec3(0.8, 0.1, 0.8) * 0.05 / (abs(beams) + 0.01);
  g += vec3(0.0, 0.0, 0.5) * 0.01 / (abs(puput) + 0.2);
  g += vec3(0.1, 0.3, 0.8) * 0.05 / (abs(spheres) + 0.01);
  
  g *= 0.333;
  glow += g;
  
  return max(puput, min(beams, spheres));
}


float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t +=d;
    p = ro + rd * t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  return t;
}

//calculate normals for objects
vec3 normals(vec3 p){
  vec3 eps = vec3(E, 0.0, 0.0 );
  return normalize(vec3(
    scene(p+eps.xyy) - scene(p-eps.xyy),
    scene(p+eps.yxy) - scene(p-eps.yxy),
    scene(p+eps.yyx) - scene(p-eps.yyx)
  ));
}

vec3 shade(vec3 p, vec3 rd, vec3 ld){
  vec3 n = normals(p);
  
  float l = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(ld, n), rd), 0.0);
  float s = pow(a, 20.0);
  
  return l*vec3(0.2, 0.1, 0.8)+s*vec3(0.5, 0.4, 0.6);
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = uv - 0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0.0, -0.5, 10.0);
  vec3 rt = vec3(0.0, 1.0, -FAR);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x, y, z) * vec3(q, 1.0/radians(60.0)));
  
  vec3 col = vec3(0.0);
  float t = march(ro, rd);
  vec3 p = ro + rd * t;
  
  if(t < FAR){
    col = shade(p, rd, -rd);
  }
  col += glow;

	out_color = vec4(col, 1.0);
}