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

vec3 C1 = vec3( 1.0, 1.0, 1.0);
float time = fGlobalTime;
float ffts = 0.0;
float ffti = 0.0;
float beat = 0.0;
float bar = 0.0;
float beats=0.0;

float glow = 0.0;

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross( vec3(0,1,0), forward));
  vec3 up = normalize( cross( forward, right));
  return normalize( uv.x * right + uv.y* up+ forward * fov);
}

vec3 repeat( vec3 p, vec3 q)
{
  return mod(p+q*.5, q)-.5*q;
}

float sphere( vec3 p, float r)
{
  return length(p)-r;
}

float oct( vec3 p, float s)
{
  p = abs(p);
  return (p.x+p.y+p.z-s)*0.57;
}

float circle( vec2 p, float r){
  return length(p)-r;
}

float ground( vec3 p, float h )
{
  return p.y - h;
}

vec3 U( vec3 a, vec3 b)
{
  return a.x < b.x ? a : b;
}

vec3 map( vec3 p, float refon)
{
  vec3 sp = p;
 
  float refonAdd = 0.0;
  if( bar < 2.0) refonAdd = 0.7;
  
  refon += refonAdd;
  
  if(refon > 0.5) sp = repeat( vec3( 10.0, 0.0, 10.0), sp);
  float s1 = sphere(sp + vec3(0.0, -0.5 + 0.25*sin(beats*3.14), 0.0), 1.75);
  float o1 = oct( repeat(p, vec3(0.5 + sin(ffti*10.0)*0.356,0.0, 0.2+ sin(ffti*3.0)*0.156)), 0.41 + 0.3*sin(ffti*12.0));
  
  //if(refon < 0.5)
    s1 = max( s1, o1);
    
  
  float g1 = ground(p, 0.0);
  
  vec3 S1 = vec3( s1, 1.0, 1.0);
  vec3 G1 = vec3( g1, 0.0, 1.0);
  
  return U(S1, G1);
}

vec3 march(vec3 cam, vec3 rd, float refOn, out vec3 p, out float t, out float minD)
{
  minD = 9999.0;
  for(int i = 0;i  < 100; i++)
  {
    p = cam+ rd*t;
    vec3 r = map(p,refOn);
    t+=r.x;
    glow += r.x * (refOn > 0.5 ? 1.0: 0.0);
    minD = min(minD, r.x);
    if(r.x < 0.001){
      return r;
    }
    if(t > 50.0){
      t = 50.0;
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
}

vec3 normal( vec3 p)
{
  vec2 e = vec2(0.001, 0.0);
  vec3 c = map(p, 0.0);
  return normalize( vec3(
    map(p+e.xyy,0.0).x,
    map(p+e.yxy,0.0).x,
    map(p+e.yyx,0.0).x
  )-c.x);
}

float diffuse( vec3 p, vec3 l, vec3 n)
{
  return max( 0.0, dot(normalize( l-p), n));
}

float interference( vec2 uv)
{
  float mp = 0.5+sin(ffti);
  if( bar < 1.0) mp = 0.03;
  else if( bar < 2.0) mp = 0.70;
  else if( bar < 3.0) mp = 0.1;
  
  vec2 off1 = vec2( sin(time*0.4+ffti), cos(time*0.325))*30.0;
  vec2 off2 = vec2( sin(time*0.34-ffti), cos(time*0.2))*20.0;
  vec2 off3 = vec2( sin(time*0.74+ffti), cos(time*0.15))*17.0;
  
  
  float s1 = circle( mp*70.0*uv+off1, 0.15);
  float s2 = circle( mp*90.0*uv+off2, 0.95);
  float s3 = circle( mp*150.0*uv+off3, 0.05);
  
  float s = sin(s1) + sin(s2) + sin(s3);
  
  return s;
  
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  ffts = texture( texFFTSmoothed, 0.2).r;
  ffti = texture( texFFTIntegrated, 0.2).r;
  
  beat = floor( time/ 60.0 * 120.0);
  beats = fract( time/ 60.0 * 120.0);
  bar = mod(floor( beat/ 4.0), 4.0);
  
  vec3 c = vec3(0.0);
  
  vec3 cam = vec3( 
    sin(ffti)*3.0,
    sin(ffti*0.2)*1.1+2.0,
    sin(ffti*0.7)*10.1
  );
  vec3 target = vec3(0,0,0);
  float fov = 1.2 + sin(ffti)*1.1 ;
  vec3 light1 = vec3( sin(time)*3.0, 3.0, 0.0);
  
  float int1 = interference( uv * (2.2+abs(sin(ffti*2.0))*1.5));
  target += int1 * step(0.002 , ffts) * 3.0;
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  float travel = 0.0; float minD = 0.0;
  vec3 p = cam;
  vec3 res = march( cam, rd, 0.0, p, travel, minD);
  
  if(res.y < -0.5){
    
  }
  
  if(res.y >-0.5 && res.y < 0.5)
  {
    vec3 n = normal(p);
    c = vec3(interference(p.xz))*C1 * diffuse(p, light1, n);
    
    vec3 rRD = reflect( rd, n );
    vec3 rP =p;
    float rTravel = 0.0; float rMinD = .0;
    vec3 rRES = march( p + n*0.1, rRD, 0.0, rP, rTravel, rMinD);
    
    c *= 0.25+0.75* smoothstep( 0.0, 0.1, rMinD);
    
  }
  else if(res.y < 1.5){
    vec3 n = normal(p);
    c = C1 * diffuse(p, light1, n);
    
    vec3 rRD = reflect( rd, n );
    vec3 rP =p;
    float rTravel = 0.0; float rMinD = .0;
    vec3 rRES = march( p + n*0.1, rRD, 1.0, rP, rTravel, rMinD);
    
    vec3 rC = vec3(0.0);
    if(res.y >-0.5 && res.y < 0.5)
    {
      vec3 rN = normal(rP);
      rC = vec3(interference(rP.xz))*C1 * diffuse(rP, light1, rN);
      
      c += rC;
      
    }
    else if(res.y < 1.5){
      vec3 rN = normal(rP);
      rC = C1 * diffuse(rP, light1, rN);
      
      c += rC;
    }
    
    
  }
  
  float intf = interference(uv);
  intf = smoothstep( 0.5, 1.0, intf)*smoothstep(0.1, 0.4,ffts)*0.3;
  
  c += smoothstep(0.1, 0.0,glow)*0.2;
  
  c = mix( c, C1, intf);
  
  if( bar < 1.0) c = c.bgr;
  else if( bar < 2.0) c = c.rbg;
  else if( bar < 3.0) c = c.grb;
  
	
  
  
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv *= 0.9+smoothstep(0.0, 0.1, ffts)*0.1;
  uv += 0.5;
  
  vec3 prev = texture( texPreviousFrame, uv).rgb;
  
  c = mix( c, c+prev, smoothstep( 0.05, 0.34, ffts*70.0));
  
  out_color = vec4(c, 1.0);
  
}



















