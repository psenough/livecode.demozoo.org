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
float time = fGlobalTime;
float ffts = 0.0;
float beat = 0.0;
float bar = 0.0;

vec3 repeat( vec3 p, vec3 q)
{
  return mod( p +0.5*q,q)-0.5*q;
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward =normalize( target -cam);
  vec3 right = normalize( cross( vec3(0,1,0), forward));
  vec3 up = normalize( cross( forward, right));
  return normalize( forward*fov + uv.x * right + uv.y* up);
}
float sphere(vec3 p, float r)
{
  return length(p) -r;
}
float oct( vec3 p, float s)
{
  p = abs(p);
  return (p.x + p.y + p.z -s)*0.577;
}

vec3 map(vec3 p, float glow)
{
  
  float h = mod( bar, 4.0) * 2.0 + 0.5;
  vec3 ro = repeat( p, vec3( 0.15, sin(h)*0.5, 0.15));
  vec3 so = repeat( p, vec3( 0.45, 1.0, 0.74)*glow);
  
  
  float s = sphere( so, sin(h)*0.3+0.4);
  float o = oct( ro, 0.15);
  
  s = max( o, s);
  
  return vec3( s, 1.0, 0.0);
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float t, float glow)
{
  for(int i = 0; i < 256; i++)
  {
    p = cam + rd*t;
    vec3 r = map(p, glow);
    t+=r.x;
    if(r.x < 0.001)
    {
      return r;
    }
    if(t>=50.0)
    {
      t = 50.0;
      return vec3(-1.0);
    }
  }
  return vec3(-1.0);
  
}

vec3 normal( vec3 p)
{
  vec2 e = vec2(0.001, 0.0);
  vec3 c = map(p,0.0);
  return normalize( vec3(
    map( p +e.xyy,0.0).x,
    map( p +e.yxy,0.0).x,
    map( p +e.yyx,0.0).x
  )-c.x);
}

float diffuse( vec3 p , vec3 l, vec3 n)
{
    return max( 0.0, dot( normalize(l-p), n));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 col1 = vec3(1.0, 0.6, 0.0);
  vec3 col2 = vec3(0.0, 0.6, 1.0);
  
  ffts = texture( texFFTSmoothed, 0.2).r;
  
  beat = mod( time, 60./130.0);
  bar = floor( time *60/ 130.0);
  
  vec3 c = vec3(0.);
  vec3 cam = vec3(
    sin( time*0.5) * 1.5,
    cos( time*0.5) * 1.5,
    sin( time*1.1) * 1.7
  );
  vec3 target = vec3(0,0,0);
  vec3 light1 = vec3( 
    sin(time*0.3)*5.0,
    sin(time*2.2)*5.0,
    sin(time*1.2)*5.0
  );
  vec3 light2 = vec3( 
    sin(time*0.5)*5.0,
    sin(time*1.2)*5.0,
    sin(time*1.5)*5.0
  );
  
  float fov = 2.2;
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 p; float t;
  vec3 res = march(cam, rd, p, t, 0.0);
  
  if(res.y < -0.5)
  {
    //sky
  }
  else if(res.y < 0.5){
    //
  }
  else if( res.y < 1.5){
    vec3 n = normal(p);
    c = col1 * diffuse(p, light1, n) + col2 * diffuse(p, light2, n);
    
    vec3 rrd = reflect( p, n);
    vec3 rp; float rt;
    vec3 rres = march( p+ n*0.1, rrd, rp, t,1.0);
    vec3 rc = vec3(0.0);
    if(rres.y < -0.5)
    {
      //sky
    }
    else if(rres.y < 0.5){
      //r
    }
    else if( rres.y < 1.5){
      vec3 rn = normal(rp);
      rc = col1 * diffuse(rp, light1, rn) + col2 * diffuse(rp, light2, rn);
      
      vec3 rrrd = reflect( rp, rn);
      vec3 rrp; float rrt;
      vec3 rrres = march( rp+ rn*0.1, rrrd, rrp, rt,1.0);
      vec3 rrc=  vec3(0.0);
      if(rrres.y < -0.5)
      {
        //sky
      }
      else if(rrres.y < 0.5){
        //r
      }
      else if( rrres.y < 1.5){
        vec3 rrn = normal(rrp);
        rrc = col1 * diffuse(rrp, light1, rrn) + col2 * diffuse(rrp, light2, rrn);
        
      }
      rc = mix( rc, rrc, 0.5);
      
    }
    
    c = mix( c, rc,0.5);
    
  }
  
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -=0.5;
  uv*=0.99;
  uv+=0.5;
	vec3 previous = texture( texPreviousFrame, uv).rgb;
  
  c = previous * (1.0-length(c))*(0.8 + smoothstep(0.0, 0.016, ffts)*0.2) + c;
  
  
  float col = mod( bar, 4.0);
if( col < 1.0) c.rgb = c.rgb;
else if( col < 2.0) c.rgb = c.grb;
else if( col < 3.0) c.rgb = c.bgr;
else if( col < 4.0) c.rgb = c.brg;
  
  
  
	out_color = vec4(c, 1.0);
}




