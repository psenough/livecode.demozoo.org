#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDfox;
uniform sampler2D texDojoe;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float ffts;
float ffti;
float beat;
float beatstep;
float bar;

float glow;

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
  return rotx*roty*rotz * p;
}

vec3 repeat( vec3 p, vec3 q)
{
  return mod( p +q*0.5, q) - q*0.5;
}


vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross( forward, right));
  return normalize( forward*fov + right*uv.x + up*uv.y);
}

vec3 texmap( vec3 p, vec3 n)
{
  return mat3( texture(texDojoe, p.yz).rgb, texture(texDfox, p.xz).rgb, texture(texDojoe,p.xy).rgb)*n;
}

float torus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x, p.y);
  return length(q)-t.y;
}

float roundbox( vec3 p, vec3 b, float r)
{
  vec3 d = abs(p)-b;
  return min(max(d.x, max(d.y, d.z)), 0.0)+ length( max(d, 0.0))-r;
}

float sphere( vec3 p, float r)
{
  return length(p) -r;
}

float ground(vec3 p, float h)
{
  return p.y-h;
}
  
vec3 map( vec3 p)
{
  float g = ground(p, -3.0);
  
  
  p*=1.0-smoothstep(0.0, 0.15,ffts*5.0);
  
  p = rotate(p, time*1.2, time*0.25, time*0.1);
  
  float tc = roundbox( p, vec3(0.1, 0.1, 2.1), 0.05);
  
  float t = torus( p, vec2(2.5, 0.15));
  
  //t = min(tc,t);
  
  p = rotate(p, time*1.2, time*0.25, time*0.1);
  
  float t1 = torus( p, vec2(2.0, 0.15));
  p = rotate(p, time*1.2, time*0.25, time*0.1);
  float t2 = torus( p, vec2(1.5, 0.15));
  p = rotate(p, time*1.2, time*0.25, time*0.1);
  float t3 = torus( p, vec2(1.0, 0.15));
  
  
  
  
  t = min( t,t1);
  t = min( t,t2);
  t = min( t,t3);
  
  float mat = t < g ? 1.0 : 2.0;
  t = min(t,g);
  
  return vec3(t, mat, 1.0);
}

vec3 march( vec3 cam ,vec3 rd, out vec3 p ,out float t)
{
  float lowest = 999.0;
  for(int i = 0; i < 200; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t +=r.x*0.5;
    lowest = min( lowest, r.x);
    
    if(r.x < 0.05) glow +=r.x;
    
    if(r.x < 0.001){
      return r;
    }
    if(t > 50.0){
      t = 50.0;
      return vec3(lowest, -1,-1);
    }
  }
  return vec3(lowest, -1,-1);
}

vec3 normal( vec3 p)
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map( p + e.xyy).x,
    map( p + e.yxy).x,
    map( p + e.yyx).x
  )-c.x);
}
  
float light( vec3 p, vec3 l, vec3 n)
{
  return max( 0.0, dot(n, normalize( l- p)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 vuv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  ffts = texture(texFFTSmoothed, 0.1).r;
  ffti = texture(texFFTIntegrated, 0.1).r;
  
  beat = floor( fGlobalTime * 136.0/60.0);
  beatstep = fract( fGlobalTime * 136.0/60.0);
  bar = floor( beat /8.0);
  
  time = ffti*2.5 + fGlobalTime*0.1;
  
  vec3 col = vec3(0.0);
  vec3 cam = vec3(
    sin(time*0.1-bar*2.0)*10.0,
    abs(sin(time*0.05 + bar*3.0)*7.9)-1.5,
    cos(time*0.1+bar*1.1)*7.0
    );
  vec3 target = vec3(0,0,0);
  
  target -= cam*0.25;
  
  float fov = 2.2 + sin(bar*6.3);
  
  vec3 light1 = vec3(sin(time*10.0), 10.0, 0.0);
  
  vec3 rd = getcam(cam, target, uv, fov);
  
  rd *= 1.0 +0.05* vec3( sin(time*0.25), cos(time*0.3), sin(time*0.4));
  
  vec3 p = cam; float t = 2.0;
  vec3 res = march( cam, rd, p, t);
  
  vec3 gold = vec3(1.8, 1.5, 0.5);
  
  if(res.y > 1.5){
    
    vec3 n= normal(p);
    vec2 pat = vec2( 
      step( mod(p.x, 1.0),0.5),
      step( mod(p.z, 1.0),0.5)
    );
    col = mix(gold, gold*0.25, pat.x-pat.y) * light(p,light1,n)*0.25;
    
    col = max( col, gold*0.25) *  texmap(p*0.25,n*1.0) * 5.0;
    
    vec3 outp = vec3(0.0);
    float outt = 0.0;
    vec3 shadow = march( p + n * 0.1, normalize( light1-p), outp, outt)*0.95;
    
    col *=0.125+ 1.0*smoothstep( 0.0, 0.5, shadow.x);
    
    
  }
  else if(res.y > -0.5){
    
    vec3 n= normal(p);
    col = gold * light(p,light1,n);
    
    vec3 refrd = reflect( rd, n);
    vec3 refp = p;
    vec3 refc = vec3(0.0);
    float reft = 0.0;
    vec3 refres = march( p+rd*0.01, refrd, refp, reft);
    
    vec3 refn = normal(refp);
    if(refres.y > 1.5)
    {
      col = vec3(1.0) * light(refp,light1,refn);
    }
    else if(refres.y > 0.5)
    {
      vec2 pat = vec2( 
        step( mod(refp.x, 1.0),0.5),
        step( mod(refp.z, 1.0),0.5)
      );
      refc = col = mix(gold, gold*0.25, pat.x-pat.y) * light(refp,light1,refn);
    }
    col = mix(col, refc, 0.5);
    
  }
  
  float fft2 = texture(texFFTSmoothed, vuv.x).r*25.0;
  //col += 0.25* smoothstep(0.9, 1.0,length(fft2-uv.y-1.0));
  
  col +=gold* glow*0.04;
  
  col = mix( col, vec3(0.0), smoothstep(5.0, 50.0, t));
  
  
  vuv -=0.5;
  vuv *= 0.97;
  vuv +=0.5;
  
  
  vec3 previous = texture( texPreviousFrame, vuv).rgb;
  col += previous * 0.9 * smoothstep(0.0, 0.1, ffts*10.0);
  
  if(mod(bar, 5.0) < 0.5) col.rgb = col.bgr;
  else if(mod(bar, 5.0) < 1.5) col.rgb = col.grb;
  else if(mod(bar, 5.0) < 2.5) col.rgb = col.gbr;
  else if(mod(bar, 5.0) < 3.5) col.rgb = vec3(length(col)*0.5);
  
  
	out_color = vec4( col, 1.0);;
}











