#version 420 core

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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float n1(vec2 uv) {
  return texture(texNoise,uv).x;
}

float fbm(vec2 uv) {
  float res=0;
  float a=0.5;
  for (int i=0;i<3;++i) {
    res += n1(uv);
    uv *= 2;
    a *=0.4;
  }
  return res;
}
    

float map(vec3 p, out int mat) {
  float res = p.y+2-2*fbm(p.xz/100)*(1+texture(texFFT,0.1).x*3);
  mat = 1;
  float sl = p.y +0.9;
  if (sl < res) {
    res = sl;
    mat = 2;
  }
  return res;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  int m;
  return normalize(map(p,m) - vec3(map(p-e.xyy,m),map(p-e.yxy,m),map(p-e.yyx,m)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float alt = texture(texFFTIntegrated,0.1).x*5-fGlobalTime*1-texture(texFFT,0.1).x*10;
  alt *= 2;

  vec3 ro=vec3(cos(alt*0.01)*3,2,alt);
  vec3 la = vec3(0,-2+sin(fGlobalTime),alt+10);
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f, vec3(0,1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f+uv.x*r-uv.y*u);
  
  float t=0,d;
  
  int mat;
  float reflects = 0;
  
  for(int i=0;i<100;++i) {
    d = map(ro+rd*t,mat);
    if (d<0.01) {
      if (mat == 2) {
        ro = ro+rd*t;
        rd = reflect(rd, gn(ro));
        t = 0.01;
        reflects = 1;
      } else {
        break;
      }
    }
    t+=d;
    if (t > 100) break;
  }
  vec3 bgcol = vec3(0.4,0.6,0.99);
  bgcol = mix(bgcol,vec3(0.97),smoothstep(0.1,-0.1,rd.y));
  
  float clouds = fbm(rd.xy+vec2(alt*0.05,0))*clamp(rd.y*4,0,1);;
  clouds += fbm(rd.xy*vec2(0.1,0.5)+vec2(alt*0.01,0))*clamp(1+rd.y*4,0,1);
  bgcol += clouds*0.1;
  
  vec3 col = bgcol;
  
  vec3 ld = normalize(vec3(-1,2,3));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    col = vec3(1);
    col = mix(col, vec3(0.045,0.6,0.2)*0.6, smoothstep(.5,-1.2,p.y));
    col = mix(col, vec3(0.6,0.2,0.22)*0.3, smoothstep(-2.2,-2.6,p.y));
    col = col*dot(ld,n);
    col += pow(max(dot(reflect(ld,n),-rd),0),30)*vec3(1,1,0);
  }
  
  col = mix(bgcol, col, exp(-0.00005*t*t*t));
  
  out_color.rgb = col;
}