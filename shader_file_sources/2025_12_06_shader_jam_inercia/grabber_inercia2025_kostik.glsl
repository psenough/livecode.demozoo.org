#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 getTexture(sampler2D sampler, vec2 uv){
    vec2 size = textureSize(sampler,0);
    float ratio = size.x/size.y;
    return texture(sampler,uv*vec2(1.,-1.*ratio)-.5);
}

#define PI 3.14159265
#define rep(p,s) (mod(p,(s))-(s)/2.)
#define rep2(p,s) (abs(rep(p,2.*(s)))-(s)/2.)
#define time fGlobalTime
#define beat (time * 120./60.)

float hash(float t) {return fract(sin(t)*45561.2121351);}
float hash(vec2 t) {return hash(dot(t, vec2(13.4134,21.31244)));}

mat2 mr(float a) {float c=cos(a),s=sin(a); return mat2(c,s,-s,c);}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y, p.z));
}

float map(vec3 p) {
  p.z += time*.02;
  float t1 = beat/2.;
  t1 = floor(t1)+pow(fract(t1), .3);
  p.xz *= mr(PI/4.+t1*.1);
  p.yz *= mr(PI/6.);
  p.xy *= mr(PI/6.);
  vec3 s=vec3(mix(1., 2.5, hash(floor(beat/8.))));
  float m=1e10;
  for(float i=0.; i<5.; ++i) {
    s *= .57;
    float ph1;
    if(i==0.) ph1 = t1*.01;
    s.xz *= mr(.27+ph1);
    s.yz *= mr(.35);
    s=abs(s);
    p = rep2(p, 3.79*s);
    m = min(m, box(p, s));
  }
  return m;
}

vec3 norm(vec3 p) {
  vec2 e=vec2(.001, 0.);
  return normalize(vec3(
    map(p+e.xyy),
    map(p+e.yxy),
    map(p+e.yyx)
  )-map(p));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 c;
  for(float i=0.; i<8.; ++i) {
    vec3 p=vec3(uv*.5, i/32.);
    p.xy *= (1.+i/8.);
    p.xy *= mr(i*.1*sin(time/16.));
    p.xy *= (1.+length(p.xy));
    float m=map(p);
    float h=hash(uv + time + i);
    p.x += .01*(h-.5) * mix(0., 1., 200.*abs(m));
    m=map(p);
    m /= norm(p).z;
    vec3 col=vec3(.1),powa = vec3(1.2)-.5*exp(-fract(beat));
    
    float m1=map(p*.7-vec3(1.21, 2.,3.));
    col *= m1>0.?0.2: 1.;
    
    vec2 tuv=(1.-.1*exp(-fract(beat)))*(p.xy)*mr(.3*sin(time*.2))+vec2(time*.2, 0.);
    tuv.y += .05*sin(time + p.x);
    
    col += 5.*getTexture(texInercia2025, tuv).rgb;
    vec3 c1;
    c1 += pow(col * .0006 / abs(m), powa);
    c1 += pow(col * .0001/abs(m), powa/3.) * step(m, 0.) *
      smoothstep(-.5, .5, sin(time + 500.*dot(uv, vec2(1./sqrt(2.)))));
    c += c1 * exp(-i*.6) * (cos(6.*h + vec3(0., 2., 4.))*.5+.5);
  }
  c = sqrt(c)*.8;
	out_color = vec4(c, 1.);
}