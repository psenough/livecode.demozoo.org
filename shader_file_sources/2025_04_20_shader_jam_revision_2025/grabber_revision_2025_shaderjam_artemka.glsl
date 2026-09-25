// ultimate recyclotron 9000 v1.2.32.1337 - revision 2025 edition
// artemka 21.o4.2025

#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texRevisionBW;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// font
const int font[] =  int[](
    0,0,0,0,0,0,48,48,48,0,48,0,
    40,40,0,0,0,0,20,62,20,62,20,0,
    30,40,28,10,60,0,34,4,8,16,34,0,
    16,40,26,36,26,0,16,32,0,0,0,0,
    16,32,32,32,16,0,32,16,16,16,32,0,
    8,42,28,42,8,0,0,16,56,16,0,0,
    0,0,0,48,16,32,0,0,56,0,0,0,
    0,0,0,48,48,0,2,4,8,16,32,0,
    28,54,58,50,28,0,24,56,24,24,60,0,
    60,6,28,48,62,0,62,6,12,38,28,0,
    12,28,52,62,4,0,62,48,60,6,60,0,
    28,48,60,50,28,0,62,6,12,24,48,0,
    28,50,28,50,28,0,28,50,30,2,28,0,
    48,48,0,48,48,0,48,48,0,48,16,32,
    8,16,32,16,8,0,0,56,0,56,0,0,
    32,16,8,16,32,0,60,12,24,0,24,0,
    28,42,46,32,28,0,28,50,50,62,50,0,
    60,50,60,50,60,0,28,50,48,50,28,0,
    60,50,50,50,60,0,62,48,60,48,62,0,
    62,48,60,48,48,0,30,48,54,50,30,0,
    50,50,62,50,50,0,60,24,24,24,60,0,
    62,6,6,54,28,0,50,52,56,52,50,0,
    48,48,48,48,62,0,54,62,62,42,34,0,
    50,58,62,54,50,0,28,50,50,50,28,0,
    60,50,50,60,48,0,28,50,50,50,28,2,
    60,50,50,60,50,0,30,56,28,14,60,0,
    60,24,24,24,24,0,50,50,50,50,28,0,
    50,50,50,28,8,0,34,42,62,62,54,0,
    50,50,28,50,50,0,52,52,60,24,24,0,
    62,12,24,48,62,0,48,32,32,32,48,0,
    32,16,8,4,2,0,48,16,16,16,48,0,
    8,20,34,0,0,0,0,0,0,0,60,0,
    32,16,0,0,0,0,0,30,38,38,30,0,
    48,60,50,50,60,0,0,30,56,56,30,0,
    6,30,38,38,30,0,0,28,54,56,28,0,
    14,24,62,24,24,0,0,28,38,62,6,28,
    48,60,50,50,50,0,48,0,48,48,48,0,
    6,0,6,6,38,28,48,50,60,50,50,0,
    48,48,48,48,28,0,0,52,62,42,42,0,
    0,60,50,50,50,0,0,28,50,50,28,0,
    0,60,50,50,60,48,0,30,38,38,30,6,
    0,60,50,48,48,0,0,30,56,14,60,0,
    24,62,24,24,14,0,0,50,50,50,28,0,
    0,50,50,28,8,0,0,34,42,62,54,0,
    0,54,28,28,54,0,0,38,38,30,6,28,
    0,62,12,24,62,0,24,16,48,16,24,0,
    32,32,32,32,32,0,48,16,24,16,48,0,
    0,20,40,0,0,0,48,48,0,0,0,0
);

// text array
const int text[] = int[](
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,85,76,84,73,77,65,84,
    69,0,82,69,67,89,67,76,79,84,82,79,78,0,25,16,
    16,16,0,86,17,14,18,14,19,18,14,17,19,19,23,0,
    13,0,82,69,86,73,83,73,79,78,0,18,16,18,21,0,
    69,68,73,84,73,79,78,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,72,69,
    76,76,79,0,82,69,86,73,83,73,79,78,1,0,72,79,
    80,69,0,89,79,85,0,65,76,76,0,69,78,74,79,89,
    73,78,71,0,84,72,69,0,80,65,82,84,89,1,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,65,76,83,79,0,87,72,65,84,0,65,78,
    0,65,87,69,83,79,77,69,0,83,69,84,0,28,19,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,81,85,73,67,75,0,
    71,82,69,84,83,0,84,79,0,69,78,70,89,83,12,0,
    65,65,82,84,0,8,68,65,77,78,0,89,79,85,0,76,
    85,67,75,89,0,13,0,73,0,69,78,86,89,0,89,79,
    85,0,26,36,9,12,0,66,70,79,88,12,0,83,81,12,
    0,80,65,84,79,82,12,0,80,83,0,8,84,72,65,84,
    7,83,0,72,79,87,0,84,72,69,89,0,71,69,84,0,
    77,69,1,9,12,0,84,79,84,69,84,77,65,84,84,12,
    0,70,65,84,65,76,83,80,73,78,69,12,0,65,76,68,
    82,79,73,68,0,65,78,68,0,65,76,76,0,79,84,72,
    69,82,0,74,65,77,77,69,82,83,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,65,82,84,69,77,
    75,65,0,18,17,14,79,20,14,18,79,18,21,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,
    13,13,13,13,13,13,13,13,13,13,78,79,87,0,87,82,
    65,80,13,13,13,13,13,13,13,13,13,13,13,13,13,13,
    13,13,13,13
);


float hash(vec2 uv) { return fract(sin(dot(vec2(32.5, 32.), uv) * 230.0));}

float time = fGlobalTime;
float mt   = mod(time, 120);
float tt = mod(fGlobalTime + 0.01*hash(gl_FragCoord.xy/v2Resolution), 180.0);

const float PI = 3.14159265359;

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

// char grid
vec3 drawgrid(vec2 fuv) {
  float zoom = 64+48*sin(time*1.2);
  //float zoom = 12;
  
  vec2 auv = fuv;
  fuv.y  = 1.0 - fuv.y;
  fuv.y -= 0.5;
  fuv.y += 0.2*sin(time*2.2 + fuv.x*0.3);
  
  ivec2 cg = ivec2(fuv*zoom + vec2(mt*80,0));
  if (cg.y < 0 || cg.y > 5) return vec3(0.0);

  //cg.x += int(mt);
  int bitpos = 0x20 >> (cg.x%6);
  int bit = font[((text[(cg.x/6) % text.length()]*6)+(cg.y)) % font.length()] & bitpos;
  return bit==0 ? vec3(0.0) : vec3(1.0);
}

float sph(vec3 p, float r) {
  return length(p)-r;
}

vec3 mod3(vec3 p, vec3 s, vec3 l) {
  vec3 q = p - s*clamp(round(p/s),-1,1);
  return q;
}

float map(vec3 p) {
  p.zx *= rot2(time*0.2);
  p.xy *= rot2(time*0.1);
  p.y  *= (1.0+0.2*texture(texFFT,abs(mod(p.x+time,3)-1.5)*0.01).r+0.4*texture(texFFT,0.014).r);
  p.yz *= rot2(time*1.1+0.3*sin(1.4*time)+p.x*(0.3+0.05*sin(0.9*time)));
  p.xz *= rot2(time*1.1+0.3*sin(1.4*time)+p.x*(0.02+0.05*sin(0.9*time)));
  p = mod3(p,vec3(5),vec3(0));
  return sph(p, 1.0);
}

vec3 norm(vec3 p) {
  vec2 b = vec2(0., 0.0001);
  float a = map(p);
  return normalize(vec3(
    -a+map(p+b.yxx),
    -a+map(p+b.xyx),
    -a+map(p+b.xxy)
  ));
}

vec2 trace(vec3 o, vec3 d) {
  float t = 0.;
  float mct = 1000.0;
  for (int i = 0; i < 256; i++) {
    vec3 p = o + t*d;
    float ct = map(p);
    if ((abs(ct) < 0.00001) || (t > 128.)) break;
    t += ct;
    mct = min(mct, abs(ct));
  }
  
  return vec2(t, mct);
}

vec3 mapLogo(vec2 uv) {
  uv = clamp(uv, vec2(-0.5), vec2(0.5));
  uv *= (1.0 + (2. * texture(texFFT, 0.01).r));
  float r = length(uv);
  if (r < 0.5) {
    if (r < 0.12) uv *= rot2(tt * 0.7 + 3*sin(tt * 0.3)); else
    if (r < 0.18) uv *= rot2(tt * 1.5); else
    if (r < 0.25) uv *= rot2(tt * 0.3); else
    if (r < 0.4) uv *= rot2(tt * -1.3); else
                uv *= rot2(tt * 0.5);
      
    return textureLod(texRevisionBW, uv - vec2(0.5), 1).rgb;
  } else return vec3(0.0);
  
}

vec3 glgrid(vec2 fuv) {
  const float zoom=5;
  ivec2 cg = ivec2(fuv*zoom);
  //sin(mt*1.2+cg.x*0.3)*cos(mt*0.8+cg.y*0.1)
  //return abs(hash(vec2(cg)+time)) > 1.0-0.8*texture(texFFT,0.02).r ? vec3(0.9) : vec3(0.0);
  float ift = float(int(mt*7))/7;
  return abs(hash(vec2(cg)+ift)) > 1.0-0.1*texture(texFFT,0.02).r ? vec3(0.9) : vec3(0.0);
}

void main(void)
{
	vec2 fuv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = fuv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 color = vec3(0.0);
  
  {
    float aoa = 1.0-texture(texFFT,0.02).r;
    for (float f = 0.5; f < 1; f += 0.1) {
      vec2 lu = uv*f*aoa;
      lu *= rot2(mt*0.1);
      lu = abs(lu);
      lu *= rot2(mt*0.2);
      lu += vec2(0.3*sin(1.2*mt), 0.3*sin(1.2*mt));
      lu *= rot2(mt*0.3);
      lu = abs(lu);
      lu += vec2(0.2*cos(1.2*mt), 0.2*cos(1.2*mt));
      lu *= rot2(mt*0.2);
      color += 0.1*f*texture(texAcorn1, vec2(lu.x, -lu.y)).rgb;
    }
  }
  
  // RECYYYYCLING
  // raymarch something
  vec3 ray = normalize(vec3(uv, -0.5));
  vec3 o = vec3(0,0,13);
  vec2 tm = trace(o, ray);
  float t = tm.x;
  if (!((t == 0.0) || (t > 128.0))) {
    vec3 p = o+t*ray;
    vec3 n = norm(p);
    color = mix(color,vec3(0.2,0.4,0.6),pow(max(dot(n,vec3(0,0,1)),0),9));
  }
  color += 0.8*vec3(0.4,0.4,0.6)/max(1,7*pow(tm.y,1.9));  
  color *= 9.0;
  color = color/(1.0+color);
  
  // rotate + invert
  {
    vec2 buv = uv;
    buv *= rot2(time*0.2);
    if (mapLogo(buv).r > 0.3) color = vec3(1.0) - color;
  }
  
  color += 0.8*drawgrid(fuv/vec2(v2Resolution.y / v2Resolution.x, 1));
  
  {
    color += 0.9*(texture(texFFT, 0.1*abs(uv.y)).r);
  }
  if (glgrid(uv).x>0.5) color = 1.0-color;
  
  // vingette
  color *= 1.0-0.4*length(fuv-vec2(0.5));
  
  out_color = vec4(pow(color,vec3(0.6)),1.0);
}