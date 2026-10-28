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

const int STEPS = 60;
const float FAR = 100.0;
const float E = 0.001;

const vec3 FOG_COLOR = vec3(0.02, 0.1, 0.2);
const vec3 LIGHT_COLOR = vec3(0.9, 0.2, 0.3);

vec3 glow = vec3(0.0);

float sphere(vec3 p, float r){
  return length(p)-r;
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float scene(vec3 p){
  
  vec3 pp = p;
  
  float offset = 20.0;
  
  //pp.z = mod(pp.z + offset*0.5, offset)-offset*0.5;
  
  float safe = sphere(p, 5.0);
  
  for(int i = 0; i < 5; ++i){
    pp = abs(pp)-vec3(1.0, 0.5, 2.5);
    rot(pp.xy, time);
    rot(pp.yz, fft+ time);
    rot(pp.xz, fft*0.5);
  }
  
  float a = sphere(pp, 3.0);
  float b = sphere(pp-vec3(4.0, 5.0, 1.0), 5.0);
  
  vec3 g = vec3(1.0, 0.0, 0.3) * 0.05 / (abs(a)+0.01);
  g = vec3(0.1, 0.5, 0.5) * 0.05 / (abs(b)+0.01);
  g *= 0.5;
  
  glow += g;
  
  //a = max(abs(a), 0.9);
  b = max(abs(b), 0.5);
  
  return max(min(a, b), -safe);
  
}

float march(vec3 ro, vec3 rd){
  vec3 p = ro;
  float t = E;
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    p = ro + rd*t;
    
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

vec3 shade(vec3 rd, vec3 p, vec3 ld){
  vec3 n = normals(p);
  
  float l = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(ld, n), rd), 0.0);
  float s = pow(a, 20.0);
  
  return vec3(0.8, 0.2, 0.5)*l*0.5 + vec3(1.0, 0.0, 0.8)*s*0.5;
}



//http://www.iquilezles.org/www/articles/fog/fog.htm
vec3 fog(vec3 col, vec3 p, vec3 ro, vec3 rd, vec3 ld){
  float dist = length(p-ro);
	float sunAmount = max( dot(rd, -ld), 0.0 );
	float fogAmount = 1.0 - exp( -dist*0.05);
	vec3  fogColor = mix(FOG_COLOR, LIGHT_COLOR, pow(sunAmount, 10.0));
  return mix(col, fogColor, fogAmount);
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 q = -1.0 + 2.0 * uv;
  q.x *= v2Resolution.x/v2Resolution.y;
  
  vec3 ro = vec3(20.0*cos(time*0.5), 1.0+sin(time*2.0), 20.0*sin(time*1.0));
  vec3 rt = vec3(0.0, -1.0, 0.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x, y, z) * vec3(q, 1.0/radians(50.0)));
  
  float t = march(ro, rd);
  vec3 p = ro + t*rd;
  
  vec3 ld = -z;
  
  vec3 col = vec3(0.0);
  if(t < FAR){
    col = shade(rd, p, ld);
  }
  
  col += glow;
  col = fog(col, p, ro, rd, ld);
  
  vec3 prev = texture(texPreviousFrame, uv).rgb;
  
  col = mix(col, prev, 0.65);
  
  col = smoothstep(-0.2, 1.1, col);
  
  
	out_color = vec4(col, 1.0);
}