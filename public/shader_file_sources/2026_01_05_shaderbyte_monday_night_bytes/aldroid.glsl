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
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float dfpa=1000;
void setD(ivec2 idx, float t) {
  int quant_val = int(t * dfpa);
  imageStore(computeTex[0], idx, ivec4(quant_val));
}

float getD(ivec2 idx) {
  return float(imageLoad(computeTex[0],idx).x)/dfpa;
}

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25);
}

vec3 pal(float v) {
  return plas(vec2(0.79,16.1),v*4-1.3);
}

float map(vec3 p) { 
  vec3 q = p;
  q.y +=.5;
  q.x = abs(q.x);
  q.x -= 1.5;
  q.z = mod(q.z,8)-4;
  q.y = q.y + sin(fGlobalTime+p.z);
  return length(q)-1;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy), map(p-e.yyx)));
}

vec3 sk(vec2 uv) {
  float sk = texture(texNoise,uv).x;
  sk *= sk;
  return vec3(1-pal(sk))*0.4+.4;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float ms = fGlobalTime * 10;
  vec3 ro=vec3(sin(fGlobalTime)*3,cos(fGlobalTime*.9)*.5+4,ms-20+sin(texture(texFFTIntegrated,.1).x*10));
  vec3 la=vec3(0,0,ms);
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(r,f);
  vec3 rd = normalize(f*2+r*uv.x+u*uv.y);
  
  float ft = fGlobalTime * sign(sin(texture(texFFTIntegrated,0.5).x*2));
  
  float t=0, d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 bgcol = pal(texture(texNoise,rd.xy*vec2(0.001,1)).x)*.4+.3;
  bgcol = mix(bgcol,sk(rd.xy),smoothstep(0.1,0.11,rd.y + texture(texNoise,vec2(0,rd.x)).x));
  bgcol = mix(bgcol,vec3(0), smoothstep(-.3,-.5,rd.y));
  bgcol = mix(bgcol,vec3(1,1,.7),smoothstep(0.13,0.03,length(rd.xy)));
  vec3 col = bgcol;
  
  vec3 ld=normalize(vec3(3,2,-1));
  
  if (d<0.01) {
    col = pal(3+uv.x+ft);
    float clt = dot(ld,gn(ro+rd*t));
    col *= 0.6 + 0.4*floor(clt*5)/5;
    col *= 1.21;
  }
  out_color.rgb = col;
  ivec2 cell=ivec2(gl_FragCoord.xy);
  setD(cell, t);
  
  float dgn = 0;
  
  int st = 4;
  for (int x=-1;x<=1;++x) for (int y=-1;y<=1;++y) {
    if (x==0 && y==0) continue;
    dgn = max(dgn,getD(cell+ivec2(x*st,y*st)));
  }
  //dgn /= 8;
  if (t<40) {
    col=mix(col,vec3(0),smoothstep(.4,1.2, abs(dgn-getD(cell))));
  }
  
  col = mix(bgcol, col, exp(-0.000001*t*t*t));
  
  col = mix(vec3(0),col,smoothstep(1.1,0.85,length(uv)));
  
  col += texture(texNoise,uv).x*0.1;
  out_color.rgb = col;
  
}