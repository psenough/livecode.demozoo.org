#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaBW;
uniform sampler2D texInercia;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float ffti = 0.0;
float ffts = 0.0;
float fft = 0.0;
float iTime = fGlobalTime;
float glow = 0.0;
float beat = 0.0;
float beatstep = 0.0;
float bar = 0.0;
float barstep = 0.0;

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
  return rotx*roty*rotz * p;
}

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec2 rot2d( float a, vec2 p)
{
  return mat2( cos(a), -sin(a), sin(a), cos(a)) * p;
}

vec3 repeat( vec3 p, vec3 q)
{
  return mod(p + q*0.5, q)-q*0.5;
}

vec3 textureMap( vec3 surfacepos, vec3 normal)
{
  mat3 trimap = mat3(
    texture(texNoise, surfacepos.yz).rgb,
    texture(texNoise, surfacepos.xz).rgb,
    texture(texNoise, surfacepos.xy).rgb
  );
  return trimap * normal;
}
vec3 textureMap2( vec3 surfacepos, vec3 normal)
{
  mat3 trimap = mat3(
    texture(texTex3, surfacepos.yz).rgb,
    texture(texTex3, surfacepos.xz).rgb,
    texture(texTex3, surfacepos.xy).rgb
  );
  return trimap * normal;
}


vec3 inercia( vec2 uv )
{
  vec3 c = texture(texInercia, uv*1.25).rgb;
  return c;
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam);
  vec3 right = normalize( cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  return normalize( forward * fov + uv.x * right + uv.y * up);
}

float sphere( vec3 p, float r)
{
  return length(p)-r;
}

float box( vec3 pos, vec3 size)
{
  vec3 q = abs(pos)-size;
  return length(max(q,0.0)+min(max(q.x, max(q.y, q.z)), 0.0));
}


float hexPrism( vec3 p, vec2 h )
{
  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  vec2 d = vec2(
       length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float octahedron( vec3 p, float s)
{
  p = abs(p);
  return (p.x+p.y+p.z-s)*0.57735027;
}


vec3 union( vec3 a, vec3 b)
{
  if(a.x < b.x) return a;
  return b;
}

vec3 map( vec3 p)
{
  vec2 id = floor( (p.xz+vec2(2.0))*0.25);
  vec3 hexP = repeat(p+vec3(iTime*id.x,0.0,0.0), vec3(2.0, 0.0, 2.0))+
      vec3(0.0, -1.0+1.0*sin(id.x+id.y + ffti*1.0), 0.0);
  hexP = rotate(hexP, ffti + id.x -id.y,-ffti + id.x -id.y, 0.0);
  
  float s1 = sphere( 
    repeat(p, vec3(2.0, 0.0, 2.0))+
      vec3(0.0, -1.0+0.5*sin(id.x+id.y + ffti*1.0), 0.0), 
    0.5 + sin(ffts+id.x-id.y)*0.15);
  
  float oct1 = octahedron( hexP, 0.85+ffts);
  
  float hex1 = hexPrism( 
    hexP, 
    vec2(0.5 + sin(ffts+id.x-id.y)*0.1));
  
  s1 = mix( oct1, hex1, ffts);
  
  float b1 = box(p, vec3(95.0, 0.1, 95.0));
  vec3 S1 = vec3(s1, 1.0, 0.0);
  vec3 B1 = vec3(b1, 1.4, 0.0);
  glow += 1.0- smoothstep( 0.0, 0.4, s1);
  float bm = mod(bar*0.5, 11.0);
  if( mod(bm, 2.0) < 1.0) return B1;
  return union(S1, B1);
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float travel)
{
  float minim = 99.0;
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd*travel;
    vec3 r = map(p);
    travel+=r.x;
    minim = min(r.x, minim);
      
    if(r.x < 0.001)
    {
      return r;
    }
    if(travel > 90.0)
    {
      travel = 90.0;
      return vec3(minim, 0.0, 0.0);
    }
  }
  return vec3(minim, 0.0, 0.0);
}

vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x);
}

float diffuse( vec3 p, vec3 l, vec3 n)
{
  return max(0.0, dot(n,normalize(l-p)));
}


void main(void)
{
  vec2 ouv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	ffti = texture(texFFTIntegrated,0.2).r;
  ffts = texture(texFFTSmoothed, 0.15).r*30.0;
  fft = texture(texFFT,0.2).r;
  
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  beat = floor(iTime * 130.0 / 60.0);
  beatstep = fract( iTime * 130.0 / 60.0*1.0);
  bar = floor(beat/4.0);
  barstep = fract(beat/4.0);
  
	vec3 c = vec3(0.0);
  
  
  
  vec3 target = vec3(0,1,1.0);
  vec3 cam = target - vec3(cos(iTime*0.3),sin(iTime*0.3)-4,2);
  float fov = 0.8;
  
  float bm = mod(bar,4.0);
  if(bm < 1.0){
    target = vec3(0.01);
    cam = target - vec3(cos(iTime*0.06)-3.0,sin(iTime*0.3)*0.5-3,2);
    fov = mix( 0.2, 1.0, barstep);
  
  }
  else if(bm < 2.0){
    target = vec3(0.01);
    cam = target - vec3(cos(iTime*0.56)-3.0,sin(iTime*0.13)-9.0,-8);
    fov = mix( 1.2, 3.0, barstep);
  
  }
  else if(bm < 3.0){
    target = vec3(0.0, 0.0, sin(iTime*0.4)*3.0);
    cam = target - vec3(cos(iTime*0.56)-3.0,sin(iTime*0.03)-5.0,-3);
    fov = mix( 1.2, 0.05, barstep);
  
  }
  else if(bm < 4.0){
    fov = mix( 0.5, 1.0, barstep);
  
  }
  
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 light1 = target + vec3( 0.0, 2.0, sin(iTime));
  
  vec3 marchP = cam;
  float marchT = 0.0;
  vec3 res = march( cam, rd, marchP, marchT);
  float shadow = 1.0;
  // Materials
  if(res.y < 0.5)
  {
    // Sky
    
  }
  else if(res.y < 1.5)
  {
    // obj 1
    vec3 n = normal(marchP);
    vec3 mapUv = marchP;
    
    if(res.y < 1.25){
      c = vec3(1.0) * textureMap(mapUv, n) * diffuse( marchP, light1, n);
      c = mix( vec3(1.0, 0.6,0.2), c, length(c));
      c = palette( length(c), vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20));
    }
    else {
      mapUv.xz = rot2d( ffti*0.7 + length(mapUv.xz)*0.05, mapUv.xz);
      c= vec3(1.0) * textureMap2(mapUv*(0.1*smoothstep(0.0, 1.0,beatstep)+0.05), n) * diffuse( marchP, light1, n);
      c = palette( length(c), vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20));
    }
    // Shadows
    vec3 shadowP = marchP;
    float shadowT = 0.0;
    vec3 shadowMarch = march( marchP+n*0.1, normalize( light1 - marchP), shadowP, shadowT)*0.95;
    c *= 0.15+ smoothstep(0.0, 0.15,shadowMarch.x);
    shadow = 0.05+ smoothstep(0.0, 0.15,shadowMarch.x);
    // Reflection
    vec3 ref = reflect( rd, n);
    vec3 refP = marchP;
    float refT = 0.0;
    vec3 refR = march( marchP+n*0.1, ref, refP, refT);
    if(refR.y < 0.5) {
      // sky
      
    }
    else if(refR.y < 1.5)
    {
      // Ground
      n = normal(refP);
      mapUv = refP;
      mapUv.xz = rot2d( ffti*0.7 + length(mapUv.xz)*0.25, mapUv.xz);
      vec3 rc =  vec3(0.0);//vec3(1.0) * textureMap(mapUv, n) * diffuse( refP, light1, n);
      
      if(refR.y < 1.25){ 
        rc = vec3(1.0) * textureMap(mapUv, n) * diffuse( refP, light1, n);
        rc = palette( length(rc), vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20));
      }
      else rc = vec3(1.0) * textureMap2(mapUv, n) * diffuse( refP, light1, n);
      // Shadows
      shadowP = refP;
      shadowT = 0.0;
      shadowMarch = march( refP+n*0.1, normalize( light1 - refP), shadowP, shadowT)*0.95;
      rc *= 0.0+ smoothstep(0.0, 0.15,shadowMarch.x);
      
      c = mix(c, rc, 0.05);
    }
  }
  
  c = mix( c, vec3(0.4, 0.2, 0.1), smoothstep(2.0, 20.0, marchT));
  c += glow*0.08*palette( length(c), vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20))*shadow;
  //c += inercia(uv * vec2(1.0, 1.0+ ffts) + iTime*vec2(0.2,0.0));
  
  if(bm < 1.0) c.rgb = c.grb;
  else if(bm < 2.0) c.rgb = c.brg;
  else if(bm < 3.0) c.rgb = c.rbg;
  else if(bm < 4.0) c.rgb = c.gbr;
  
  ouv -= 0.5;
  ouv *= 0.99;
  ouv += 0.5;
  vec3 prev = texture(texPreviousFrame, ouv).rgb;
  c = mix( c, c+prev*0.75, ffts);
  
	out_color = vec4(c, 1.0);
}