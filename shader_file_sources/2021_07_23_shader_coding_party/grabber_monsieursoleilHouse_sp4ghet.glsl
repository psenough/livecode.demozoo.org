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

#define fft texFFT
#define fft_integrated texFFTIntegrated
#define time fGlobalTime

#define saturate(x) clamp((x), 0., 1.)

const vec3 up = vec3(0.,1.,0.);
const float PI = acos(-1);
const float TAU = PI*2;


const mat3 rot(float x, float y, float z){
  float cx = cos(x), cy = cos(y), cz = cos(z), sx = sin(x), sy = sin(y), sz = sin(z);
  
  return mat3(cx*cy, cx*sy*sz - sx*cz, cx*sy*cz + sx*sz,
              sx*cy, sx*sy*sz + cx*cz, sx*sy*cz - cx*sz,
              -sy, cy*sz, cy*cz);
}

float noise(vec3 p3)
{
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3,p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float sph(vec3 i, vec3 f, ivec3 c){
  float rad =  .5 * noise(i+c);
  return length(f-vec3(c)) - rad;
}

float based(vec3 p){
    
    vec3 i = floor(p);
    vec3 f = fract(p);
  
    return min(min(min(sph(i,f,ivec3(0,0,0)),
                      sph(i,f,ivec3(0,0,1))),
                  min(sph(i,f,ivec3(0,1,0)),
                      sph(i,f,ivec3(0,1,1)))),
              min(min(sph(i,f,ivec3(1,0,0)),
                      sph(i,f,ivec3(1,0,1))),
                  min(sph(i,f,ivec3(1,1,0)),
                      sph(i,f,ivec3(1,1,1)))));
}

float smin(float a, float b, float k){
  float h = max( k-abs(a-b), 0.0 )/k;
  return min( a, b ) - h*h*h*k*(1.0/6.0);
}

float smax(float a, float b, float k)
{
    float h = max(k - abs(a - b),0.0);
    return max(a, b) + h * h * 0.25 / k;
}

void chmin(inout vec4 a, vec4 b){
    a = a.x < b.x ? a : b;
}

mat3 r = rot(PI*.23, PI*.76, PI*.37);

vec3 purp = vec3(.9, .05, .9);
vec3 orag = 1.2*vec3(.8, .35, .1);

vec4 map(vec3 q){
  vec3 p = q;
  vec4 d = vec4(1e5, 0,0,0);
  
  p = q - vec3(.7,0,.75);
  float bell0 = .3 * exp(-1.5*dot(p.xz, p.xz));
  p = q + vec3(1.,0,0);
  float bell1 = .75*exp(-2*dot(p.xz, p.xz));
 
  float pl = p.y - bell1 - bell0;
  float s = 1.;
  
  for(int i=0; i<5; i++){
    float n = based(p)*s;
    n = smax(n, pl-.1*s, .3*s);
    pl = smin(pl, n, .3*s);
    s *= .5;
    p = r*p/.5;
  }
  
  p = q*20;
  p.z -= texture(fft_integrated, .01).r;
  float gr = min(fract(p.z), fract(p.x));
  gr = step(gr, 0.05) * step(-0.05, gr);
  
  vec3 pal = mix(vec3(.1, .05, .4), purp, gr);
  chmin(d, vec4(pl, pal));
  
  p = q - vec3(0,1.,-5);
  float sun = length(p) - 2.5;
  pal = mix(purp, orag, p.y);
  chmin(d, vec4(sun, -1, -1, -1));
  
  return d;
}

vec3 normal(vec3 p, vec2 e){
    return normalize( e.xyy*map( p + e.xyy).x +
                      e.yyx*map( p + e.yyx).x +
                      e.yxy*map( p + e.yxy).x +
                      e.xxx*map( p + e.xxx).x );
}

float chi(vec3 n, vec3 l){
    return max(dot(n,l), .1);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 pt = (uv - 0.5) * 2;
	pt *= vec2(1, v2Resolution.y / v2Resolution.x);
  
  vec3 c = vec3(1);
  
  vec3 ro = vec3(0., .25, 3.);
  vec3 fo = vec3(0,0,0);
  vec3 rov = normalize(fo - ro);
  vec3 cu = normalize(cross(rov, up));
  vec3 cv = cross(cu, rov);
  vec3 rd = mat3(cu,cv,rov) * normalize(vec3(pt, 1.));
  
  float t = 0.01;
  float maxt = 25.;
  vec4 d;
  vec3 p = ro;
  float precis = 1e-6;
  
  for(int a=0; a<2; a++){
    for(int i=0; i<128; i++){
      p = ro + rd*t;
      d = map(p);
      t += d.x;
      precis = t * .001;
      if(abs(d.x) < precis || t > maxt){
        t = t >= maxt ? maxt : t;
        break;
      }
    }
    
    if(abs(d.x) < precis){
      if(d.y == -1){
        c *= 2.5*mix(purp, orag, uv.y);
        break;
      }
      vec3 n = normal(p, vec2(precis, -precis));
      vec3 albedo = d.yzw;
      c *= albedo;
      ro = p + n*.1;
      rd = reflect(rd, n);
    }else{
      c *= 1.5*mix(orag, purp, uv.y);
    }
  }
  
  c *= abs(sin(pt.y*400));
  
  c = smoothstep(.01, 1.5, c);
  float lum = dot(c.rgb, vec3(.2126, .7152, .0722));
  float shad = smoothstep(.4, .01, lum);
  float high = smoothstep(.3, 1., lum);
  c.rgb = c.rgb*shad*vec3(.4, 1.2, 1.2) + c.rgb*(1-shad*high) + c.rgb*high*vec3(.99, .8,.8);
  
  c = c / (1. + c);
  c = pow(c, vec3(.4545));
  
  
  

	out_color = vec4(c,0);
}