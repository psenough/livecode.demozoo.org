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

float t=fGlobalTime;

#define T(t,v) texture(t, (v+.5)/textureSize(t,0))
#define fft(v) T(texFFT, v).r
#define ffts(v) T(texFFTSmoothed, v).r
#define ffti(v) T(texFFTIntegrated, v).r

#define h1(a) fract(sin(a)*54839.4328)
#define h2(v) h1(dot(v,vec2(17.342,347.3217)))

float vmax(vec3 p){return max(max(p.x,p.y),p.z);}
float vmax(vec2 p){return max(p.x,p.y);}
#define B(p,s) vmax(abs(p)-s)
#define R(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define rep(v,s) (mod(v,s)-s*.5)

float xfld(vec3 p) {
  vec2 e=vec2(1.,.01)*.07;
  //p.z += t*.8 + ffti(5.);
  p = rep(p, vec3(1.6));
  return min(min(
    B(p,e.xyy),
    B(p,e.yxy)),
    B(p,e.yyx));
}

float w(vec3 p) {
  vec3 pp = p;
  float d = p.y + 0.3;
  
  vec2 c = floor(p.xz);
  vec2 pc = fract(p.xz) - .5;
  p.xz = pc;
  float r1=h2(c), r2=h2(c+.1), r3=h2(c+.3);
  
  vec3 sz = vec3(
    .1 + r1 * .3,
    .2 + r2*1.,
    .1 + r1 * .3
  );
  d = min(d, B(p, sz));
  
  
  d = min(d, -B(pc, vec2(.6)));
  d = min(d, xfld(pp));
  
  vec3 bp = pp;
  bp.z += t;
  bp.xz = rep(bp.xz, vec2(.3, 1.));
  
  d = min(d, B(bp, vec3(.05, .025, .07)));
  
  return d;
}

const vec3 E=vec3(0.,.001,1.);
vec3 wn(vec3 p){
  return normalize(vec3(
    w(p+E.yxx), w(p+E.xyx), w(p+E.xxy)) - w(p));
}

float tr(vec3 o, vec3 D, float l, float L) {
  for (float i = 0.; i < 199.; ++i) {
    float d = w(o+D*l);
    l += d;
    if (d < .001*l || l > L) break;
  }
  return l;
}

void main(void) {
  vec2 pix = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = pix - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.);
  float a = 0;
  
  //c = vec3(h2(uv));
  
  t -= .4 * h2(pix+t*.1) * ffts(3.);
  
  
  
  float bpt = t/4.*177./120.;
  float cp = floor(bpt);
  
  vec3 O=vec3(0., 1.3, 0.), D=normalize(vec3(uv, -1.));
  D.yz *= R(.3 - .3 * h1(cp+.3));
  D.xz *= R(.6 - 1.2 * h1(cp+.2));
  
  float za = .1 - .2 * h1(cp+.1);
  za += fract(bpt) * (1. - 3. * h1(cp+.41)) - h1(cp+.85) * .4;
  //za += cp
  //+ (t*(.1 - .2 * h1(cp+.75)))
  D.xy *= R(za);
   
  
  O.x += 8. * h1(cp);
  O.y += 1. * h1(cp+.5);
 
  
  vec3 od = vec3((1. - 2. * h1(cp+.6)), 0., 2.);
  
  //if (1(cp+.54), .5)
  //od.x *= (1. - low);
  //O.y = (1. - low) + .3;
  if (h1(cp+.54) > .7) {
    od.x = 0.;
    O.x = .0;
    O.y = .2;
  }
 
  O -= od * (t+ffti(3.)*.3);
  
  vec3 sunc = 3. * vec3(1.,.5,.6);
  vec3 skyc = vec3(.3,.5,.9);
  vec3 ld = normalize(vec3(.98, 1., -1.4));

  vec3 kc = vec3(1.);
  for (int b=0; b < 4; ++b) {
    float L=20.,l=tr(O,D,0.,L);
    if (l >= L) {
      C += kc * mix(
        skyc,
        sunc,
        pow(max(0., dot(D, ld)), 30.)
      );
      break;
    }
  
    vec3 p=O+D*l;
    vec3 n=wn(p);
    
    float mr = 1.;//min(1.,  h2(floor(p.zy*16.) + floor(p.xz*16.)) * 2.5);
    //mr = h2(floor(p.xz*16.))*10.;// + floor(p.xz*16.)) * 20.5);
    //mr = fract(p.x);
    //mr = min(1., h2(floor(p.xz*6.) + floor(p.xy*32.)));
    vec3 md = vec3(1.);
    vec3 c=vec3(0.);
    //c=fract(p*10.);
    //c = n;
    
    float shl = 10.;
    float sh = step(shl, tr(p, ld, .1, shl));
    c += sunc * md * max(0, dot(ld, n)) * sh;
    
    c += .3 * skyc * md * max(0, dot(vec3(-ld.x, ld.y, -ld.z), n));

    // :(((
    kc *= mix(vec3(1.), skyc, l/L);
    c = mix(c, skyc, l/L * .8);
    //c *= pow(.001, l/L);
    
    C += kc * c;
    
    O = p + n * .01;
    D = reflect(D, n);
    kc *= .4 * mr;
  }
  
  C *= smoothstep(1.1, .1, length(uv));
  
  C = mix(C, pow(texture(texPreviousFrame, pix).rgb, vec3(2.)), .3 + .3 * ffts(.2));
  
	out_color = vec4(sqrt(C), a);
}