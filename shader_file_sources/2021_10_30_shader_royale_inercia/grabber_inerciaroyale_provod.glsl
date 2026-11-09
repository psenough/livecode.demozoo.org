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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float t = fGlobalTime;
#define pi 3.1415927
#define TT(t,v) texture(t, ((v)+.5)/textureSize(t,0))
float fft(float f){return TT(texFFT,f).r;}
float ffts(float f){return TT(texFFTSmoothed,f).r;}
float ffti(float f){return TT(texFFTIntegrated,f).r;}
#define rep(v,s) (mod(v,s)-(s)*.5)
float hash(float f){return fract(sin(f)*54353.42347);}
mat2 rot(float a){return mat2(cos(a),sin(a),-sin(a),cos(a));}

vec3 circ(vec2 uv, float h) {
  float r=length(uv);
  float a=atan(uv.x,uv.y);
  a/=pi;a+=1.;
  a+=2.;
  float f = 4. * ffts(floor(a*(5. + 50. * hash(h))));
  r -= f;
  
  float mask = step(abs(r-.3), .1);
  float masz = .2 * hash(h+.1);
  mask *= step(mod(a + sin(t),.1+masz),.04+.1*masz);
  
  return mix(vec3(.1,.2,.3),vec3(.5,.2,.3),min(f*40., 3.)) * mask;
}

vec3 dots(vec2 p) {
  //p = fract(p) - .5;
  p = rep(p,vec2(.2));
  return vec3(.1,.4,.6) * step(length(p), .01);
}

vec3 plane(float O, float D, float S, vec2 ouv, vec2 duv, float n) {
  float l = (S - O) / D; if (l < 0.) return vec3(0.);
  vec2 uv = ouv + duv * l;
  
  if (n == 1.)
     uv.y += floor(t) + pow(fract(t), 2.);
  
  float xoffc = floor(uv.y);
  float xoffp = t * (.2 - 1. * sin(2. * pi * hash(xoffc+.3))) + hash(xoffc);
  //xoffp = 
  float xoff = floor(xoffp/2.)*2. + 2. * pow(fract(xoffp), 3.);
  uv.x += xoff;
  
  vec2 pc = floor(uv);
  vec2 p = fract(uv) - .5;
  
  vec3 c = vec3(0.);
  
  c += circ(p*1.5, hash(pc.x*.18+pc.y*34.)) * 4.;
  
  //c += vec3(.1, .2, .3) * step(length(p), .1);
  c += dots(uv) * 4.;
  
  //c +
  
  return c / l;
}


void main(void) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.);
  
  float seed = uv.x*45.43278 + uv.y*17.643 + t*3.4;

  float foc = 6.;
  float fov = 1./2.;
  float ls = .05;

  const int NS = 16;
  float tt = fGlobalTime * 130./120.;
  for(int si = 0; si < NS; ++si) {
    seed = fract(seed);
    vec3 O,D;

    t = tt + hash(seed+=.01) * .03;
    vec2 dp = vec2(hash(seed+=.1), hash(seed+=.2));
    
    vec3 at = vec3(uv, fov) * foc;
    O = vec3(dp * ls, 0.);
    D = normalize(at - O);
    
    vec3 S=vec3(1., 1.1, 10.), DS=vec3(2.);
    //O += vec3(.1 + .4*sin(t*.17 + ffti(.3)*.1), .4, 5.);
    
    float tp = t / 2.;
    float tc = floor(tp);
    float tct = /*1. -*/ pow(fract(tp), 1.);
    
    vec3 o0 = S * .9 * (1. - 2. * vec3(hash(tc   ),hash(tc+ .1),hash(tc+ .2)));
    vec3 o1 = S * .9 * (1. - 2. * vec3(hash(tc+1.),hash(tc+1.1),hash(tc+1.2)));

    O += mix(o0, o1, tct);
    
    
    D.xz *= rot(-.3 + .2 * (1. - 2. * mix(hash(tc+.3), hash(tc+1.3), tp)));
    D.yz *= rot(-.2 + .3 * (1. - 2. * mix(hash(tc+.5), hash(tc+1.5), tp)));
    D.xy *= rot(-.1 + .4 * (1. - 2. * mix(hash(tc+.6), hash(tc+1.6), tp)));
    //D.yz *= rot(-.2);


    S *= sign(D);
    DS *= sign(D);
    
    //C += circ(uv);
    for (float ip = 0.; ip < 2.; ++ip, S+=DS) {
      C += plane(O.y, D.y, S.y, O.xz, D.xz, 0.);
      C += plane(O.x, D.x, S.x, O.yz, D.yz, 1.);
      C += plane(O.z, D.z, S.z, O.xy, D.xy, 2.);
    }
  }
  
  C /= float(NS);
  
	out_color = vec4(sqrt(C), 0.);
}