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

vec2 n2(vec2 uv) {
  vec3 p=vec3(234.43*uv.x,324.23*uv.y,432.2*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p *= dot(p,p+34);
  return fract(vec2(p.x*p.z,p.y*p.z));
}

vec3 erot(vec3 p, vec3 axis, float a) {
  return mix(dot(p,axis)*axis,p,cos(a)) + cross(p,axis)*sin(a);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 sk(vec2 uv) {
  float flt = n2(uv*20).x*0.4;
  return vec3(flt);
}


float map(vec3 p) {
  p/=2;
  float tt = texture(texFFTIntegrated,0.1).x*0.1;
  p.y += 2;
  p.xz = abs(fract(p.xz*.5)*2-1);
  vec3 q = erot(p,vec3(cos(tt),0,sin(tt)), tt*0.43);
  q = abs(q)-1;
  
  vec3 offs = vec3(0.3,0.4,.1);
  float a1=0.56+texture(texFFTSmoothed,0.1).x*4;
  float tn = 1.1+texture(texFFTSmoothed,0.6).x*5;
  vec3 v1 = normalize(vec3(0,cos(tn),-sin(tn)));
  float sc=4.2;
  float amp=1/sc;
  float d=1e7;
  for (int i=0;i<5;++i) {
    q = erot(q,v1,a1);
    
    if(q.x<q.y) q.xy=q.yx;
    if(q.x<q.z) q.xz=q.zx;
    if(q.y<q.z) q.yz=q.zy;
    
    q=q*sc+offs*(1-sc);
    d=min(d,max(q.x,max(q.y,q.z))*amp);
    //d=max(d,-m
    amp /= sc;
  }
  return d+n2(p.xz).x*0.001;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p) - vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(atan(sin(texture(texFFTIntegrated,.1).x)),3+sin(texture(texFFTIntegrated,.1).x),-fGlobalTime);
  vec3 la = ro+vec3(0,-1,-8+sin(texture(texFFTIntegrated,.1).x)*5);
  vec3 f = normalize(la-ro);
  vec3 r = cross(vec3(0,1,0),f);
  vec3 u = cross(f,r);
  vec3 rd = normalize(f*4 + r*uv.x + u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>200) break;
  }
  
  vec3 bgcol=vec3(sk(rd.xy));
  vec3 col;
  
  float lpt1 = texture(texFFTIntegrated,0.345).x;
  vec3 lp1 = ro + vec3(cos(lpt1),3,sin(lpt1)-20);
  
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    vec3 ld1 = normalize(lp1-p);
    col=vec3(20)*dot(ld1,n)/pow(length(lp1-p),2);
  }
  col = mix(bgcol,col,exp(-0.000007*t*t*t));
  out_color.rgb=col;
}