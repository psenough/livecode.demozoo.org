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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float ffts = 0.0;
float ffti;
float beat;
float beatstep;
float bar;

float glow = 0.0;

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross( vec3(0,1,0), forward));
  vec3 up = normalize( cross( forward, right));
  return normalize( forward*fov + uv.y * up + uv.x * right);
}

float sphere(vec3 p , float r)
{
  return length(p)-r;
}

float ground(vec3 p, float h)
{
  return  p.y-h;
}
float wall(vec3 p, float x)
{
  return p.x-x;
}

vec3 repeat( vec3 p, vec3 q)
{
  return mod(p +0.5*q, q) -q*0.5;
}

vec3 map( vec3 p)
{
  float g = ground(p, 0.0);
  float wl = wall(p, -4.0);
  float wr =-wall(p, 4.0);
  g = min(wl,g);
  g = min(wr,g);


  vec3 bp = repeat( p, vec3( 0.0, 0.0, 10.0));
  
  vec3 bounce = vec3( 0.0, -abs(sin(time*1.5)*0.5)-0.5, 0.0);
  float s = sphere(bp+bounce, 0.5+ffts*15.0);

  vec3 bounce2 = vec3( 2.0, -abs(sin(time*0.5)*1.25)-0.5, 2.0);
  float s2 = sphere(bp+bounce2, 0.5+ffts*15.0);
  vec3 bounce3 = vec3( -1.5, -abs(sin(time*1.25)*1.1)-0.5, 0.0);
  float s3 = sphere(bp+bounce3, 0.5+ffts*15.0);
  vec3 bounce4 = vec3( 0.7, -abs(sin(time*1.75))-0.5, -3.0);
  float s4 = sphere(bp+bounce4, 0.5+ffts*15.0);

  s = min( s, s2);
  s = min( s, s3);
  s = min( s, s4);
  
  
  float mat = g < s ? 1.0 : 2.0;
  
  s = min(g,s);
  
  
  
  return vec3( s, mat, 1.0);
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t)
{
  for(int i = 0;i  < 250; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p);
    t += r.x*0.5;
    if( r.x < 2.0){
      glow +=0.05;
    }
    
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
  vec3 c = map( p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map(p+e.xyy).r,
    map(p+e.yxy).r,
    map(p+e.yyx).r
  
  )-c.x);
}

float light(vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot( n, normalize(l-p)));
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
  bar = floor( beat / 4.0);
  
  time = fGlobalTime*0.1 + ffti*2.5;
  
	vec3 col = vec3(0.0);
  vec3 cam = vec3(0,2,2);
  
  cam += abs(sin(bar)*2.5);
  
    
  vec3 target = vec3(0,1,-5);
  vec3 light1 = vec3(sin(time)*10.0,10.0,0);
  float fov = sin(bar*3.1)*1.5 + 3.0;
  
  
  
  
  
  vec3 rd = getcam( cam, target, uv, fov);
  vec3 p = cam; float t = 0.0;
  vec3 res = march( cam, rd, p, t);
  
    vec3 n = normal(p);
  
  if(res.y > 1.5)
  {
    vec3 refrd = reflect( rd, n);
    vec3 refp = p;
    float reft = 0.0;
    vec3 refres = march( p + refrd*0.01, refrd, refp, reft);
    vec3 refn = normal( refp);
    
    vec3 refc = vec3(0.0);
    if(refres.y > 1.5)
    {
      vec3 rrefrd = reflect( refrd, n);
      vec3 rrefp = refp;
      float rreft = 0.0;
      vec3  rrefres = march( refp + rrefrd*0.01, rrefrd, rrefp, rreft);
      vec3 rrefn = normal( rrefp);
      
      vec3 refc = vec3(0.0);
      if(rrefres.y > 1.5)
      {
        vec2 pat = vec2(
          step( mod(time+ rrefp.x+rrefp.y, 1.0), 0.5),
          step( mod(-time+ rrefp.z, 1.0), 0.5)
        );
        
        refc = mix( vec3(1.0, 0.5, 0.0), vec3(0.0, 0.5, 1.0), pat.x+pat.y) *  vec3(1.0)*(0.5+light(rrefp,light1,rrefn)*0.75);
        
      }
      else
      {
        vec2 pat = vec2(
          step( mod(time+ rrefp.x+rrefp.y, 1.0), 0.5),
          step( mod(-time+ rrefp.z, 1.0), 0.5)
        );
        
        refc = mix( vec3(1.0, 0.5, 0.0), vec3(0.0, 0.5, 1.0), pat.x+pat.y) *  vec3(1.0)*(0.5+light(rrefp,light1,refn)*0.75);
        
      }
      col = mix(col, refc, 0.5);
      
    }
    else
    {
      vec2 pat = vec2(
        step( mod(time+ refp.x+refp.y, 1.0), 0.5),
        step( mod(-time+ refp.z, 1.0), 0.5)
      );
      
      col = mix( vec3(1.0, 0.5, 0.0), vec3(0.0, 0.5, 1.0), pat.x+pat.y) *  vec3(1.0)*(0.5+light(refp,light1,refn)*0.75);
      
    }
    col = mix(col, refc, 0.5);
    
    
  }
  else if(res.y > -0.5){
    vec2 pat = vec2(
      step( mod(time+ p.x+p.y, 1.0), 0.5),
      step( mod(-time+ p.z, 1.0), 0.5)
    );
    
    col = 0.5* mix( vec3(1.0, 0.5, 0.0), vec3(0.0, 0.5, 1.0), pat.x+pat.y) *  vec3(1.0)*(0.5+light(p,light1,n)*0.75);
  }
  
  vec3 previous = texture( texPreviousFrame, vuv).rgb;
  
  col += glow*0.1*vec3(1.0, 0.5, 0.0);
  
  col += previous * 0.5 + smoothstep(0.0, 0.1, ffts);
  
  out_color = vec4( col, 1.0);

 }
 
 
 
 
 
 
 
 
 
 
 