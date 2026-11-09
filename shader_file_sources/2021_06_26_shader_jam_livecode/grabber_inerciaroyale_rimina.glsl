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


//HELLO WORLD!

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.2).r;

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

const vec3 FOG_COLOR = vec3(0.02, 0.08, 0.085);
const vec3 LIGHT_COLOR = vec3(0.9, 0.6, 0.3);

vec3 glow = vec3(0.0);

bool flip = false;

float ID = 0.0;

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

//FROM MERCURY SDF LIBRARY
// Cylinder standing upright on the xz plane
float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}

void rotate(inout vec2 p, float a){
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
  
  float safe = sphere(p, 1.0);
  
  vec3 pp = p; 
  for(int i = 0; i < 8; ++i){
    pp = abs(pp) - vec3(0.4, 0.1, 0.5);
    
    rotate(pp.xy, fft*10.0);
    rotate(pp.xz, time*0.5);
    rotate(pp.yz, fft*10+time*0.1);
  }
  
  pp -= noise(p-time)*0.9;
  float a = box(pp, vec3(0.5));
  //a = max(a, -safe);
  
  pp = p;
  pp -= noise(p-fft*20.0)*0.4;
  
  float offset = 12.0;
  
  ID = floor((pp.z + offset*0.5) / offset);
  pp.z = mod(pp.z + offset*0.5, offset)-offset*0.5;
  
  rotate(pp.yz, radians(90.0));
  float tunnel = -fCylinder(pp, 12.0, 12.0);
  rotate(pp.yz, -radians(90.0));
  
  glow += vec3(0.2, 0.5, 0.5) * 0.01 / (abs(a) + 0.01);
  
  if(tunnel < a){
    flip = true;
  }
  else{
    flip = false;
  }
  
  return min(a, tunnel);
}

float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < FAR; ++i){
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

vec3 shade(vec3 rd, vec3 p, vec3 n, vec3 ld){
  if(flip){
    n = -n;
    ld = -ld;
  }
  float l = max(dot(n, ld), 0.0);
  float a = max(dot(reflect(ld, n), rd), 0.0);
  float s = pow(a, 10.0);
  
  vec3 lc = vec3(0.2, 0.9, 1.0);
  vec3 sc= vec3(0.5, 0.9, 1.0);
  
  if(mod(ID, 2.0) == 0.0){
    lc = lc.brg;
    sc = sc.brg;
  }
  
  return l * lc * 0.5 + s * sc * 0.8;
}

//http://www.iquilezles.org/www/articles/fog/fog.htm
vec3 fog(vec3 col, vec3 p, vec3 ro, vec3 rd, vec3 ld){
  float dist = length(p-ro);
	float sunAmount = max( dot(rd, -ld), 0.0 );
	float fogAmount = 1.0 - exp( -dist*0.06);
	vec3  fogColor = mix(FOG_COLOR, LIGHT_COLOR, pow(sunAmount, 10.0));
  return mix(col, fogColor, fogAmount);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uvv = uv - 0.5;
	uvv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0.0, 0.0, 10.0);
  vec3 rt = vec3(0.0, 0.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(uvv, radians(40.0)));
  vec3 col = vec3(0.0);
  
  float t = march(ro, rd);
  vec3 p = ro + rd*t;
  vec3 n = normals(p);
  vec3 ld = -z;
  if(t < FAR){
    col = shade(rd, p, n, ld);
  }
  
  col += glow * 0.1;
  col = fog(col, p, ro, rd, ld);
  
  
  vec4 pcol = vec4(0.0);
  vec2 puv = vec2(1.0/v2Resolution.x, 1.0/v2Resolution.y);
  vec4 kertoimet = vec4(0.1531, 0.12245, 0.0918, 0.051);
  pcol = texture2D(texPreviousFrame, uv) * 0.1633;
  pcol += texture2D(texPreviousFrame, uv) * 0.1633;
  for(int i = 0; i < 4; ++i){
    pcol += texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x - (float(i)+1.0) * puv.y, uv.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture2D(texPreviousFrame, vec2(uv.x + (float(i)+1.0) * puv.y, uv.y + (float(i)+1.0) * puv.x)) * kertoimet[i];
  }
  col += pcol.rgb;
  col *= 0.38;
  
  col = mix(col, texture2D(texPreviousFrame, uv).rgb, 0.6);
  
  col = smoothstep(-0.2, 1.2, col);

	out_color = vec4(col, 1.0);
}