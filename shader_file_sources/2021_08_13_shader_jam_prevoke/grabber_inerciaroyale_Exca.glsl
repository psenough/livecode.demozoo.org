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
float fftS = 0.0;
float fftI = 0.0;
float beat = 0.0;
float beatStep = 0.0;
float bm = 0.0;

vec3 cam = vec3(0.0);

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d)
{
  return a + b*cos(6.28318* (c*t+d));
}

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3(1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
  return rotx*roty*rotz*p;
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize(target - cam);
  vec3 right = normalize(cross( vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  
  return normalize( forward*fov + right * uv.x + up * uv.y);
}

vec3 repeat( vec3 p, vec3 c) 
{
  vec3 q = mod(p+0.5*c, c)-0.5*c;
  return q;
}

float ground(vec3 p, float h)
{
  return p.y -h;
}

float sphere(vec3 p, float r)
{
  return length(p)-r;
}
float roundcube( vec3 p, vec3 b, float r)
{
  vec3 d = abs(p)-b;
  return min(max(d.x, max(d.y, d.z)),0.0)+length(max(d,0.0))-r;
}

float prism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float U(float a, float b){
  return min(a,b);
}

vec3 map( vec3 p)
{
  vec2 id = floor((p.xz+2.0)/4.0-2.0) ;
  
  float beatstep = fract( fGlobalTime*0.5+(id.x+id.y)/2.0);

  float distsize = length(p-cam);
  
  vec3 cp = repeat(p, vec3(4,4, 4));
  cp = rotate( cp, 0.0, 0.0, id.x+smoothstep(0.0, 1.0,beatstep)*3.14/4.0 + beat*3.14/8.0);  
  float g = ground(p, -3.0);
  
  float pr = prism(cp, vec2(
  1.20+smoothstep(10.0, 30.0,distsize),
  0.7+ (sin(id.x+fGlobalTime)-cos(id.y-fGlobalTime*0.5))+smoothstep(10.0, 30.0,distsize)
  ));
  
  return vec3(U(pr,g),1,1);
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t, out int steps)
{
  t = 0.0;
  for(int i = 0; i < 140; i++)
  {
    steps = i;
    p = cam + rd*t;
    
    vec3 r = map(p);
    float bx = roundcube(
      repeat( p + vec3(2.0), vec3(4.0,0,0)),
      vec3(0.00001,100,100),0.0 );
    float bz = roundcube(
      repeat( p + vec3(2.0), vec3(0.0,0,4)),
      vec3(100,100,0.00001),0.0);
    float by = roundcube(
      repeat( p + vec3(2.0), vec3(0.0,4,0)),
      vec3(100,0.0001,100),0.0);
    
    float delta = min(max(0.1, bx), r.x);
    delta = min( max(0.1, bz), delta);
    delta = min( max(0.1, by), delta);
    
    
    t += delta;
    if(r.x < 0.001) return r;
    
    if(t > 50.0){ 
      t = 50.0;
      return vec3(-1);
    }
  }
  return vec3(-1);
}

vec3 marchInside( vec3 cam, vec3 rd, out vec3 p)
{
  float t = 0.0;
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t += abs(r.x);
    if(r.x > 0.001) return r;
  }
  t = 100.0;
  return vec3(-1);
}


vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2(0.1, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x );
}

float light( vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot(n, normalize(l-p)));
}

vec3 getcol( vec3 p)
{
    vec2 id = floor((p.xz+2.0)/4.0-2.0) ;
    vec3 hitCol = palette( abs(sin(id.x+id.y)), vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5,0.5), vec3(1.0, 1.0, 1.0), vec3(0.90, 0.8,0.4));
    return hitCol*2.0;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  vec2 puv = uv;
  puv -=0.5;
  puv*=0.95;
  puv += 0.5;
  vec3 previous = texture(texPreviousFrame, puv).rgb;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  beat = floor( fGlobalTime*2.0);
  beatStep = fract( fGlobalTime*2.0);
  
  fft = texture(texFFT, 0.2).r;
	fftS = texture(texFFTSmoothed, 0.2).r;
	fftI = texture(texFFTIntegrated, 0.1).r;
	
  float bm = mod( beat/4.0, 6.0);
  
  
  vec3 col = vec3(0.);
  
  cam = vec3(4,10.0,0);
  vec3 target = vec3(3,8,0);
  
  target = cam + vec3(
    sin(fGlobalTime*0.1)*10.0,
    cos(fGlobalTime*0.25)*10.0,
    sin(fGlobalTime*0.5)*10.0
  );
  
  float fov = 0.8;
  
  vec3 l1 = vec3(sin(fGlobalTime)*10.0, 10.0, 10.0);
  
  vec3 rd = getcam( cam, target, uv, fov);
  vec3 p = cam;
  float t = 0.0;
  int steps = 0;
  
  vec3 material = march(cam, rd, p, t, steps);
  vec3 n = normal(p);
  if(material.y < -0.5)
  {
    //bg
  }
  else
  {
    vec3 hitCol = getcol(p);
    
    col = hitCol*(0.5+.5*light(p,l1,n));
    
    
    
    vec3 rRD = reflect( rd, n );
    
    vec3 pReflect = p;
    float tReflect = 0.0; int stepsReflect = 0;
    vec3 reflectMat = march( p+rRD*0.1, rRD, pReflect, tReflect, stepsReflect);
    
    if(reflectMat.y < -0.5){
      col = mix( col, vec3(0.5), 0.5);
    }
    else{
      vec3 refN = normal(pReflect);
      
      vec2 id = floor((pReflect.xy+2.0)/4.0-2.0) ;
    
      
      vec3 rc = normalize(pReflect);
      vec3 rhitCol = getcol(pReflect);
      
      col = mix( 
        col, 
        vec3(1.0,0.5, 0.2)*(0.5+0.5*light(pReflect,l1,refN)),
        0.5);
    }
  }
  
  vec3 grnd = vec3(0.75 + 0.2*( sin(p.z*10.0+fftI*5.)+sin(p.x*10.0-fftI*20.)));
  
  if(p.y < -2.99) col = mix( grnd, col, 1.0);
  
  col = mix(col, vec3(0.3, 0.3, 0.3), smoothstep( 30.0, 50.0, t));
  
  col = mix(col,col+ (previous-col) * smoothstep(0.0, 0.025,fftS),0.85);
  
	out_color = vec4(col,1.0);
  
}




















