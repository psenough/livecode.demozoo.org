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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

float beat;
float beatStep;
float fft;
float fftS;
float fftI;
float glow;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float diffuse(vec3 p, vec3 l, vec3 n)
{
  return max( dot(n, normalize(l-p)),0.0);
}

vec2 barrelDistortion(vec2 uv, float k)
{
  float rd = length(uv);    
  float ru = rd * (1.0 + k * rd * rd);
  uv /= rd;
  uv *= ru;
  return uv;
}
vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0, 0, 0, cos(x),-sin(x),0, sin(x),cos(x));
  mat3 roty = mat3( cos(y), 0, sin(y), 0,1,0, -sin(y), 0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0, sin(z),cos(z), 0,0,0,1);
  return rotx*roty*rotz*p;
}


vec3 repeat( vec3 p, vec3 c )
{
  vec3 q = mod( p + 0.5*c, c)-0.5*c;
  return q;
}


vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward,right));
  
  return normalize( vec3( uv.x*right + uv.y* up + forward*fov ));
}

float cube( vec3 p, vec3 size)
{
  vec3 q = abs(p)-size;
  return length( max(q,0.0)+min(max(q.x,max(q.y,q.z)),0.0));
}

float roundcube( vec3 p, vec3 b, float r)
{
  vec3 d = abs(p)-b;
  return min(max(d.x, max(d.y,d.z)), 0.0) + length(max(d,0.0))-r;
}

float sphere(vec3 p, float r)
{
  return length(p) -r;
}

vec3 map( vec3 p, out vec3 id)
{
  if(mod(beat,16.0) < 4.0)
  {
    p = rotate( p, 0.0, 0.0, p.z*-0.5);
  }
  else if(mod(beat,16.0) < 8.0)
  {
    p = rotate( p, 0.0, p.z*0.1, 0.0);   
  }
  else if(mod(beat,16.0) < 12.0)
  {
    p = rotate( p,  p.z*0.1, 0.0,sin(fftI)*p.z*0.1);   
  }
  else 
  {
    p = rotate( p, 0.0, 0.0, p.z*0.1);   
  }
    
  
  
  p+=vec3(-fGlobalTime,0,0);
  id = floor(p *1.0 -0.5);
  float idf = sin(id.x+id.y+id.z);
  
  float s1 = sphere(p, 0.5);
  
  vec3 cp = repeat(p, vec3(2.0, 2., 2.0));
  cp = rotate(cp, id.x, id.y, id.z);
  float c1 = roundcube(cp, vec3(
    0.2+idf*0.1, 
    sin(fftI*10.0+idf)*0.1+ 0.2+idf*0.1,
    0.2)
    ,abs(sin(p.x+fftI)*fftS*8.0+cos(p.y-fftI)*fftS*8.0));
  
  return vec3(c1,0,0);
}

vec3 march( vec3 cam, vec3 rd, out float t, out vec3 p, out vec3 id)
{
  t = 0.0;
  for(int i = 0; i < 200; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p, id);
    /*float bx = cube(
      repeat( p + vec3(1.0), vec3(2.0,0,0)),
      vec3(0.00001,100,100));
    float bz = cube(
      repeat( p + vec3(1.0), vec3(0.0,0,2)),
      vec3(100,100,0.00001));
    float by = cube(
      repeat( p + vec3(1.0), vec3(0.0,2,0)),
      vec3(100,0.0001,100));
    
    float delta = min(max(0.1, bx), r.x);
    delta = min( max(0.1, bz), delta);
    delta = min( max(0.1, by), delta);
    */
    float delta = r.x;
    t+=delta*0.5;
    
    if(r.x < 0.001)
    {
      return r;
    }
  }
  return vec3(-1);
}

vec3 marchV( vec3 cam, vec3 rd, out float t)
{
  vec3 sum = vec3(0.);
  t = 0.0;
  vec3 id=vec3(0.);
  for(int i = 0; i < 100; i++)
  {
    vec3 p = cam + rd*t;
    vec3 r = map(p, id);
    float d = max(0.1, r.x);
    t+=d;
    if(r.x < 0.01){
      glow += abs(r.x);
    }
    if(r.x < 0.001)
    {
      sum.y+= 0.1*d;
    }
  }
  return sum;
}

vec3 normal( vec3 p)
{
  vec3 id = vec3(0.);
  vec3 c = map(p,id);
  vec2 e = vec2(0.001, 0.0);
  return normalize( 
    vec3( 
      map(p+e.xyy,id).x,
      map(p+e.yxy,id).x,
      map(p+e.yyx,id).x
    )-c.x
  );
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  beat = floor(fGlobalTime*2.9166);
  beatStep = fract( fGlobalTime*2.9166);
  fft = texture(texFFT, 0.2).r;
  fftS = texture(texFFTSmoothed, 0.2).r;
  fftI = texture(texFFTIntegrated, 0.2).r;
  

  uv = barrelDistortion( uv, fftS*50.0);
    
  float time = fGlobalTime;
  
  vec3 cam = vec3(0,sin(floor(beat/8.0)),1);
  vec3 target = vec3(0,0,10);
  vec3 light1 = vec3(sin(time), 10, cos(time));
  float fov = 2.2;
  
  vec3 c = vec3(0.0);
  float travel = 0.0;
  vec3 p = vec3(0.0);
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 id = vec3(0.);
  
  vec3 obj = march( cam, rd, travel, p, id);
  if(obj.y > -0.5)
  {
    vec3 n = normal(p);
    
    c = vec3(1.0)*diffuse(p, light1, n) * vec3( sin(id.x), cos(id.y), sin(-id.z));
  }
  
  float vTravel = 0.0;
  vec3 vol = marchV( cam, rd, vTravel);
  
  c = mix(c, vec3(0.0),  smoothstep( 15., 35., travel));
  
  c+=vol*fftS*300.0;
  c*=0.7+glow*fftS*350.;
  
  vec3 prev = texture(texPreviousFrame, (uv*0.9)*0.5+0.5 ).rgb;
  
  c = mix(c*c, c, fftS*55.0);
  
	out_color = vec4(c+prev*0.5,1.0);
}




























































