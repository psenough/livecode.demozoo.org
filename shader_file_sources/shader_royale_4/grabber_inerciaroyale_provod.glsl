#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

float t=fGlobalTime,dt=fFrameTime;

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

float vmax(vec3 v){return max(max(v.x,v.y),v.z);}
#define box(v,s) vmax(abs(v) - (s))

#define Rm(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define T(t,s) texture(t,(s)/textureSize(t,0))
#define P(s) T(texPreviousFrame, s)
#define N(s) T(texNoise, s).r
#define fft(s) T(texFFT, s).r
#define ffts(s) T(texFFTSmoothed, s).r
#define ffti(s) T(texFFTIntegrated, s).r
float h(float f) { return fract(sin(f)*45734.4378); }
#define rep(p,s) (mod(p,s)-(s)*.5)

vec3 ptrans(vec3 p) {
  p.x += 2.* sin(.4 * ffti(10) + t * .3);
  p.xz *= Rm(t + ffti(6) * 1.);
  p.xy *= Rm(t*.7);
  p.z += 2.* sin(.2 * ffti(10) + t * .3);
  return p;
}

float w(vec3 p) {
  vec3 bp = ptrans(p);
  float d = box(bp, vec3(.3 + 1.5 * ffts(7) * 17.));
 
  vec3 pf = p;
  pf.y -= h(floor(ffti(15))) * 100.;
  pf.xy *= Rm(ffti(8)*.1 - t - p.z*(-.005+ .01 * ffts(7.)));
  float d2 = box(rep(pf+vec3(0., 0., -t*100.), vec3(10., 10., 40.)), vec3(.2));
  if (ffts(5.) > .21)
    d = min(d, d2);
  else d = d2;
  
  
  return d;
}


float pv(vec2 pix, vec2 RES) {
  float v = 0.;
  vec2 uv=pix/RES*2. - 1.; uv.x*=RES.x/RES.y;
  
  float a = N(pix) * 20.;
  vec2 off = 2. * vec2(cos(a), sin(a)) * (.5 + 60.*ffts(5));
  off -= uv*2.;
  v += P(pix + off).a;
  v -= dt * 3. * (.1 + 20. * ffts(7.));
  
  vec3 O=vec3(0., 0., 5.), D=normalize(vec3(uv, -2.)), p;
  float L=100.,l=0.,d;
  for (float i=0.;i<100.;++i){
    d=w(p=O+D*l); l+=d;
    if (d<.001*l||l>L)break;
  }
  if (l<L) {
    p = ptrans(p) * 400.;
    v += step(.05, N(p.xz) * N(p.zy));
  }
  
  float r = length(uv);
  
  float rt = mod(t, 2.);
  r = r - rt;
  //r = max(r - rt, r);
  v += step(r, 0.) * step(-.08, r) * step(.2, N(pix*2.+r)) * step(.01, ffts(40));
  
  return v;
}

vec4 pf(vec2 pix) {
  vec4 c = P(pix);
  return vec4(c.rgb*c.rgb, c.a);
}

void main(void) {
  vec2 pix = gl_FragCoord.xy;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 C=vec3(0.);
  //vec2 TS = vec2(1920., 1080.) / 8.;
  vec2 TS = v2Resolution;
  float A = pv(pix + vec2(0., 0.), TS); 
  
  const float NS=40.;
  for (float s=0.;s<NS;++s) {
    vec3 O=vec3(5., 1., 3.), D = normalize(vec3(uv, -1.));
    O.x += h(floor(t*1.)) * 2. - 3.;
    //O.x -= 1.;
    O.z += N(t)*10.;
    D.xz *= Rm(-.2);// + .3 * sin(t*.1 +ffti(6)*.3));
    D.yz *= Rm(-.1 + .2 * N(ffti(7.)));
    
    float tt = fract(t);
    O.z += 3. * mix(h(floor(tt)), h(floor(tt)+1.), 1.-tt*tt);
    
    //if (fract(ffti(10)) > .9)
    {
      O.y += 2.;
      D.yz *= Rm(.5);
    }
    vec3 kc = vec3(1.);
    float sd = h(pix.x+pix.y+t+s);
    for(float b=0.;b<2.;b++){
      float ly = D.y < .0 ? - O.y / D.y : 1e6;
      float lz = D.z < .0 ? - O.z / D.z : 1e6;
      float r = 0.;
      vec3 p, n, c=vec3(0.);
      if (ly < lz) {
        if (ly > 100.) break;
        p = O + D * ly;
        n = vec3(0., 1., 0.);
        //c = vec3(fract(p.xz), 0.);
        //c = vec3(0.,1.,0.);
        vec2 uv = p.xz * 100;
        r = N(uv);
        r *= (.6 + .4 * step(.7, fract(t+dot(normalize(vec2(1.)), uv/100.))));
      } else {
        if (lz > 100.) break;
        p = O + D * lz;
        n = vec3(0., 0., 1.);
        //C += kc * vec3(fract(p.xy), 0.);
        vec2 uv = p.xy * TS / 4.; //uv.x /= TS.x / TS.y;
        uv.x /= TS.x / TS.y;
        
        //uv.x += 100.;
        uv = floor(uv);
        //uv = clamp(uv, vec2(0.), TS);
        #define pxl(p,s) (floor((p)/(s))*(s))
        float ps = 1. + max(0., floor(1. + ffts(8) * 200. + 8. * sin(N(floor(uv/1.)))));
        uv = pxl(uv, ps);
        
        //uv.x -= floor(ffts(uv.y/100.) * 10.)*100.;
        
        c = vec3(
          pf(uv+.7).a,
          pf(uv).a,
          pf(uv-.4).a);
        
        //c = vec3(1.,0.,0.);
      }
      C += kc * c;
      
      O = p + .01 * n;
      D = normalize(mix(
        reflect(D, n),
        vec3(h(sd+=D.y),h(sd+=D.z),h(sd+=D.x)) - .5,
        r));
      kc *= .9;
    }
  }
  
  C/=NS;
  
  C = mix(C, vec3(
    pf(pix-.3).r,
    pf(pix).g,
    pf(pix+.9).b
  ), min(1., length(uv) * .9 * (50. * ffts(17))));
  
  C *= smoothstep(1.3, .9, length(uv));
  
	out_color = vec4(sqrt(C), A);
}