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

#define time fGlobalTime

mat2 rot(float a){
float c = cos(a);
  float s = sin(a);
  return mat2(c, -s, s, c);
}

float hash13(vec3 p3) {
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 w = smoothstep(0., 1., p-i);
    
    vec2 k = vec2(1., 0.);
    return 
    mix(mix(mix(hash13(i+k.yyy),
                hash13(i+k.xyy), w.x),
            mix(hash13(i+k.yxy),
                hash13(i+k.xxy), w.x), w.y),
        mix(mix(hash13(i+k.yyx),
                hash13(i+k.xyx), w.x),
            mix(hash13(i+k.yxx),
                hash13(i+k.xxx), w.x), w.y), w.z);
}

float fbm(vec3 p){
    float f = 0.;
    float s = 0.5;
    float a = 1.;
    for(int i = 0; i < 1; i++){
        s *= 2.;
        a *= 0.5;
        f += a*noise(s*p);
    }
    return f;
}

float gyr(vec3 p){
    return dot(sin(p.xyz), cos(p.yzx))*0.7;
}

float smin(float a, float b , float k){
  return -log2(exp2(-k*a)+exp2(-k*b))/k;
  }

 float zz(float x){
  return fract(x)*2-1;
   }
   
   float ss(float x){ return 0.5*sin(x)+0.5;}
  
float map(vec3 p) {
  vec3 p0 = p;
  p.xz *= rot(p.y);
  p.xz *= 1. + 0.2*sin(p.y + 2*time);
  p.x = abs(p.x)-1.;
  p.z = abs(p.z) - 0.5;
  float d = abs(length(p) - (1+0.5*exp(-fract(3*time)))) -( 0.1 + 0.1*exp(-fract(time)));
  vec3 q = p + time + pow(abs(sin(time*0.5)), 5);
  p.xz *= rot(4*time);
  p.yz *= rot(3*time);
  
  //vec3 c = vec3(cos(time),0,sin(time));
  //d = min(d, dot(q, c)-0.1);
  
  d = max(d, gyr(q*10 + sin(time))/10);
  float d1 = d + fbm(p*(10+2*ss(3*time)))*0.1;
  d = d1;
  vec3 n = vec3(0, 1, 1);
  float d2 = abs(dot(p, n) - sin(time)) - 1;
  d = max(d, d2);
  return d;
}

vec3 normal(vec3 p){
  vec2 h = 0.001*vec2(1,-1);
  return normalize(
    h.xyy*map(p+h.xyy) +
    h.yxy*map(p+h.yxy) +
    h.yyx*map(p+h.yyx) +
    h.xxx*map(p+h.xxx)
  );
  }


float glow = 0;
vec2 march(vec3 ro, vec3 rd){
  float t = 0;
  float n = 32;
  for(float i = 0.; i < n; i++){
    float d = map(ro + rd*t);
    glow += pow(exp(-3*d), 50);
    if(d < 0.001){
      return vec2(t, i/n);
    }
    t += d;
  }
  return vec2(-1);
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
	uv -= 0.5;
  uv.x *= v2Resolution.x / v2Resolution.y;
  
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0, 0, -4);
  vec3 rd = normalize(vec3(uv, 1));
  rd.xz *= rot(time);
  ro.xz *= rot(time);
  
  vec2 hit = march(ro, rd);
  if(hit.y > 0){
    float f = 1 - hit.y;
    f = pow(f, 0.5);
    col = vec3(1)*f;
    
    vec3 p = ro + rd*hit.x;
    vec3 n = normal(p);
    
    
    vec3 c = mix(vec3(1), vec3(0,1,1), 0.5*sin(10*time)+0.5);
    c = mix(c, vec3(1,0,1), 0.3*sin(time)+0.5);
    
    float sh = max(0, dot(n, normalize(vec3(1)+sin(time))));
    col *= sh*sh*sh*sh*sh;
    col += max(0, dot(n, -normalize(vec3(1)))) * vec3(0, 0, 1) * 0.5;
     
    vec3 s = normalize(vec3(1));
    col += pow(max(0, dot(n, -rd)), 10);
    
    col += f*c;
    
    vec3 k = normalize(vec3(0,1,0));
    k.xy *= rot(time);
    k.zx *= rot(time);
    col = mix(col, 1-col, step(0, dot(p,k)));
    
    col.rg *= rot(col.b + time);
  } else {
    col += glow;
    }
  
    
    float k = time + exp(-fract(5*time));
    float d = dot(uv, vec2(cos(k), sin(k))) + 0.3*sin(time);
    float d2 =  dot(uv, vec2(-cos(k), sin(k+1.33))) + 0.3*sin(time);
    col = mix(col, 1.-col, step(d*d2, 0));
    //col= mix(col, 1-col, noise(vec3(uv)
    
  out_color = vec4(col, 1.);
}