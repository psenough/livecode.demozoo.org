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

vec3 erot(vec3 p, vec3 ax, float a) {
  return mix(ax*dot(p,ax),p, cos(a)) + cross(p,ax)*sin(a);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float boxFr(vec3 p, vec3 b, float e) {
  p = abs(p)-b;
  vec3 q = abs(p+e) -e;
  return min(min(
    length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float map(vec3 p) {
  for (int i=0;i<4;++i) {
  p.x += 2;
  p = erot(p,normalize(vec3(1,.4,0.4)),0.4+0.2*sin(texture(texFFTIntegrated,0.5).x));
  p.x = abs(p.x);
  p = erot(p,normalize(vec3(1,.4,0.4)),0.4);
  p.x -= 2;
  }
  return boxFr(p,vec3(2),0.1);
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 col = plas(plas(uv,1).rg*3,fGlobalTime).rgb*.1;
  for (float i =0;i<3;++i) {
  
  vec3 ro= vec3(cos(i)*10,sin(i)*10,-4*(1+20*mod(i,4)));
    i+= fGlobalTime*0.1;
  vec3 la = vec3(1-1*sin(i),1*cos(i*7),0);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0.,1,0));
  vec3 u = cross(r,f);
  
  vec3 rd=normalize(f*2+r*uv.x+u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100; ++i) {
    d = map(ro+rd*t);
    if (d< 0.01) break;
    t += d;
    if (t>100) break;
  }
  
  col -= plas(uv*8,fGlobalTime*.9).rgb*0.5;
  col -= plas(uv*.14,fGlobalTime*1.5).rgb*0.2;
  if (d<0.01) {
    vec3 p = ro+rd*t;
    col=col.gbr*3;
    col += gn(p)*3;
  }
}
	out_color.rgb=col;
  float ttt = mod(texture(texFFTIntegrated,0.1).x+floor(uv.y+floor(uv.x*4)/4), 3);
  if (ttt >2) out_color.rgb = out_color.gbr;
  if (ttt >1) out_color.rgb = out_color.gbr;
}