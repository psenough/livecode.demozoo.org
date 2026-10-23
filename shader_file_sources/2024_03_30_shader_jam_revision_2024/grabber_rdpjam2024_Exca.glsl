#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float fft = 0.0;
float ffts = 0.0;
float ffti = 0.0;
float glow1 = 0.0;
float glow2 = 0.0;
float glow3 = 0.0;
float beat = 0.0;
float beatstep = 0.0;
float bar = 0.0;
float barstep = 0.0;
vec2 uv = vec2(0.0);

vec3 getcam(vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize(target - cam);
  vec3 right = normalize( cross(vec3(0,1,0), forward));
  vec3 up = normalize( cross(forward, right));
  return normalize( forward * fov + uv.x * right +  uv.y * up);
}
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

vec3 color1 = palette( time, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20));

vec2 rot2d( float a, vec2 p)
{
  return mat2( cos(a), -sin(a), sin(a), cos(a)) * p;
}

vec3 repeat( vec3 p, vec3 q)
{
  return mod(p + q*0.5, q)-q*0.5;
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



float sphere(vec3 p, float r)
{
  return length(p) - r;
}

float ground(vec3 p, float h)
{
  return p.y - h;
}

vec3 union(vec3 a, vec3 b)
{
  return a.x < b.x ? a : b;
}

vec3 map( vec3 p )
{
  vec2 ruv = rot2d( (ffti*0.3-ffts*2.0)*0.1, uv)+vec2(ffti*0.7, ffti*0.3);
  
  if(ffts > 0.85) p = rotate( p, floor(ruv.x*15.0)-0.5*ffti,floor(ruv.y*5.0)+floor(uv.x*5.0),0.0);
  else if(ffts > 0.4) p = rotate( p, floor(ruv.x*3.0)-0.5*ffti,floor(uv.y*0.0)+floor(uv.x*3.0),0.0);
  else if(ffts > 0.3) p = rotate( p, floor(ruv.x*1.0)-0.5*ffti,floor(ruv.y*10.0)+floor(uv.x*5.0),0.0);
  else if(ffts > 0.2) p = rotate( p, floor(ruv.x*1.0)-0.5*ffti,floor(uv.y*5.0)+floor(uv.x*2.0),0.0);
  else if(ffts > 0.1) p = rotate( p, floor(uv.x*4.0)-0.5*ffti,floor(uv.y*2.0)+floor(ruv.x*5.0),0.0);
  else p = rotate( p, floor(uv.x*1.0)-1.5*ffti,floor(uv.y*1.0)+floor(ruv.x*1.0),0.0);
  
  vec3 sphereP = repeat( p, vec3( 1.0, 0.0,1.0));
  
  float distanceFromCenter = length( p);
  float distanceSize = 1.0 - smoothstep(1.0, 5.0, distanceFromCenter);
  
  float bm = mod(beat,4.0);
  
  float s1 = sphere(sphereP, 0.5 * distanceSize);
  if(bm < 1.0) s1 = hexPrism(sphereP, vec2(0.2,0.4) * distanceSize);
  else if(bm < 2.0) s1 = octahedron(sphereP, 0.8 * distanceSize);
  
  float innerRadius = (0.2+ 0.2 * ffts)*distanceSize;
  float innerOffset = (0.25 + ffts*0.25)*distanceSize;
  float sx1 = sphere(sphereP - vec3(innerOffset, 0.0,0.0), innerRadius);
  float sx2 = sphere(sphereP - vec3(-innerOffset, 0.0,0.0), innerRadius);
  float sy1 = sphere(sphereP - vec3(0.0, -innerOffset,0.0), innerRadius);
  float sy2 = sphere(sphereP - vec3(-0.0, innerOffset,0.0), innerRadius);
  float sz1 = sphere(sphereP - vec3(0.0, 0.0,-innerOffset), innerRadius);
  float sz2 = sphere(sphereP - vec3(-0.0, 0.0,innerOffset), innerRadius);
  
  float si = min(sx1, sx2);
  si = min(si, sy1);
  si = min(si, sy2);
  si = min(si, sz1);
  si = min(si, sz2);
  
  s1 = max(s1, -si);
  
  float lightSphere = sphere(sphereP, 0.07*ffts + 0.05*(sin(floor(p.x+0.5)+ffti*4.0) + cos(ffti*10.0-floor(p.z+0.5))));
  
  float g1 = ground(p, -2.0);
  
  glow1 += 1.0/lightSphere;
  //glow1 += smoothstep(0.0, 0.5, lightSphere);
  
  
  vec3 S1 = vec3(s1, 1.0, 0.0);
  vec3 LS1 = vec3(lightSphere, 2.0, 0.0);
  vec3 GROUND1 = vec3( g1, 3.0, 0.0);
  
  
  vec3 OUT = union(GROUND1, union(S1, LS1));
  
  return OUT;
}

vec3 march( vec3 cam, vec3 rd, out vec3 p, out float travel)
{
  float minim = 99.0;
  for(int i = 0; i < 100; i++)
  {
    p = cam + rd*travel;
    vec3 r = map(p);
    travel += r.x;
    minim = min(r.x, minim);
    if(r.x < 0.001){
      return r;
    }
    if(travel > 90.0){
      travel = 90.0;
      return vec3( minim, 0.0, 0.0);
    }
  }
  return vec3( minim ,0.0, 0.0);
}

vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2(0.001, 0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x);
}

float diffuse( vec3 p, vec3 n, vec3 l)
{
  return max( 0.0, dot(n, normalize(l-p)));
}

vec2 barrelDistortion(vec2 uv, float k)
{
  float rd = length(uv);    
  float ru = rd * (1.0 + k * rd * rd);
  uv /= rd;
  uv *= ru;
  return uv;
}

void main(void)
{
	uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = uv;
	uv -= 0.5;
	
  
  ffti = texture(texFFTIntegrated,0.2).r;
  ffts = texture(texFFTSmoothed, 0.15).r*30.0;
  fft = texture(texFFT,0.2).r;
  
  uv = barrelDistortion(uv, 0.10 + smoothstep(0.0, 0.75, ffts)*2.5 * smoothstep(0.08, 0.2, length(uv-0.5)));
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  beat = floor(time * 110.0 / 60.0);
  beatstep = fract( time * 130.0 / 60.0*1.0);
  bar = floor(beat/4.0);
  barstep = fract(beat/4.0);
  
  
  vec3 col = vec3(0.0);
  
  vec3 target = vec3(
    sin(ffti*0.05)*1.3,
    cos(ffti*0.01)*0.3+0.8,
    cos(ffti*0.02)*1.3 +  cos(time*0.3)*1.0
   );
  vec3 cam = vec3(
    sin(time*0.1)*1.3,
    cos(time*0.1)*0.3+0.8,
    cos(time*0.2)*1.3 +  cos(time*0.3)*1.0
  );
  float fov = 0.5;
  
  vec3 light1 = vec3( 
    sin(time)*2.3,
    cos(time)*0.3+3.0,
    cos(time)*2.3 +  cos(time*0.3)*1.0
  );
  
  vec3 rd = getcam( cam, target, uv, fov);
  
  vec3 marchP = cam;
  float marchT = 0.0;
  vec3 res = march( cam , rd, marchP, marchT);
  
  if(res.y < 0.5 ){
    // bg 
    
  }
  else if(res.y < 1.5){
    // balls
    vec3 n = normal(marchP);
    vec3 l = color1 * diffuse( marchP, n, light1);
    col =vec3(1.0) * l;
    
    // balls reflection
    vec3 ref = reflect( rd, n);
    vec3 refP = marchP;
    float refT = 0.0;
    vec3 refR = march( marchP - n*0.1, ref, refP, refT);
    vec3 refC = vec3(0.0);
    if(refR.y < 0.5 ){
      // ref1 bg 
      refC = vec3(0.0);
    }
    else if(refR.y < 1.5){
      // ref1 balls
      vec3 n = normal(refP);
      vec3 l = color1 * diffuse( refP, n, light1);
      refC =vec3(1.0) * l;
    }
    else if(refR.y < 2.5){
      // ref1 inner light
      refC =vec3(1.0);
    }
    else if(refR.y < 3.5){
      // ref1 ground
      refC = vec3(1.0);
    }
    col = mix(col, refC,0.4);
    
    
  }
  else if(res.y < 2.5){
    // inner light
    col =vec3(1.0);
  }
  else if(res.y < 3.5){
    // ground
    float xl = length( mod(marchP.x*3.0,4.0)-2.0);
    float zl = length( mod(marchP.z*3.0,4.0)-2.0);
    col = vec3( 0.1,0.2,0.3) * (1.0-xl * zl)*1.1;
    
    // ground reflection
    vec3 n = normal(marchP);
    vec3 ref = reflect( rd, n);
    vec3 refP = marchP + n*0.1;
    float refT = 0.0;
    vec3 refR = march( marchP + n*0.1, ref, refP, refT);
    vec3 refC = vec3(0.0);
    if(refR.y < 0.5 ){
      // ref1 bg 
      refC = vec3(0.0);
    }
    else if(refR.y < 1.5){
      // ref1 balls
      vec3 n = normal(refP);
      vec3 l = color1 * diffuse( refP, n, light1);
      refC =vec3(1.0) * l;
    }
    else if(refR.y < 2.5){
      // ref1 inner light
      refC =vec3(1.0);
    }
    else if(refR.y < 3.5){
      // ref1 ground
      refC = vec3(1.0);
    }
    col = refC;
  }
  
  col += glow1*0.002;
  
  col = mix( col, vec3(0.0), smoothstep(10.0, 15.0, marchT));
  
  float bm = mod(bar,4.0);
  if(bm < 1.0) col.rgb = col.grb;
  else if(bm < 2.0) col.rgb = col.brg;
  else if(bm < 3.0) col.rgb = col.rbg;
  else if(bm < 4.0) col.rgb = col.gbr;
  
  
  ouv -= 0.5;
  ouv *= 1.05-ffts*0.15;
  ouv += 0.5;
  vec3 prev = texture( texPreviousFrame, rot2d(ffti, ouv)).rgb + texture( texPreviousFrame, ouv).rgb;
  prev *=0.5;
  col = mix( 
    col, 
    col + palette(time*0.3,vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20))*  prev*0.5, smoothstep(0.005, 0.2, ffts));
  
  out_color = vec4(col,1.0);
  
}