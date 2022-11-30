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

#define time fGlobalTime
#define fft texFFT
#define ffts texFFTSmoothed
#define backbuffer texPreviousFrame

#define saturate(x) clamp((x), 0, 1)
#define bass texture(ffts, .001).r

const float PI = acos(-1);
const float TAU = 2 * PI;

float beat = time * 175. / 60.;
const vec3 up = vec3(0,1,0);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 r2d(float t){
  float c = cos(t), s = sin(t);
  return mat2(c,s,-s,c);
}

mat3 r3d(float angle, vec3 axis){
      vec3 a = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float r = 1.0 - c;
    mat3 m = mat3(
        a.x * a.x * r + c,
        a.y * a.x * r + a.z * s,
        a.z * a.x * r - a.y * s,
        a.x * a.y * r - a.z * s,
        a.y * a.y * r + c,
        a.z * a.y * r + a.x * s,
        a.x * a.z * r + a.y * s,
        a.y * a.z * r - a.x * s,
        a.z * a.z * r + c
    );
    return m;
}

void chmin(inout vec4 a, vec4 b){
    a = a.x < b.x ? a : b;
}

float box(vec3 p, vec3 b){
  p = abs(p) - b;
  return min(0., max(p.x, max(p.y, p.z))) + length(max(p,0.));
}

float octahedron(vec3 p, float s)
{
    p = abs(p);
    float m = p.x + p.y + p.z - s;
    vec3 r = 3.0*p - m;
    // iq's original version
  	vec3 q;
    if( r.x < 0.0 ) {q = p.xyz;}
    else if( r.y < 0.0 ){ q = p.yzx;}
    else if( r.z < 0.0 ){ q = p.zxy;}
    else {return m*0.57735027;}
    float k = clamp(0.5*(q.z-q.y+s),0.0,s);
    return length(vec3(q.x,q.y-s+k,q.z-k));
}

float rectSDF(vec2 st, vec2 size){
  return max(abs(st).x * size.x, abs(st).y * size.y);
}

float crossSDF(vec2 st, float s){
  vec2 size = vec2(.25, s);
  return min(rectSDF(st, size.xy),
    rectSDF(st, size.yx));
}

vec4 map(vec3 q){
  vec4 d = vec4(1000, 0,0,0);
  vec3 p = q;  
   
  float ns = texture(texNoise, p.xz * .1).r;
  ns += texture(texNoise, p.xz * .1 + ns).r * .2;
  p.y += ns;
  p.y += .5;
  float pl = p.y;
  chmin(d, vec4(pl, 0,0,0));
  
  p = q;
  float t = 0.5 + 0.5 * cos(PI * exp(-3. * fract(.5*beat)));
  float x = length(p.xz) - 1.;
  float y = p.y;
  float th = atan(y,x);
  float ph = atan(p.z, p.x);
  float r = length(vec2(x,y)) - 2.25;
  p = vec3(r,th,ph);
  p.y += p.z*(1 + t);
  p.y = mod(p.y, .2) - .1;
  
  p.r = abs(p.r) - 2;
  
  float tr = box(p, vec3(.05, .05, PI));
  chmin(d, vec4(tr,0,0,0));
  
  p = q;
  t = 0.5 + 0.5 * cos(PI * exp(-3. * fract(.5*beat + .5)));
  float sc = .3;
  float fr = 10000.;
  for(int i=0; i<5; i++){
      p *= r3d(PI * (.15 + t), normalize(vec3(-1, 1, 0)));
      fr = min(fr, octahedron(p, sc));
      p = abs(p);
      sc *= .43;
      p -= sc*1.5;
  }
  chmin(d, vec4(fr, 0,0,0));
  
  
  return d;
}

vec3 normal(vec3 p, vec2 e){
  return normalize(vec3(
    e.xyy * map(p + e.xyy).x +
    e.yxy * map(p + e.yxy).x +
    e.yyx * map(p + e.yyx).x +
    e.xxx * map(p + e.xxx).x
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 pt = uv - 0.5;
  vec2 ar = vec2(v2Resolution.y / v2Resolution.x, 1);
	pt /= ar;
  
	vec3 c = vec3(0);
  
  vec3 ro = vec3(1.,1.,-1.5);
  vec3 fo = vec3(1,0,0);
  vec3 rov = normalize(fo-ro);
  vec3 cu = normalize(cross(rov,up));
  vec3 cv = cross(cu,rov);
  vec3 rd = mat3(cu,cv,rov) * normalize(vec3(pt, 1));
  
  float t = 0, precis = 0;
  vec3 p = ro;
  vec4 d;
  for(int i=0; i<128; i++){
      p = ro + rd*t;
      d = map(p);
      t += d.x * .5;
      precis = t * .001;
      if(abs(d.x) < precis || t > 20.){
        break;
      }
  }
  
  vec3 lpos = vec3(1, 4, .5);
  if(abs(d.x) < precis){
    vec3 l = normalize(lpos - p);
    vec3 n = normal(p, vec2(precis, -precis));
    
    float ao = 0;
    for(int i=1; i<=10; i++){
      ao += map(p + n*i*.1).x / (i*.1);
    }
    ao /= 10;
    
    c = vec3(ao) * max(dot(n,l), .1);
  }
  
  
  float v = dot(c.rgb, vec3(.2126, .7152, .0722));
  float tm = 0.5 + 0.5 * cos(PI * exp(-4. * fract(beat)));
  vec2 st = pt;
  float s = rectSDF(st, vec2(1, 2))*.3 - .25;
  st *= r2d(PI*.5*tm);
  s = max(s, -crossSDF(st, 1.)+.075);
  s = step(s, 0.);
  st = abs(pt);
  s *= step(0., sin(PI*.5 + 100*(st.x) - TAU*tm));
  v = mix(v, 0, s);
  
  v *= 1.5 - length(pt);
  
  int n = int(bass * 100) + 1;
  for(int i=0; i<n; i++){
    pt *= .99;
    pt -= .1 * bass * vec2(1.,0) * r2d(TAU*20*bass);
    uv = (pt*ar) + .5;
    c += texture(backbuffer, uv).aaa;
  }
  c /= n;
  
  
  c = c / (1 + c);
  float lum = dot(c.rgb, vec3(.2126, .7152, .0722));
  float shad = smoothstep(.4, .01, lum);
  float high = smoothstep(.3, 1., lum);
  c = c * shad * vec3(.4, 1., 1.5) + c * (1-shad*high) + c*high*vec3(.99,.6,.8);
  
	out_color = vec4(c, v);
}