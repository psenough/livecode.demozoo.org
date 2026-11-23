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
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float map(vec3 p) {
  
  vec3 ofs = vec3(0,1.2,1.0);
  float a1=.4;
  float a2=1.7;
  float s = 4.;
  float amp = 1/s;
  
  
  p = abs(fract(p*.5)*2 -1);
  
  float d = 1e7;
  
  for (int i=0;i<2;++i) {
    p.xy *= rot(a1);
    p.yz *= rot(fGlobalTime);
    p=abs(p);
  
    p.xy += step(p.x, p.y) * (p.yx - p.xy);
    p.xz += step(p.x, p.z) * (p.zx - p.xz);
    p.yz += step(p.y, p.z) * (p.zy - p.yz);
    p.z *= 1.2;
    p.y += 0.01*s;
    p = p*s + ofs*(1.-s)*.6;
    amp /= s;
    vec3 q = abs(p)*amp-amp; 
    d = min(max(max(q.x,q.y),q.z), d);
    d = min(d,length(p.xz)-1.5);
  }
  return d;
}

vec3 gn(vec3 p) {
  vec2 e= vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec3 uvw = vec3(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y, mod(fGlobalTime/2,2)-1);
  
  
  vec2 uv;
  float time;
  vec3 col = mix(vec3 (0.6,0.7,0.9), vec3(1),uv.y)*10;
  for (int stime = 0; stime < 2; ++stime) {
  if (stime < 1) {
    uv = uvw.xz - 0.5;
    time = sin(uvw.y)*4;
  } else if (stime  < 2) {
    uv = uvw.xy -0.5;
    time = uvw.z;
  } else {
    uv=uvw.yz;
    time = uvw.x-0.5;
  }
  
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float cmag = 10;
  float ctim = sin(fGlobalTime/40)*10;// - texture(texFFTSmoothed,0.1).x*10;
  vec3 ro=vec3(cos(ctim)*cmag,-ctim*10,sin(ctim)*cmag), la = vec3(0,-ctim*10,0);
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f, vec3(0,-1,0));
  vec3 u = cross(f,r);
  
  vec3 rd = normalize(f*2+r*uv.x+u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map (ro+rd*t);
    
    if (d<0.01) break;
    t += d;
    if (t>100) break;
    
  }
  
  vec3 bgcol=col;
  col = col.zxy *vec3(0.1,0.2,0.5)*.1;
  
  float lt = texture(texFFTIntegrated,0.1).x;
  
  float lmag = 10+sin(texture(texFFTIntegrated,0.6).x*5)*5;
  vec3 lo = vec3(sin(lt)*lmag, 0, cos(lt)*lmag);
  vec3 p = ro+rd*t;
  vec3 ld = normalize(lo-p);
  float li = exp(-length(lo-p)*0.3);
  vec3 ncol = col;
  if (d<0.01) {
    vec3 n = gn(ro+rd*t);
    
    col += 40*plas(floor(p.xz/2)*2,fGlobalTime).rgb*dot(n,ld)*li;
    col = mix(col,bgcol,pow(1+dot(rd,n),4));
  }
  
  col = mix(ncol,col,exp(-t*t*t*0.00001))*2;
}
  col = mix(col,vec3(0), pow(length(uv),2));
  col = pow(col,vec3(0.45454));
  out_color.rgb=col;
}