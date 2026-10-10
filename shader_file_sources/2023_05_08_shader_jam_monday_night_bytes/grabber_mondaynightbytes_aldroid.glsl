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

float map(vec3 p) {
  return length(p)-wwid;
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro= vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  
  for(int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    if (d<0.01)break;
    t += d;
  }
  
  vec3 col=vec3(0);
  
  vec3 ld=vec3(-1,0,0);
  
  if (d<0.01) {
    vec3 p=ro+rd*t;
    vec2 wuv=vec2(atan(p.x,p.z)+fGlobalTime,atan(p.y,p.z));
  
    wuv *=.2;
    float val=0;
    
    float amp=0.75;
    
    for (int i=1; i < 13; ++i) {
      val += pow(1-n2(vec2(0,fGlobalTime)*i/20+ wuv * 20 / i) / 2 * pow(i,0.25),4)*amp;
      amp *= 0.5;
      wuv *= 4.5;
      //wuv.y += 0.15*(fGlobalTime*amp);
    }
    
    col=mix(vec3(0,1,0),vec3(0,0,1),val)*0.5+0.1;
    col=mix(col,vec3(0.7),smoothstep(0.6,0.99,abs(p.y)/wwid));
    col *= 0.6 + dot(gn(p),ld);
  } else {
    col = texture(texPreviousFrame,(uv*vec2(0.4,0.9)*1.2)+0.5).rgb*0.8;
  }
	out_color = vec4(col,1);
}