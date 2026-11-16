#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const vec3 E=vec3(0.,.01,1.);
float t = fGlobalTime;

float fft(float f) {f+=.5; return texture(texFFT, f/textureSize(texFFT,0)).r; }
float ffti(float f) {f+=.5; return texture(texFFTIntegrated, f/textureSize(texFFT,0)).r; }
float ffts(float f) {f+=.5; return texture(texFFTSmoothed, f/textureSize(texFFT,0)).r; }

float h1(float v){return fract(sin(v)*55789.54387);}
float ns(vec2 v){return texture(texNoise,(v+.5)/textureSize(texNoise,0)).r;}

mat2 rm(float a){return mat2(cos(a),sin(a),-sin(a),cos(a));}

float rep1(float p, float s){return mod(p,s) - s*.5;}
vec3 rep3(vec3 p, vec3 s){return mod(p,s) - s*.5;}
float vmax(vec3 v) { return max(max(v.x,v.y),v.z); }
float box3(vec3 p, vec3 s){return vmax(abs(p) -s);}

float dbox= 1e6;
float dbl = 1e6;
float w(vec3 p) {
  dbox = -box3(p,vec3(6.));
  float R = length(p);

  float lsz = .4;
  float maxl = 8.;
  
  float r = mod(R - ffti(4.)*.3, lsz * maxl);
  
  float Rlay = floor(R/lsz)+1.;
  float lay = floor(r/lsz)+1.;
  
  p.zy *= rm(t*.3+ffti(lay)*.04);
  p.xz *= rm(t*.5+ffti(lay)*.03);
  
  float pr = rep1(r, lsz);
  float ar = abs(pr);
  
  dbl = ar - .03*Rlay;
  dbl = max(dbl, abs(p.z) - .03*Rlay);
  dbl += ns(vec2(atan(p.x,p.y)*4., p.z)*100.)*.04*Rlay;

  dbl = min(dbl, lsz * .5 - ar + .1);
  dbl = max(dbl, R - maxl*lsz);
  
  //return min(dbl, dbox);
  return dbl;
  //return max(dbl, -(length(p)-1.));
}

vec3 wn(vec3 p) {
  return normalize(
    vec3(w(p+E.yxx),w(p+E.xyx),w(p+E.xxy))
  -w(p));
}

float tr(vec3 o, vec3 D, float l, float L) {
  for (float i = 0.0; i < 200.; ++i) {
    float d = w(o+D*l);
    l +=d;
    if (d< .001*l || l > L) break;
  }
  
  return l;
}

float occ(vec3 p, vec3 n, float N, float L) {
  float v=1.;
  L/=N;
  for(float i=1.;i<N;++i) {
    float ll = i*L, d = w(p+n*ll);
    v -= max(0.,ll-d)/ll/N;
  }
  return max(0., v);
}

void main(void) {
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float NS=4.;
 
  vec3 l1d = normalize(vec3(1.));
  vec3 C=vec3(0.);
  
  vec3 pos  =vec3(sin(ffti(8.))*.2, .3*cos(ffti(7.)), 6.);
  
  vec3 bg = vec3(.75,.8,.9);
  
  float lap = .2;
  float lfoc = 5.;
  float lfov = 2.;
  float rs = (uv.x+1.)*(1.+uv.y)+fract(t);
  for (float s=1.;s<=NS;++s) {
    rs = fract(rs);
    vec2 uvo = vec2(h1(rs+=s+1.),h1(rs+=s))/v2Resolution;
    t = fGlobalTime + .07*h1(rs+=s+1.)/NS;
    
    //float a = ns(vec2(t,s))*6.283*4.;//h1(rs+=.2)*6.283;
    //float r = ns(vec2(t,s+32.))*4.;//h1(rs+=.6);
    float a = h1(rs+=.2)*6.283;
    float r = h1(rs+=.6); r = sqrt(r);
    rs=fract(rs);

    vec3 at = vec3((uv+uvo)*lfov, lfoc);
    vec3 O = vec3(lap * vec2(cos(a),sin(a))*r, 0.);
    vec3 D = normalize(at-O);
    
    O -= pos;
    
    //vec3 O=vec3(sin(ffti(8.))*.2, .3*cos(ffti(7.)), 5.),
    //D = normalize(vec3(uv+uvo, -1.));
  
    mat2 mx=rm(ffti(10.)*.3-t*.8),my=rm(ffti(11.)*.5-t*.7);
    D.zy*=mx;O.zy*=mx;
    D.xz*=my;O.xz*=my;
  
    float L = 8.;
    float l = tr(O,D,.0,L);
  
  if (l< L) {
    vec3 p = O+D*l,n=wn(p);
    vec3 ma = vec3(1.);
    vec3 c = vec3(0.);
    c += ma * .4 * bg * occ(p, n, 5., 20.);
    //c += ma * .2 * bg * occ(p, n, 10., 1.);
    
    c += ma * vec3(.9, .7, .5) * (
      .3 * max(0., dot(n,l1d))
      + .7 * pow(max(0., dot(n,normalize(l1d-D))), 300.)
    );
    
    C += mix(bg, c, 1. - pow(l/L, 16.));
    //C = vec3(1.) * n * l/L ;
  } else {
    C += bg;
  }
}
  C /= NS;
  

  out_color = vec4(sqrt(C), 1.);
}