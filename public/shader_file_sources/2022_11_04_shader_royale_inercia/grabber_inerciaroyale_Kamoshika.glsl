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

#define hash(x) fract(sin(x)*5723.2622)
const float pi = acos(-1);
const float pi2 = acos(-1)*2;

mat2 rot(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, s, -s, c);
}

float hash12(vec2 p) {
  float v = dot(p, vec2(1.8672, 1.3723));
  return hash(v);
}

float perlin1d(float x) {
  float i = floor(x);
  float f = fract(x);
  float u = f*f*(3-2*f);
  
  return mix(f*(hash(i)*2-1), (f-1)*(hash(i+1)*2-1), u);
}

float stepNoise(float x, float n) {
  float i = floor(x);
  float s = .1;
  float u = smoothstep(.5-s, .5+s, fract(x));
  
  return mix(floor(hash(i)*n), floor(hash(i+1)*n), u);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * .5;
  vec3 col = vec3(0);
  
  float w = .03;
  
  vec3 ac = vec3(0);
  for(float j=0; j<8; j++) {
    float time = fGlobalTime;
    vec2 seed = gl_FragCoord.xy + fract(time) + j * sqrt(983);
    
    time += hash12(seed) * .05;
    
    vec3 ro = vec3(0, 1, -time);
    vec3 ta = vec3(0, -.5, -time-.5);
    
    ro.x += (stepNoise(ro.z, 5) - 2) * .5;
    ro.y += stepNoise(ro.z - 500 - 1/3, 5) * .5;
    
    vec3 dir = normalize(ta - ro);
    vec3 side = normalize(cross(dir, vec3(0,1,0)));
    vec3 up = normalize(cross(side, dir));
    
    float fov = 40;
    fov += (stepNoise(ro.z - 1000 - 2/3, 2) * 2 - 1) * 20;
    vec3 rd = normalize(uv.x*side + uv.y*up + dir/tan(fov/360*pi));
    float L = length(ta - ro);
    vec3 fp = ro + rd * L;
    
    vec3 ros = ro;
    float r = sqrt(hash12(seed*1.1));
    float theta = hash12(seed*1.2) * pi2;
    ros.xy += r * vec2(cos(theta), sin(theta)) * L * .05;
    
    vec3 rds = normalize(fp - ros);
    
    bool hit = false;
    float t;
    vec2 id, q;
    
    for(float i=0; i<50; i++) {
      t = -(ros.y + i*.05) / rds.y;
      vec2 p = ros.xz + t * rds.xz;
      p += vec2(hash(i), hash(i*1.1)) * 500;
      p *= rot(i*2);
      
      id = vec2(i, floor(p.x));
      
      p.x = fract(p.x) - .5;
      p.y += hash12(id) * 500;
      float s = .03;
      float curve = smoothstep(.25-s, .25+s, abs(fract(time*.11) - .5));
      p.x += perlin1d(p.y) * (1 - w * 2) * curve;
      
      q = p;
      
      if(t > 0 && abs(p.x) < w) {
        hit = true;
        break;
      }
    }
    
    if(hit) {
      vec3 add = vec3(1);
      
      vec3 lightDir = normalize(vec3(-5, 2, -2));
      vec3 normal = normalize(vec3(q.x, sqrt(w*w - q.x*q.x), 0));
      
      float e = 1e-4;
      float grad = (perlin1d(q.y + e) - perlin1d(q.y - e)) / (e*2);
      float a = atan(grad);
      
      normal.xz *= rot(-id.x*2 - a);
      
      float diff = max(dot(normal, lightDir), 0);
      float spec = pow(max(dot(reflect(lightDir, normal), rds), 0), 20);
      float m = .5;
      float lp = 3;
      add *= diff * (1-m) * lp + spec * m * lp + .2;
      
      q.y = fract(q.y * .03 - time * .2) - .5;
      add += smoothstep(.01, 0., abs(q.y)) * 5.;
      
      float T = time + hash12(id);
      add += step(hash12(id*1.1 + floor(T)), .05) * step(fract(T*3.), .8) * 5;
      
      add *= exp(-t*t*.1);
      add *= exp(-id.x*id.x*.001);
      
      ac += add;
    }
  }
  
  col += ac / 8;
  col = pow(col, vec3(1/2.2));
  
	out_color = vec4(col, 1);
}