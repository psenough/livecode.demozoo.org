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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = acos(-1);
#define saturate(x) clamp((x), 0, 1)

float time, beat, bHalf, whole;
float bpm = 130;

mat3 ortho(vec3 z){
  z = normalize(z);
  vec3 up = vec3(0,1,0);
  vec3 cx = normalize(cross(z, up));
  vec3 cy = normalize(cross(cx, z));
  return mat3(cx, cy, z);
}

float noise(vec3 p){
  vec3 s = vec3(.1, .9, .2);
  float n = 0;
  float amp = 1, gain = 0.5, lac = 1.4;
  float warp = 1.3, warpTrk=.7,warpGa=1.5;
  mat3 rot = ortho(s);
  
  for(int i=0; i < 5; i++){
    p += sin(p.yzx * warpTrk)*warp;
    n += amp*sin(dot(cos(p.zxy), sin(p.yzx)));
    p *= rot;
    p *= lac;
    warpTrk *= warpGa;
    amp *= gain;
    
    }
  return n;
}

float random(int n){
    n = (n << 13) ^ n;
  return 1.0 - float((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0;
  }

float fractSin(vec2 p){
    return fract(sin(dot(p, vec2(12.18181, 4.1141414))) * 42069);
  }

vec3 cosgrad(float t){
    return 0.5 + 0.5 * cos(2 * PI * (vec3(t) + vec3(.66666, .33333, 0)));
}

float aBeat = 0, aHalf;

float sdBox(vec3 p, vec3 b){
  vec3 q = abs(p) - b;
  return length(max(q, 0)) + min(0, max(q.x, max(q.y,q.z)));
}

#define r2d(t) mat2(cos(t), sin(t), -sin(t), cos(t))
#define sq(x) ((x)*(x))


float map(vec3 q){
    vec3 p = q;
    float d = 1000;
    int mi = int(whole) % 6;
    //mi = 1;
    
    if(mi == 0){
      d = length(p) - .1 - aBeat;
    }
    if(mi == 1){
      p.xz *= r2d(PI * .5 * p.y + PI * aHalf);
      d = sdBox(p, vec3(1, 1, 1));
      
      p = q;
      p = abs(p);
      int exclude = int(random(int(beat)) * 3);
      int i = exclude == 0 ? 1 : 0;
      int j = exclude == 0 ? 2 : exclude == 1 ? 2 : 1;
      vec2 pp = vec2(p[i], p[j]);
      pp *= r2d(0.5 * PI * aBeat);
      p[i] = pp.x;
      p[j] = pp.y;
      d = min(d, sdBox(p - vec3(2,0,0), vec3(.25)));
    }
    if(mi == 2){
      p = q;
      p.xz *= r2d(PI * .5 * aBeat + time);
      d = sdBox(p - vec3(0, 1./2, 0), vec3(1, 1.0/6, 1.));
      p = q;
      p.xz *= r2d(time);
      d = min(d, sdBox(p, vec3(1, 1.0/6, 1.)));
      p.xz *= r2d(-PI * .5*aBeat);
      d = min(d, sdBox(p + vec3(0, 1./2, 0), vec3(1, 1.0/6, 1.)));
    }
    if(mi == 3){
      int cnt = int(fract(whole) * 16) + 1;
      for(int i=-cnt/2; i<cnt/2; i++){
        d = min(d, sdBox(p - vec3(i * .2, sin(PI * p.x), 0), vec3(.03, 1, 1)));
      }
    }
    if(mi == 4){
      int sd = 114514 + int(beat);
      for(int i=0; i<5; i++){
        sd += i;
        vec3 h = 2 * vec3(random(sd), random(sd + 186), random(sd + 189));
        vec3 n = 2 * vec3(random(sd + 1), random(sd + 186 + 1), random(sd + 189 + 1));
        vec3 c = mix(h,n, aBeat);
        d = min(length(p - c) - .35 - .1 * random(sd), d);
      }
    }
    if(mi == 5){
      d = p.y + 2 - .1 * noise(vec3(p.xz, floor(beat) + aBeat));
    }
    
    if(mi == 6){
      // im out of ideas, bye
    }
    
    
    return d;
}

vec3 normal(vec3 p){
  vec2 e = vec2(0, 1e-4);
  return normalize(
  vec3(
  map(p + e.yxx) - map(p -e.yxx),
  map(p + e.xyx) - map(p -e.xyx),
  map(p + e.xxy) - map(p -e.xxy)
  )
  );
}
  
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 pt = uv - 0.5;
	pt /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float offset = fractSin(pt * fGlobalTime);
  time = fGlobalTime + offset * .2;
  beat = time * bpm / 60.0;
  bHalf = beat * .5;
  whole = beat * .25;
  
  vec3 c = vec3(0,0,0);
  float anim = 0.5 + 0.5 * cos(PI * exp(-3. * fract(beat)));
  aBeat = anim;
  aHalf = smoothstep(0, 1, fract(bHalf));
  c += .01 * cosgrad(offset) * noise(vec3(pt * 4., floor(beat) + anim));
  c = abs(c);

  
  vec3 ro = vec3(0, 0, -5 + sin(time));
  vec3 rd = ortho(normalize(-ro)) * normalize(vec3(r2d(whole * .1) * pt, 1));
  float t = 0, d, thresh=1e-3;
  vec3 p;
  
  for(int i=0; i<100; i++){
    p = ro+rd*t;
    d = map(p);
    if(abs(d) < thresh || t > 100){
      break;
    }
    t += d;
    thresh = 1e-3 * t;
  }
  

  if(abs(d) < thresh){
    vec3 n = normal(p);
    vec3 l = normalize(vec3(1));
    c += cosgrad(offset) * sq(0.5 + 0.5 * dot(n,l));
  }
  
  c = pow(c, vec3(.4545));
	
	out_color = vec4(c,0);
}