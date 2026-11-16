#version 420 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define PI acos(-1.0)

const float TR = 20.0; // Torus radius
const float TUNNEL_R = 3.0; // Tunnel radius
vec3 panelColor;
const float ALONG = 160.0;
const float AROUND = 32.0;
vec3 green = vec3(0.0, 0.77, 0.09);
vec3 orange = vec3(1.0, 0.25, 0.04);

mat2 rot(float a)
{
  float s = sin(a), c = cos(a);
  return mat2(c, s, -s, c);
}

float hash21(vec2 p)
{
  return fract(sin(dot(p,vec2(12.9898,78.233))) * 43758.5453);
}

float sdBox(vec3 p, vec3 b)
{
  vec3 q = abs(p)-b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 path(float a)
{
    return vec3(
      cos(a) * TR,
      0.0,
      sin(a) * TR
    );
}

float map(vec3 p)
{
  float time = fGlobalTime * .25;
  float d;
  //p.xz *= rot(fGlobalTime * .25);
  //p = mod(p, 2.) - 1.;
  //d = length(p) - 0.25;
  
  // front angle
  float a = atan(p.z, p.x);
  vec3 radial = vec3(cos(a), 0., sin(a));
  
  vec3 center = path(a);
  
  vec3 q = p - center;
  
  // sluced tunnel angle
  float b = atan(q.y, dot(q, radial));
  
  float ia = floor((a / (2. * PI) + 0.5) * ALONG);
  float ib = floor((b / (2. * PI) + 0.5) * AROUND);
  
  vec2 id = vec2(ia, ib);
  
  // panel center angle
  float ca = ((ia + 0.5) / ALONG - 0.5) * 2. * PI;
  float cb = ((ib + 0.5) / AROUND - 0.5) * 2. * PI;
  
  // coord for panels
  vec3 R = vec3(cos(ca), 0., sin(ca));
  vec3 U = vec3(0., 1., 0.);
  vec3 F = vec3(-sin(ca), 0., cos(ca));
  
  // panel center
  vec3 pc = path(ca) + R * cos(cb) * TUNNEL_R + U*sin(cb) * TUNNEL_R;
  vec3 N = R*cos(cb) + U*sin(cb);
  
  vec3 S = -R * sin(cb) + U * cos(cb);
  
  q = p - pc;
  vec3 lp = vec3(dot(q,F), dot(q,S), dot(q,N));
  
  // FLIP
  
  float rnd = hash21(id);
  float cycle = fGlobalTime / 3.;
  
  float turn = floor(cycle);
  float phase = fract(cycle);
  
  float delay = rnd * 0.25;
  
  float flip = smoothstep(delay, delay+0.25, phase);
  
  float angle = (turn + flip) * PI;
  lp.yz *= rot(angle);
  
  // COLOR
  
  vec3 front = vec3(0.1);
  float h = hash21(id + 37.);
  vec3 back = vec3(.75);
  
  if(h<0.2)
  {
    back = vec3(.4);
  }
  
  if(h<0.1)
  {
    back = green;
  }
  
  if(h<0.02)
  {
    back = orange;
  }
  
  float side = step(0, cos(angle));
  // panel SDF
  float panelX = PI * TR / ALONG * 1.1;
  float panelY = PI * TUNNEL_R / AROUND * 0.88;
  
  //d = sdBox(lp, vec3(.5));
  panelColor = mix(back, front, side);
  d = sdBox(lp, vec3(panelX, panelY, 0.095));
  
  return d;
}

vec3 getNormal(vec3 p)
{
  const float e = 0.001;
  return normalize(vec3(
    map(p+vec3(e,0.,0.)) - map(p-vec3(e,0.,0.)),
    map(p+vec3(0., e,0.)) - map(p-vec3(0.,e,0.)),
    map(p+vec3(0.,0.,e)) - map(p-vec3(0.,0.,e))
  ));
}



void main(void)
{
  float time = fGlobalTime * 0.25;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 asp = vec2(v2Resolution.xy / min(v2Resolution.x, v2Resolution.y));
  vec2 suv = (uv * 2. - 1.) * asp;
  
  vec3 col = vec3(suv, 0.);
  
  vec3 ro = vec3(0., 0., -5.);
  ro = path(time);
  vec3 ta = vec3(0., 0., 0.);
  ta = path(time + 0.25);
  vec3 forward = normalize(vec3(ta-ro));
  
  vec3 right = normalize(cross(vec3(0., 1., 0.), forward));
  vec3 up = normalize(cross(forward, right));
  
  vec3 rd = normalize(mat3(right, up, forward) * vec3(suv, 1.5));
  rd.yz *= rot(cos(fGlobalTime* 0.5));
  
  float dist;
  float totalDist = 0.;
  vec3 pos;
  bool hit = false;
  vec3 lightPos = ro + forward * 5. + up;
  
  for(int i=0; i<100; i++)
  {
    pos = ro + rd * totalDist;
    dist = map(pos);
    if(dist < 0.001)
    {
      col = vec3(1.);
      
      
      hit = true;
      break;
    }
    totalDist += dist;
  }
  
  col = vec3(0.);
  
  if(hit)
  {
    vec3 n = getNormal(pos);
    vec3 ld = normalize(lightPos - pos);
    float diff = max(.1, dot(ld, n));
    col = diff * panelColor;
    //col = n * 0.5 + 0.5;
  }
  
  vec3 fogColor = vec3(0.5, 0.6, 0.7) * pow(clamp(rd.y + 0.9, 0., 1.), 2.);
  col = smoothstep(0.1, 1., col);
  
  col = mix(fogColor, col, exp(-totalDist * 0.04));
  
  float phase = fract(fGlobalTime / 3.);
  
  float fx = smoothstep(0., 0.08, phase) * (1. - smoothstep(0.35, 0.5, phase));
  
  vec2 dir = normalize(suv + vec2(0.001));
  
  float shift = 0.008 * fx;
  
  float r = texture(texPreviousFrame, uv + dir * shift).r;
  float g = texture(texPreviousFrame, uv).g;
  float b = texture(texPreviousFrame, uv - dir * shift).b;
  
  vec3 prev = vec3(r,g,b);
  
  col = mix(col, prev, fx * 0.8);
  
  
  
	out_color = vec4(col, 0.);
}