#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// shared values
vec2 ouv = vec2(0.0);
float time = fGlobalTime;
vec3 color1 = vec3(1.0, 0.0, 0.0);
vec3 color2 = vec3(0.0, 1.0, 0.0);
vec3 color3 = vec3(0.0, 0.0, 1.0);
vec3 light1 = vec3(1.0, 0.6, 0.0);
vec3 light2 = vec3(0.5, 0.5, 0.9);
vec3 light3 = vec3(0.2, 0.9, 0.4);
vec3 glow = vec3(0.0);
float fft = 0.0;
float ffts = 0.0;
float ffts2 = 0.0;
float ffti = 0.0;
float beat = 0.0;
float beatstep = 0.0;
float bar = 0.0;
float barstep = 0.0;

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
  return rotx*roty*rotz * p;
}
vec3 getcam(vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize(target-cam);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross(forward, right));
  return normalize(forward*fov + uv.x * right + uv.y*up);
}
float sphere(vec3 p, float r)
{
  return length(p)-r;
}
float frame( vec3 p, vec3 b, float e )
{
  p = abs(p)-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float torus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}


float ground(vec3 p, float h)
{
  return p.y-h;
}

vec3 union( vec3 a, vec3 b)
{
  return a.x < b.x ? a :b;
}


vec3 repeat( vec3 p, vec3 q)
{
  return mod(p + q*0.5, q)-q*0.5;
}


vec3 map(vec3 p, float isShadow)
{
  vec3 ps1 = rotate(p-vec3(0.0, 1.7,0.0), ffti, ffti*0.63, ffti*1.3);
  ps1 = repeat(ps1, vec3(8.0, 8.0, 8.0));
  float s1 = frame(ps1,vec3(0.5)*(1.0+smoothstep(0.2, 0.5, ffts)), 0.25-0.2*smoothstep(0.1,0.9,ffts)-0.1*smoothstep(0.1,0.9,ffts2));
  if(mod(bar, 8.0) < 4.0) s1 = torus(ps1, vec2(1.0,0.2 + 0.3*smoothstep(0.1,0.6,ffts)));
  vec3 S1 = vec3( s1, 1.0, 0.0);
  
  
  float g1 = ground(p, 0.0);
  vec3 G1 = vec3( g1, 1.0, 1.0);
  
  float l1 = sphere(p - light1, 0.05);
  float l2 = sphere(p - light2, 0.05);
  float l3 = sphere(p - light3, 0.05);
  
  vec3 L = vec3(99.0,99.0, 99.0);
  if(isShadow < 0.5)
  {
    vec3 L1 = vec3( l1, 12.0, 0.0);
    vec3 L2 = vec3( l2, 12.0, 0.5);
    vec3 L3 = vec3( l3, 12.0, 1.0);
    L = union(L1,L2);
    L = union(L, L3);
    glow += smoothstep(0.2, 0.0, L1.x) * color1;
    glow += smoothstep(0.2, 0.0, L2.x) * color2;
    glow += smoothstep(0.2, 0.0, L3.x) * color3;
  }
    
  return union(L, union(G1,S1));
}

vec3 normal( vec3 p)
{
  vec3 c = map(p, 0.0);
  vec2 e = vec2(0.001, 0.0);
  return normalize( vec3( 
    map(p+e.xyy, 0.0).x,
    map(p+e.yxy, 0.0).x,
    map(p+e.yyx, 0.0).x
  )-c.x);
}

float diffuse( vec3 p, vec3 n, vec3 l)
{
  return max(0.0, dot(n,normalize(l-p)));
}

vec3 march(vec3 cam, vec3 rd, out vec3 p, out float travel, float isShadow)
{
  float minimum = 99.0;
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd*travel;
    vec3 r = map(p, isShadow);
    minimum = min(r.x, minimum);
    
    travel += r.x;
    if(r.x < 0.001){
      
      return r;
    }
    if(travel > 100.0){
      travel = 100.0;
      return vec3(minimum, 0.0, 0.0);
    }
    
  }
  return vec3( minimum, 0.0, 0.0);
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  ouv = uv;
  
  ffti = texture(texFFTIntegrated,0.2).r;
  ffts = texture(texFFTSmoothed, 0.15).r*70.0;
  ffts2 = texture(texFFTSmoothed, 0.05).r*30.0;
  fft = texture(texFFT,0.2).r;
  
  beat = floor(time * 130.0 / 60.0);
  beatstep = fract( time * 130.0 / 60.0*1.0);
  bar = floor(beat/4.0);
  barstep = fract(beat/4.0);
  
  
  vec3 inercia = texture(texInerciaLogo2024, vec2(uv.x, 1.0-uv.y)).rgb;
  
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 c = vec3(0.0);
  
  vec3 cam = vec3( sin( time*0.2 ) * 4.0, 4.0, cos( time*0.21 ) * 3.0);
  vec3 target = vec3( 0.0, 1.6, 0.0);
  float fov = 1.36;
  
  light1 = vec3(cos(time)*1, 2.0+sin(time*1.1), sin(time)*1.0);
  light2 = vec3(cos(time*0.5)*3, 1.5+sin(time*0.6), sin(time*0.89)*3.0);
  light3 = vec3(cos(time*0.8)*3, 1.5+sin(time*0.3), sin(time*0.23)*3.0);
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 marchp = cam;
  float marcht = 0.0;
  vec3 res = march( cam, rd, marchp, marcht, 0.0);
  
  if(res.y < 0.5)
  {
    // bg
  }
  else if(res.y < 1.5)
  {
    // obj
    vec3 n = normal(marchp);
    
    float mat = 1.0;
    if(res.z > 0.5)
    {
      float idx = mod( floor(marchp.x/0.5)+0.5, 2.0);
      float idy = mod( floor(marchp.z/0.5)-0.5, 2.0);
      mat = max(1.0,2.0-idx * idy);
    }
    
    // shadows
    vec3 l1marchp = marchp;
    float l1marcht = marcht;
    vec3 l1march = march( marchp + n*0.1, normalize(light1-marchp+n*0.1), l1marchp, l1marcht, 1.0);
    
    vec3 l2marchp = marchp;
    float l2marcht = marcht;
    vec3 l2march = march( marchp + n*0.1, normalize(light2-marchp+n*0.1), l2marchp, l2marcht, 1.0);
    
    vec3 l3marchp = marchp;
    float l3marcht = marcht;
    vec3 l3march = march( marchp + n*0.1, normalize(light3-marchp+n*0.1), l3marchp, l3marcht, 1.0);
    
    
    float shadow1 = smoothstep( 0.05, 0.15, l1march.x);
    float shadow2 = smoothstep( 0.05, 0.15, l2march.x);
    float shadow3 = smoothstep( 0.05, 0.15, l3march.x);
    
    c = mat* color1*diffuse( marchp, n, light1)/1.0 * shadow1;
    c +=mat* color2*diffuse( marchp, n, light2)/1.0 * shadow2;
    c +=mat* color3*diffuse( marchp, n, light3)/1.0 * shadow3;
    
    
  }
  else 
  {
    c = vec3(1.0);
    if(res.z < 0.33) c = color1;
    else if(res.z < 0.66) c = color2;
    else if(res.z < 1.33) c = color3;
    
  }
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

  c+= glow;
	
  ouv -= 0.5;
  ouv *= 1.05-ffts*0.15;
  ouv += 0.5;
  vec2 inc = ouv;
  inc.x = 1.0-inc.x;
  vec3 prev = texture( texPreviousFrame, ouv).rgb + texture( texPreviousFrame, ouv).rgb;
  prev *=0.5;
  c = mix( 
    c, 
    c +prev*0.5, smoothstep(0.005, 0.1, ffts));
  
  float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
  c = mix(c,vec3(gray),0.75);
  
  out_color = vec4(c,1.0)+ 1.0*vec4(inercia*(0.75+vec3(f)*2.85),1.0);
 
  
}