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

mat2 rot(float a) {
  return mat2(cos(a),-sin(a), sin(a), cos(a));
}

float plas( vec2 v, float time )
{
	return clamp(sin(v.x + cos(v.y*2+time*0.9))+cos(v.y+3*sin(time*0.1)),0,1);
}

float map(vec3 p) {
  p.xz = mod(p.xz+4,vec2(8))-4;
  return length(p)-2-texture(texFFT,0.1).x*100;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ruv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float ft1 = fGlobalTime*10;
  vec3 ro= vec3(0,7,ft1-10);
  vec3 la = vec3(5*sin(ft1/10),2,ft1+10);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,-1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f + r*uv.x + u * uv.y);
  
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (d>100)break;
  }
  
  vec3 col=mix(vec3(0.9,0.9,0.8),vec3(0.5,0.5,0.9),smoothstep(0.2,.6,uv.y));
  vec3 ld = normalize(vec3(3,2,-2));
  if (d < 0.01) {
    vec3 n = gn(ro+rd*t);
    col = vec3(0,0.,0) + vec3(0,0,1)*dot(ld,n);
    col += vec3(0.5,1,0.5)*clamp(pow(max(dot(reflect(-ld,n),-rd),0),30),0,1);
  }
  
  float gttt = 0;
  for (int i=0;i<45;++i) {
    float ttt = plas(uv*rot(0.7)*vec2(0.4,5)
    ,fGlobalTime+i);
    ttt = fract(ttt*5)-0.5;
    ttt = smoothstep(0.3,0.1,abs(ttt));
    gttt += ttt;
  }
  gttt /= 4;
  
  col = vec3(1)*smoothstep(0.2,.8,length(col))+col*0.3;
  
  col *= 0.5+gttt*0.5;
  
  vec2 rof = vec2(cos(fGlobalTime*0.7),sin(fGlobalTime*0.6));
  ruv -= rof*0.5;
  rof*=rot(sin(fGlobalTime)*.009);
  ruv += rof *0.5;
  
  //col = -vec3(0.9,0.9,0.8)+col*4;
  
  col = col*0.2 + texture(texPreviousFrame,ruv).rgb*0.9+vec3(0.4,0.4,0.8)*0.01-texture(texNoise,uv*10).xxx*(0.09);
	out_color.rgb = col;
}