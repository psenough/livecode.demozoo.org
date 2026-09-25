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
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 n2(vec2 uv) {
  vec3 p = vec3(uv.x*234.23,uv.y*432.2, (uv.x+uv.y)*234.23);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn(vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f * f * (3 - 2 * f);
  
  float a = n2(p + vec2(0,0)).x;
  float b = n2(p + vec2(1,0)).x;
  float c = n2(p + vec2(0,1)).x;
  float d = n2(p + vec2(1,1)).x;
  
  return a + (b-a)*u.x + (c-a)*u.y + (a - b - c + d)*u.x*u.y;
}

float fbm(vec2 uv) {
  float res = 0;
  float a = 0.5;
  for (int i=0;i < 4; ++i) {
    res += a * vn(uv);
    a *= 0.4;
    uv *= 2;
  }
  return res;
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

float map(vec3 p, out vec4 uvwm) {
  uvwm = vec4(atan(p.x,p.z),p.y,0,1);
  float bol = length(p)-2;
  
  float fl = 2-p.y - fbm(p.xz)*(1-texture(texFFTIntegrated,0.1).x*0.01);
  return fl;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  vec4 ig;
  return normalize(map(p,ig)-vec3(map(p-e.xyy,ig), map(p-e.yxy,ig), map(p-e.yyx,ig)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(0,2,-fGlobalTime-10);
  
  vec3 la = vec3(sin(texture(texFFTIntegrated,0.1).x),-2.1,-fGlobalTime);
  vec3 f = normalize(ro-la);
  vec3 r = cross(f, vec3(0,1,0));
  vec3 u = cross(f,r);
  
  vec3 rd = normalize(f+uv.x*r + uv.y*u);
  
  float d,t=0;
  
  vec4 uvwm;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t, uvwm);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 col = vec3(plas(uvwm.xy/1000,-texture(texFFTIntegrated,0.1).x))*0.4;
  vec3 ld = normalize(vec3(4,-3,2));
  
  if (d<0.01) {
    vec3 n = gn(ro+rd*t);
    col = vec3(plas(uvwm.xy,texture(texFFTIntegrated,0.1).x*1))*dot(ld,n);
  }
  out_color.rgb = col;
}