#version 410 core

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
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// so distracted making the stream work...

float hash(vec2 uv) {
  vec3 p3 = mod(uv.xyx * vec3(324.34,453.23,345.1),vec3(13,7,5));
  p3 += dot(p3,p3.yzx+34.19);
  return fract((p3.x+p3.y)*p3.z);
}

float n2(vec2 st) {
  vec2 i=floor(st);
  vec2 f = fract(st);
  float tl=hash(i);
  float tr=hash(i+vec2(1,0));
  float bl=hash(i+vec2(0,1));
  float br=hash(i+vec2(1,1));
  vec2 u = f*f*(3-2*f);
  return mix(tl, tr, u.x) + (bl-tl)*u.y*(1-u.x)+(br-tr)*u.x*u.y;
}

float wwid=(2+6*texture(texFFT,0.05).x);

float bloc(vec3 p, vec3 sz) {
  vec3 q = abs(p)-sz;
  return max(q.x,max(q.y,q.z));
}

vec2 min2(vec2 a, vec2 b) {
  return a.x < b.x ? a : b;
}

vec3 cbz(float t) {
  vec3 p0 = vec3(-1,sin(fGlobalTime/5),0);
  vec3 p1 = vec3(0,0.1,0.1);
  vec3 p2 = vec3(0.1,0.0,0.5);
  vec3 p3 = vec3(1,sin(fGlobalTime/7.1),0.1);
  vec3 x= pow (1-t,3)*p0;
  x += pow(1-t,2)*3*t*p1;
  x += (1-t)*3*t*t*p2;
  x+= t*t*t*p3;
  return x;
}

float nearestCbz(vec3 p) {
  float ub=1,lb=0;
  float sln = 1e7;
  for (int i=0; i< 10; ++i) {
    float tq = (ub - lb)/4;
    float t = lb + 2*tq;
    float ts = length(cbz(t+tq) - p);
    float bs = length(cbz(t-tq) -p);
    if (bs < ts) {
      ub = t;
      sln=min (sln,bs);
    } else {
      lb = t;
      sln = min(sln, ts);
    }
    if (sln < 0.01) break;
  }
  return sln;
}

vec2 map(vec3 p) {
  vec2 bubble = vec2(nearestCbz((p+vec3(1,0,5))/6)-0.05,1); //vec2(length(p)-wwid,1);
  vec2 box = vec2(
  bloc(p+vec3(15-mod(fGlobalTime*10,30),sin(floor(fGlobalTime/30)*3.1)*5+2,0),vec3(3.,0.1,3)),2);
  return min2(bubble, box);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

float getNoisy(vec2 wuv) {
  
    wuv *=.2;
    float val=0;
    
    float amp=0.75;
    
    for (int i=1; i < 13; ++i) {
      val += pow(1-n2(i/20+ wuv * 20 / i) / 2 * pow(i,0.25),4)*amp;
      amp *= 0.5;
      wuv *= 4.5;
      //wuv.y += 0.15*(fGlobalTime*amp);
    }
    return val;
  }

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro= vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0;
  vec2 d;
  
  for(int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    if (d.x<0.01) {
      if (d.y != 1) break;
      vec3 n = gn(ro+rd*t);
      ro += rd * t+0.1;
      vec3 nrd = refract(rd,n,1.15);
      if (length(nrd)>0) rd= nrd;
      else rd=reflect(rd,n);
    }
    t += d.x;
  }
  
  vec3 col=vec3(0);
  
  vec3 ld=vec3(-1,0,0);
  
  if (d.x<0.01) {
    vec3 p=ro+rd*t;
    if (d.y ==1) {
      vec2 wuv=vec2(atan(p.x,p.z)+fGlobalTime,atan(p.y,p.z));
    
      float val=getNoisy(wuv);
      col=mix(vec3(0,1,0),vec3(0,0,1),val)*0.5+0.1;
      col=mix(col,vec3(0.7),smoothstep(0.6,0.99,abs(p.y)/wwid));
      col *= 0.6 + dot(gn(p),ld);
    } else if (d.y == 2) {
      
      float val = getNoisy(p.xz*vec2(0.1,1.6));
      col = mix(vec3(0.4,0.2,0.1),vec3(0.2,0.01,0),val)*1.2;
    }
  } else {
    float val=getNoisy(rd.xy+vec2(sin(fGlobalTime/5),0));
    col=mix(vec3(0,0.3,1),vec3(1),val)*0.5+0.1;
    //col *= 0.6 + dot(gn(p),ld);
    }
	out_color = vec4(col,1);
}