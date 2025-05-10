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
vec3 cam = vec3(0.0);
vec3 camdir = vec3(0.0);
float bm=0.0;

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
  return rotx*roty*rotz*p;
}


vec3 getcam(vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize(target-cam);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross(forward, right));
  
  return normalize( forward*fov + right *uv.x + up*uv.y);
}

float sphere(vec3 p, float r)
{
  return length(p)-r;
}

float roundcube( vec3 p, vec3 b, float r)
{
  vec3 d = abs(p)-b;
  return min(max(d.x, max(d.y, d.z)), 0.0)+length(max(d,0.0))-r;
}


float ground( vec3 p, float h)
{
  return p.y - h;
}

float U(float a, float b){
  return min(a,b);
}

vec3 map( vec3 p)
{
  
  vec3 cp = cam+camdir*5.0;
    
  vec3 rp = rotate(p-cp,fftI*3.,fftI*1.0,0.0);
  rp*= 1.0+beatStep*smoothstep(0.0,0.015,fftS);
  float s = 9999.0;
  if(bm< 4.0)
  {
  s = roundcube(rotate(rp, smoothstep(0.0, 0.25,beatStep)*3.14,0.0, 0.0),vec3(1.0),0.2);
  s = U(s,roundcube(rp-vec3(2.5, 0.0, 0.0),vec3(0.5),0.2));
  s = U(s,roundcube(rp+vec3(2.5, 0.0, 0.0),vec3(0.5),0.2));
  s = U(s,roundcube(rp-vec3(0.0, 0.0, 2.5),vec3(0.5),0.2));
  s = U(s,roundcube(rp+vec3(0.0, 0.0, 2.5),vec3(0.5),0.2));
  }
  else
  {
  s = sphere(rotate(rp, smoothstep(0.0, 0.25,beatStep)*3.14,0.0, 0.0),1.5);
  s = U(s,sphere(rp-vec3(2.5, 0.0, 0.0),0.5+fftS*5.0));
  s = U(s,sphere(rp+vec3(2.5, 0.0, 0.0),0.5+fftS*5.0));
  s = U(s,sphere(rp-vec3(0.0, 0.0, 2.5),0.5+fftS*5.0));
  s = U(s,sphere(rp+vec3(0.0, 0.0, 2.5),0.5+fftS*5.0));  
  }
  
  p.z-=sin(fftI*0.35)*50.0;
  p.x-=cos(-fftI*0.15)*50.0;
  
  
  float h = texture( texNoise, p.xz*0.025+fftI*0.1).r*2.0+texture( texNoise,0.2*fftI+ p.xz*0.025+0.78).r*0.75;
  float hLrg = smoothstep( 0.1, 0.5, texture( texNoise, p.xz*0.01).r);
  float hMnt = smoothstep(0.35, 0.5,texture( texNoise, p.xz*0.01).r)*255.*fftS*10.;
  
  h += hLrg + hMnt;
  
  float ho = h;
  h = max(0.6, h);
  
  float g = ground(p, h);
  return vec3(U(s,g),h,ho);
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t, out int steps) 
{
  t = 1.5;
  for(int i = 0; i < 100; i++)
  {
    steps = i;
    p = cam + rd*t;
    vec3 r = map(p);
    t += r.x*0.75;
    if(r.x < 0.01) return r;
    if(t > 50.0) {
      t = 50.0;
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
}

vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2(0.1, 0.0);
  return normalize(vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x);
}

float light( vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot( n, normalize(l-p)));
}

float time;

vec3 calc(vec2 uv )
{
  vec3 bgCol = vec3( 0.5, 0.5, 1.05);
  vec3 sun = vec3( 10,10,10);
  
	vec3 col = vec3(0.0);
  
  time = fGlobalTime*0.25;
  
  cam = vec3( sin(time) ,12.0+cos(time)*5.5,2);
  vec3 target = vec3(0,cam.y-(3.25+sin(time)*3.25),0);
  float fov = 0.6+sin(time)*0.3;
  vec3 rd = getcam(cam, target, uv, fov);
  
  camdir = normalize(target - cam);
  
  vec3 p = cam;
  float t = 0.0;
  int steps = 0;
  vec3 mat = march( cam, rd, p, t, steps);
  
  vec3 n = normal(p);
  bgCol *=0.5+ min(0.05,fftS) * abs( smoothstep(0.5,1.0,sin( t*1.2+fftI*50. )))*150.8*min(1.0,p.y) * smoothstep(80., 30., t)*0.8;
  
  if(mat.y < -0.5){
    //bg
    col = bgCol;
  }
  else if(mat.y < 50.5)
  {
    
    float id = floor(p.x)+floor(p.z);
    
    if(mat.z < 0.6)
    {
      col =vec3(0.2, 0.25,0.85)*(mat.z);
    }
    else if( mat.z < 1.2)
    {
      col = mix( vec3( 0.2, 0.4,0.3), vec3( 0.4,0.4,0.3), (mat.z-0.6)/0.6);
    }
    else
      col = mix( vec3( 0.4,0.4,0.3), vec3(1.0), (mat.z-1.2)/0.6);
    
    if(t < 1.0)
    {
      col = mix( vec3( 1.0, 0.0, 0.0)*col, col, smoothstep(3.0, 5.5, t));
    }
    
    col = col*light(p, sun, n);
    
  }
  
  col =mix(col, bgCol*0.4, smoothstep( 5.0, 50.0, t));
  
  col*=2.0;
  return col;
}
vec2 barrel( vec2 uv, float k)
{
  float rd = length(uv);
  float ru = rd*(1.0+k*rd*rd);
  uv/=rd;
  uv*=ru;
  return uv;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  fft = texture(texFFT, ouv.x).r;
  fftS = texture(texFFTSmoothed,0.2).r;
  fftI = texture(texFFTIntegrated, 0.1).r;
  beat = floor(fGlobalTime*1.45);
  beatStep = fract( fGlobalTime*2.0);
  bm = mod(beat/4.0, 8.0);
  
  
  vec3 col = calc(uv);
  
  col += calc( barrel(uv*1.2,10.5))*min(1.0,smoothstep(0.0, 0.05,fftS)*2.0);
  col += calc( barrel(uv*1.5,-fftS*1024.0))*min(1.0,smoothstep(0.0, 0.02,fftS)*5.0);
  
  
  vec3 previous = texture(texPreviousFrame, ouv).rgb;
  
  float rot1 = sin( fftI*2.5);
  float rot2 = sin( fftI*0.65);
  
  
  vec2 cuv = ouv - 0.5;
  
  vec3 previousR = texture(texPreviousFrame, 0.5+rotate( vec3(cuv,0.0), 0.0, 0.0,rot1).xy).rgb;
  vec3 previousRR = texture(texPreviousFrame, 0.5+rotate( vec3(cuv,0.0), 0.0, 0.0,rot2).xy).rgb;
  
  col*=0.95;
  col=mix(col, smoothstep(vec3(0.0), vec3(1.0),col), beatStep);
  //col += (previousR+previousRR)*smoothstep(0.0, 1.0,15.*fftS)*0.25;
  
  col = clamp( col, vec3(0.0), vec3(1.0));
  
  if(bm < 4.0)
  {
  col = vec3(1.0)-col;
  col.rgb = col.gbr;
  }
  
  
	out_color = vec4(col+ previous*0.0, 1.0);
}





























































