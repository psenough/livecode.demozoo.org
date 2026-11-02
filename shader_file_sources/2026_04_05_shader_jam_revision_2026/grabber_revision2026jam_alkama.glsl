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

const float pi = acos(-1);

// OK, I think that's it for tonight :D


float t = mod(fGlobalTime*.4, 2.*pi);

const int AA = 1;

const vec3 background = vec3(.1, .15, .2);
vec3 lightpos = normalize(vec3(.2,.7, 1.6));

#define sat(a) clamp(a, 0., 1.)
#define repeat(p,n) mod(p,n)-.5*n
float vmax(vec3 v) { return max(max(v.x,v.y),v.z); }

float sphere(vec3 p, float r) { return length(p) - r; }
float cube(vec3 p, vec3 s, float sm) {
  vec3 b=abs(p)-s;
  return length(max(b,0.0) + min(vmax(b), 0.0)) - sm;
}

mat2 rot(float a) { float ca=cos(a), sa=sin(a); return mat2(ca, sa, -sa, ca); }

float scene(vec3 p) {
  p = repeat(p, 4.);

  vec3 tp = p;
  tp.yz *= rot(sin(.1+p.x+t));
  tp.xy += sin(t);
  tp.z -= cos(t);
  tp = repeat(tp, .3);
  float ts = sphere(tp, .04*(sat(17.-max(0,dot(p,p)))));
  
  vec3 sp = p;
  sp.yz *= rot(.4+sin(p.y+t));
  float s = cube(sp, 2.6*vec3(.6+.1*cos(t*10)), 1.+.4*sin(t+p.x));
  
  return max(s,ts);
}

vec3 normal(const vec3 pos, float t){
    vec2 e = .001*t*.6*vec2(-1, 1);
    return normalize(e.xyy*scene(pos+e.xyy) + e.yyx*scene(pos+e.yyx) + e.yxy*scene(pos+e.yxy) + e.xxx*scene(pos+e.xxx) );
}

float trace(const vec3 ro,  vec3 rd) {
  float d = .01;
  for(int i=0; i<500; i++ ) {
    float h = scene(ro+rd*d)*.4;
    if (abs(h)<.001) {
        vec3 p = ro+rd*d;
        vec3 n = normal(p, d);
        return d;
    }
    if(d>20.) {
      return -1;
    }
    d += h;
  }
  return -1;
}

vec3 getcam(vec2 uv, vec3 eye, vec3 target, float zoom) {
  vec3 f = normalize(target-eye);
  vec3 s = normalize(cross(vec3(abs(sin(t)*.5)-.5,1,abs(cos(t)*.25)), f));
  vec3 u = normalize(cross(f, s));
  return normalize(zoom * f + uv.x * s + uv.y * u);
}

void main(void)
{
  vec2 uv = ((gl_FragCoord.xy / v2Resolution) - .5) * vec2(v2Resolution.x/v2Resolution.y, 1);
  vec2 uv2 = uv;
  
  uv /= 3*(.5-length(uv));
    
  vec3 eye = vec3(1., .6, -3.);
  eye.xy += 10*vec2(.1*cos(t), .3*sin(t));
  vec3 target = vec3(0., 0., 0.);
  
  vec3 col = vec3(0);
  
  lightpos.yz *= 4.2*vec2(sin(t*10),cos(t*10));
  lightpos = normalize(lightpos);
    
  for(int y=0; y<AA; y++) for(int x=0; x<AA; x++) {
    uv2 = uv + (1./AA)*vec2(x,y) / (v2Resolution * vec2(v2Resolution.x/v2Resolution.y, 1));
    vec3 dir = getcam(uv2, eye, target, .75);
  
    float d = trace(eye, dir);

    if (d>3) {
        vec3 p = eye+dir*d;
        vec3 n = normal(p, d);
        vec3 refl = reflect(dir, n);

        vec3 foo = 3*(fract(p*.01));
        foo.xz *= rot(t*10);
        foo = abs(foo);
        
        float diffuse = abs(dot(n, lightpos));
        float specular = pow(abs(dot(refl, lightpos)), 10.);

        vec3 c = vec3(.8, .9, 1.0) * diffuse + vec3(0.7, 0.9, 1.0) * specular;

        c = mix(c, col*.001, smoothstep(0.25, .05, d/80.));
        c = pow(c, vec3(2.+.5*sin(t*10)));
        col += .5*c+c*foo*foo;
    }
  }
  col /= AA*AA;
  
  col = pow(col, vec3(.35-background));
  col += .4*background;
  col *= length(uv);

  out_color = vec4(col,1.);
}