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

int ID = 0;

vec3 glow = vec3(0.0);

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 64;

float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

void rotate(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}


float scene(vec3 p){
  
  vec3 pp = p;
  
  rotate(pp.xz, fft*20.0);
  rotate(pp.xy, fft*10.0);
  
  

  float safe = box(pp, vec3(20.0));

  pp = abs(pp)-vec3(6.0);
  rotate(pp.zy, fft*10.0);
  
  float kuutio = box(pp-vec3(0.0, -1.0, 0.0)*2.0, vec3(1.0, 2.0, 1.0)*2.0);
  kuutio = min(kuutio, box(pp-vec3(-1.0, 0.0, 0.0)*2.0, vec3(2.0, 1.0, 1.0)*2.0));
  kuutio = min(kuutio, box(pp-vec3(0.0, 0.0, -1.0)*2.0, vec3(1.0, 1.0, 2.0)*2.0));
  
  pp = p;
  rotate(pp.xy, time*0.5);
  float tunneli = -box(pp, vec3(15, 15.0+3.0*sin(time), FAR*2.0));
    tunneli = max(tunneli, -safe);
  
  float m = mod(p.z-(fft*10.0+time*0.5), 8.0)-4.0;
  if(m > 0.0){
    glow += vec3(0.6, 0.1, 0.8) * 0.1 / (abs(tunneli)+0.05);
  }
  
  if( kuutio < tunneli){
    ID = 1;
  }
  else{
    ID = 0;
  }
  
  return min(tunneli, kuutio);
  
  
}

float march(vec3 ro, vec3 rd){
  float t = E;
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

vec3 colorify(vec3 p, int id){
  vec3 col = vec3(0.8, 0.0, 0.3);
  float m = mod(p.z-(fft*10.0+time*0.5), 8.0)-4.0;
  
  if(id == 0){
    if(m > 0.0){
      col = col.bgr;
    }
    else{
      col = 1.0-col;
    }
  }
  
  return col;
}

vec3 normals(vec3 p){
  vec3 e = vec3(E, 0.0, 0.0);
  
  return normalize(vec3(
    scene(p+e.xyy) - scene(p-e.xyy),
    scene(p+e.yxy) - scene(p-e.yxy),
    scene(p+e.yyx) - scene(p-e.yyx)
  ));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 q = -1.0 + 2.0*uv;
  q.x *= v2Resolution.x/v2Resolution.y;


  vec3 ro = vec3(0.0, 2.0, 40.0);
  vec3 rt = vec3(0.0, 0.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(q, radians(60.0)));
  
  float t = march(ro, rd);
  vec3 p = ro + rd * t;
  int id = ID;
  vec3 n = normals(p);
  
  vec3 col = vec3(0.1, 0.0, 0.1);
  
  if( t < FAR){
    col = colorify(p, id);
    col += (1.0/t);
    
    if(ID == 1){
      for(int i = 0; i < 2; ++i){
        rd = reflect(rd, n);
        ro = p+n*E*2.0;
        t = march(ro, rd);
        p = ro + rd * t;
        id = ID;
        n = normals(p);
        
        col += colorify(p, id);
        col += (1.0/t);
        if(ID != 1){
          break;
        }
      }
      col *= 0.333;
    }
  }
  
  col += glow*0.25;
  
  float d = length(p-ro);
  float fa = 1.0 - exp(-d*0.04);
  col = mix(col, vec3(0.2, 0.1, 0.3), fa);
  
  col = smoothstep(-0.1, 1.2, col)* smoothstep(0.8, 0.005*0.799, distance(uv, vec2(0.5))*(0.9+0.005));
  
  col = smoothstep(-0.2, 1.2, col);

	out_color = vec4(col, 1.0);
}