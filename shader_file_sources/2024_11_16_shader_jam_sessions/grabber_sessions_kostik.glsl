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
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
#define BPM 140.
#define INF (1./0.)
#define beat (time*BPM/60.)
#define rep(p,s) (mod(p,s)-s/2.)

float hash(float t) { return fract(sin(t)*45684.56544);}
float hash(vec2 t) { return hash(dot(t, vec2(23.1245,32.256346)));}

mat2 mr(float a) { float c=cos(a),s=sin(a); return mat2(c,s,-s,c);}

vec4 prev(vec2 uv){return texture(texPreviousFrame, fract(uv));}

float rand(vec2 p) {
  vec2 E = vec2(0., 1.);
  vec2 flp=floor(p),frp=fract(p);
  return mix(
    mix(hash(flp+E.xx), hash(flp+E.yx), frp.x),
    mix(hash(flp+E.xy), hash(flp+E.yy), frp.x),
    frp.y
  );
}

float noise(vec2 p) {
  float n=0., a=1.;
  for(float i=0.;i<5.;++i) {
    n += rand(p)*a;
    a *= .5;
    p *= 2.1;
  }
  return n/2.;
}

float box(vec3 p, vec3 s) {
  p = abs(p)-s;
  return max(p.x, max(p.y, p.z));
}

float map(vec3 p) {
  float tt=time;
  tt += .1*hash(dot(p, vec3(12.31241,32.3124,43.23532)));
  p.xy *= mr(tt/4.);
  p.xz += tt*10.;

  vec3  op=p;
  float s=16.;
  float m = INF;
  for(float i=0.;i<3.;++i) {
    p = op;
    vec2 cc = floor(p.xz/16.);
    p.xz = rep(p.xz, s);
    p.y += (hash(cc+i)-.5)*tt*s*1.8;
    p.y = rep(p.y, s*.5);
    m = min(m, box(p, vec3(3, 1, 3)*.03 * s));
    s *= 2.3;
  }
  return m;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float tt = beat/8.;
	vec4 c=vec4(0.);
  {
    if(fract(tt)<.25) {
      uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
      uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
      
      int tex=0;
      if(mod(tt, 2.) < 1.) tex=1;
      if (tex == 0) uv.y *= 2.;
      uv.y += hash(floor(tt));
      uv *= 1.8;
      float fly = floor(uv.y);
      uv.x += time*.5 * (mod(fly, 2.)-.5);
      if(tex==0) c.a += texture(texSessions, uv).r;
      else c.a += texture(texSessionsShort, uv).r;
    } else {
      uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
      vec2 uv1 = uv-.5;
      float n1=noise(4.*uv.yx+.5*time)*2.;
      vec2 off = (vec2(noise(4.*uv+n1), noise(4.*uv+13.5465+n1))-.5)*.002;
      off -= uv1*.002;
      off.x += .001*hash(uv.y);
      vec4 pr = prev(uv+off);
      pr += prev(uv+2.*off);
      pr += prev(uv+8.*off);
      c.a += pr.a/3.;
    }
  }

  bool hit=false;
  {
    uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    
    vec3 O=vec3(0., 0., -1.), D=vec3(uv, .2);
    D.z *= 1.-2.*length(D.xy);
    D = normalize(D);
    float d=0., i;
    for(i=0.;i<16.;++i) {
      vec3 p = O+D*d;
      float m=map(p);
      d += m;
      if(m<.01*d) {
        hit=true;
        break;
      }
    }
  }
  
  {
    uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    if (hit) {
      uv -= .5;
      uv /= 1.5;
      uv += .5;
    }
    vec2 e=vec2(exp(-fract(beat))*.01, .0);
    vec3 pr = vec3(
      prev(uv-e).a,
      prev(uv).a,
      prev(uv+e).a
    );
    c.rgb += pow(pr, vec3(.5, .9, 1.));
  }
  
	out_color = c;
}