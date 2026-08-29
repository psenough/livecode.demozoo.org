#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texLogo;
uniform sampler2D texLogoBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define INF (1./0.)
#define mr(t) (mat2(cos(t), sin(t), -sin(t), cos(t)))
#define time fGlobalTime
#define beat (time/60.*130.)

float hash(float t) {return fract(sin(t)*45562.5648);}

float box(vec3 p,vec3 s) {
  p = abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

vec3 ct(vec3 p) {
  if(p.x<p.y) p.xy=p.yx;
  if(p.y<p.z) p.yz=p.zy;
  if(p.x<p.y) p.xy=p.yx;
  return p;
}

float fig(vec3 p, float ii) {
  vec3 s1 = vec3(.1, .05,.08);
  for(float i=0.;i<3.;++i) {
    
    if(i==0.) {
      p.xz *= mr(.34 + (hash(ii+1.)-.5)*(floor(beat) + smoothstep(0., .2, fract(beat))));
    }
    p.xz *= mr(.34+time*.3 + hash(ii+i));
    p.yz *= mr(.27+time*.2+ hash(ii+1.));
    p = p.yzx;
    p = abs(p)-s1;
  }
  
  float m = INF;
  m = min(m, box(p, vec3(.1)));
  
  vec3 s = vec3(.2);
  float m1 = max(box(p, s), -box(ct(abs(p)), vec3(INF, s.xy)-.02));
  
  return min(m, m1);
}

vec3 glow=vec3(0.);

float map(vec3 p) {
  float m=INF;
  float m1=fig(p-1.6*vec3(sin(time*vec3(.2,.3,.6))), 0.);
  float m2=fig(p-1.5*vec3(sin(time*vec3(.3,.5,.1))), 1.);
  float m3=fig(p-.7*vec3(sin(time*vec3(.4,.2,.8))), 2.);
  glow += vec3(1.,1.3,1.5)*.001/(m1+.01) * exp(-fract(beat)*3.);
  glow += vec3(1.,1.3,1.5).bgr*.001/(m2+.01) * exp(-fract(beat+.2)*3.);
  glow += vec3(1.,1.3,1.5).grb*.001/(m3+.01) * exp(-fract(beat+.4)*3.);
  m = min(m, m1);
  m = min(m, m2);
  m = min(m, m3);
  
  return m;
}

vec3 norm(vec3 p) {
  vec2 E = vec2(.001, .0);
  return normalize(vec3(
    map(p+E.xyy),map(p+E.yxy),map(p+E.yyx)
  ) - map(p));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 c=vec3(0.);
  vec3 O=vec3(0.,0.,-3.),D=vec3(uv, 1.);
  float d=0.;
  bool hit = false;
  for(float i=0.;i<64.;++i) {
    vec3 p=O+D*d;
    float m=map(p);
    d += m;
    if(m< .001*d) {
      hit=true;
      break;
    }
  }
  if(hit) {
    vec3 n = norm(O+D*d);
    c += exp(-d*.3) * max(0., dot(n, -D));
  } else {
    uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    
    uv.y += 0.5*sin(uv.x*.5+time);
    vec2 cell = floor( uv* 4.);
    uv = fract(uv*4.);
    uv.y = 1.-uv.y;
    if(true) {
      vec3 tex = mix(
        texture(texLogo, uv).rgb,
        texture(texLogoBW, uv).rgb,
        step(hash(cell.x+floor(beat)), fract(time+dot(uv, vec2(1.))))
      );
      c += tex*.5;
    }
  }
  
  c += glow;

	out_color = vec4(c, 0.);
}