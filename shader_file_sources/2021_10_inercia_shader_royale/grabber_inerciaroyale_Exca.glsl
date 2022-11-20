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

float fft = 0.0;
float ffts = 0.0;
float ffti = 0.0;
float beat = 0.0;
float beatstep = 0.0;

vec3 repeat( vec3 p, vec3 c)
{
  vec3 q = vec3(0.0);
  vec3 q2 = mod( p+ 0.5*c,c)-0.5*c;
  return q2;
}

vec3 rotate( vec3 p, float x, float y, float z){
  mat3 rotx = mat3(1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
  
  return rotx*roty*rotz*p;
}



vec3 smoothUnion(vec3 a, vec3 b, float k)
{
  float h = clamp(0.5 + 0.5*(b.x-a.x)/k,0.0, 1.0);
  float d = mix(b.x,a.x,h)-k*h*(1.0-h);
  float s = step(a.x, b.x);
  return vec3(d, mix(a.y, b.y, s),0.0);
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize(target-cam);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross(forward, right));
  
  return normalize( forward*fov + right*uv.x + up*uv.y);
}

float sphere( vec3 p, float r){
  return length(p)-r;
}

float roundcube( vec3 p, vec3 b, float r){
  vec3 d = abs(p)-b;
  return min( max( d.x, max( d.y, d.z) ), 0.0)+length(max(d,0.0))-r;
}

float ground( vec3 p, float h){
  return p.y -h;
}
vec3 Union(vec3 a, vec3 b){
  return a.x < b.x ? a : b;
}

vec3 map( vec3 p ){
  
  vec2 id = floor(p.xz/8.0+0.5);
  
  vec3 cp = rotate(
    repeat(p, vec3(8.0, 0.0, 8.0)), 
    sin(p.y*0.1)*0.2, 
    ffts*sin(id.y+id.x+ ffti*4.0+ fGlobalTime+p.y+ffti*5.0)*2.0+sin(fGlobalTime*0.33+p.y-ffti*2.0)*4.0+ffti*5.0, 
    cos(p.y*0.1)*0.2 

  );
  vec3 c = vec3( roundcube(cp, vec3(0.4, 29.0, 0.4), 0.2), 1.0, 0.0);
  
  float h1 = texture(texNoise, p.xz*0.1+vec2(fGlobalTime*0.01-ffti*0.25, fGlobalTime*0.015)).r*0.5* (0.5+fft*1.0);
  float h2 = texture(texNoise, p.xz*0.1+vec2(fGlobalTime*0.015+0.17*ffti, -fGlobalTime*0.015)).r*0.5 * (0.25+ffts*2.0);
  
  float h = mix(h1,h2,0.5);
  
  vec3 gr = vec3( ground(p, h*2.0), 2.0, h);
  
  return smoothUnion(c,gr,2.5);
  
  return vec3(sphere(p, 0.5), 1.0, 0.0);
}
vec3 normal( vec3 p ){
  vec3 c = map(p);
  vec2 e = vec2( 0.1, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x);
}

float diffuse( vec3 p , vec3 l, vec3 n){
  return max(0.0, dot(n, normalize(l-p)));
}

vec3 march(vec3 cam, vec3 rd, out vec3 p, out float t)
{
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t+=r.x;
    if(r.x < 0.01){
      return r;
    }
    if(t > 50.0){
      t = 50.0;
      return vec3(-1.0);
    }
  }
  t = 50.0;
  return vec3(-1.0);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 col = vec3(1.0);
  
  fft = texture(texFFT, 0.25).r;
  ffts = texture(texFFTSmoothed, 0.25).r;
  ffti = texture(texFFTIntegrated,0.25).r;
  
  beat = floor(fGlobalTime*1.45);
  beat = mod( beat/4.0, 8.0);
  beatstep = fract( fGlobalTime*2.0);
  
  float travel = 3.0;
  
  float time = fGlobalTime*0.2;
  
  vec3 cam = vec3(
    sin(time)*6,
    2 + cos(time),
    cos(time)*6+time
  );
  vec3 target = vec3(
    0.0, 
    1.5+  cos(time*0.5), 
    time + cos(time*4.0)
  );
  vec3 light = vec3( sin(fGlobalTime)+5.0, 4.0, time+sin(time));
  float fov = 0.5;
  
  
  if(beat < 2.0){
    uv*= sin(uv);
  }
  else if(beat < 4.0){
    uv *= 1.0 + sin(uv.x*20.0 + time)*0.2 + cos(uv.y*20. + time)*0.2;
  }
  else if(beat < 6.0){
    uv *= 1.0 - sin(uv.x*20.0 + time)*0.2 - cos(uv.y*20. - time)*0.2;  
  }
  
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  
  
  vec3 p = vec3(0.0);
  vec3 res = march( cam, rd, p, travel);
  
  vec3 n = normal(p);
  if(res.y < 0.5){
    // Bg
  }
  else if(res.y < 1.5){
    //ground mat
    col = vec3(0.0,0.7,0.9)*diffuse(p, light, n);
  }
  else if(res.y < 2.5){
    //twister
    float ly = abs(sin((p.y+fGlobalTime)*10.0));
    col = mix(vec3(0.0,0.7,0.9), vec3(1.0, 0.7, 0.0), res.z*0.5)*diffuse(p, light, n);
    col += smoothstep(1.0, 4.0, p.y)*(0.5/ly);
  }
  
  col = mix( col, vec3(0.0,0.45,0.90), smoothstep( 10.0, 20.0, travel));
  
  
  
  out_color = vec4(col,1.0);
  
}