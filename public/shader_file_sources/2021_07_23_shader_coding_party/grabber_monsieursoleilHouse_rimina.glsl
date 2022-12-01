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

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.5).r;

const float E = 0.001;
const float FAR = 60.0;
const int STEPS = 64;

vec3 glow = vec3(0.0);

int M = 0;


float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// 3D noise function (IQ)
float noise(vec3 p){
    vec3 ip = floor(p);
    p -= ip;
    vec3 s = vec3(7.0,157.0,113.0);
    vec4 h = vec4(0.0, s.yz, s.y+s.z)+dot(ip, s);
    p = p*p*(3.0-2.0*p);
    h = mix(fract(sin(h)*43758.5), fract(sin(h+s.x)*43758.5), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float scene(vec3 p){
  vec3 pp = p;
  
  pp -= noise(p+fft)*0.9;
  rot(pp.xy, time+fft*2.0);
  
  float tunnel = -box(pp, vec3(6.0, 6.0, FAR));
  
  pp = p;
  //pp.z = mod(pp.z-5.0, 10.0)+5.0;
  for(int i = 0; i < 4; ++i){
    pp = abs(pp) - vec3(0.8, 1.0, 0.8);
    rot(pp.xy, time);
    rot(pp.xz, fft*10.0);
    rot(pp.yz, fft + time*0.5);
  }
  
  
  pp -= noise(p)*0.5;
  float a = box(pp, vec3(1.8, 2.0, 4.0));
  a = min(a, box(pp-vec3(2.0, 1.0, 0.0), vec3(4, 0.5, 0.2)));
  
  float b = sphere(pp, 1.5);
  
  vec3 g = vec3(0.2, 0.8, 0.8)*0.05/(abs(a)+0.01);
  //g += vec3(0.2, 0.8, 0.8) * 0.01 / (abs(b)+0.01);
  //g *= 0.5;
  
  a = max(abs(a), 0.6);
  //b = max(abs(b), 0.3);
  
  if(tunnel < b/* && tunnel < a*/){
    M = 1;
    float m = mod(p.z+time*4.0, 4.0)-2.0;
    if(m > -1.0 && m > 1.0){
      g += vec3(1.0, 0.0, 0.5) * 0.1 / (abs(tunnel)+0.01);
      g *= 0.5;
      
      tunnel = max(abs(tunnel), 0.5);
    }
  }
  else{
    M = 0;
  }
  
  glow += g;
  
  return min(tunnel, b);
}

float march(vec3 ro, vec3 rd){
  float t = E;
  //position
  vec3 p = ro;
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd * t;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  
  return t;
}

vec3 normals(vec3 p){
  vec3 e = vec3(E, 0.0, 0.0);
  return normalize(vec3(
    scene(p+e.xyy) - scene(p-e.xyy),
    scene(p+e.yxy) - scene(p-e.yxy),
    scene(p+e.yyx) - scene(p-e.yyx)
  ));
}

vec3 shade(vec3 rd, vec3 p, vec3 n, vec3 ld){
  
  vec3 col = vec3(0.9, 1.5, 1.3);
  
  if(M == 1){
    n = -n;
    ld = -ld;
    col = vec3(0.9, 0.0, 1.3);
  }
  
  float l = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(ld, n), rd), 0.0);
  float shine = 10.0;
  float s = pow(a, shine);
  
  return l * col* 0.5 + s * (col+0.2) * 0.8;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = -1.0 + 2.0*uv;
	q.x *= v2Resolution.x / v2Resolution.y;
  
  //ray origin
  vec3 ro = vec3(0.0, 5.0*sin(time*0.1), 15.0);
  //look at
  vec3 rt = vec3(0.0, -2.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  //ray direction
  vec3 rd = normalize(mat3(x, y, z) * vec3(q, radians(60.0+50.0*sin(time*0.2))));
  
  vec3 ld = -rd;
  
  float t = march(ro, rd);
  vec3 p = ro + rd*t;

  
  vec3 col = vec3(0.0);
  if(t < FAR){
    vec3 n = normals(p);
    col = shade(rd, p, n, ld);
  }
  
  col += glow*0.3;
  
  if(M != 0){
    col = vec3(col.r*0.3 + col.g * 0.59 + col.b*0.11);
  }
  //
  //col = 1.0 - col;
  
  vec3 prev = texture(texPreviousFrame, uv).rgb;
  //col = mix(col, prev, 0.8);
  
  col = smoothstep(0.1, 1.2, col);
  
	out_color = vec4(col, 1.0);
}