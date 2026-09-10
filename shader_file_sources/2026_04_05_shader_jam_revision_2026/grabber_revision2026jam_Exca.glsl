#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

/* Timing */
float time = 0.0;
float beat = 0.0;
float bar = 0.0;
float beatStep = 0.0;
float barStep = 0.0;
float fft = 0.0;
float fftS = 0.0;
float fftI = 0.0;

/* utilities */
vec3 getcam( vec3 from, vec3 to, vec2 uv, float fov)
{
  vec3 forward = normalize(to - from);
  vec3 right = normalize(cross(vec3(0,1,0), forward));
  vec3 up = normalize(cross(forward, right));
  return normalize( forward*fov + uv.x * right + uv.y * up);
}

float hash( float p){
  vec3 p3 = fract(vec3(p)*0.1031);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y)*p3.z);
}

mat2 rot2d(float a)
{
  return mat2( cos(a), -sin(a), sin(a), cos(a));
}

/* SDF functions */
float sphere(vec3 p, float r)
{
  return length(p) - r;
}

float gyroid( vec3 seed) { return dot( cos(seed), sin(seed.xzy));}
float gyroidSurface( vec3 p, float scale, float thickness, float bias){
  p *= scale;
  float gyroid = abs( dot(sin(p)*2.0, cos(p.zxy*1.23))-bias)/(scale*2.0*1.23)-thickness;
  return gyroid;
}
float fbm( vec3 p ){
  float t = 0.0;
  float a = 0.0;
  for(int i = 0; i < 8; i++)
  {
    p.z -= 0.1*t;
    t += abs( gyroid(p/a))*a; 
    a *=0.5;
  }
  return t;
}

/* Mapping */
vec3 map( vec3 p )
{
  float s1 = sphere(p, 0.85 + fftS*15.0);
  float gyroidD = gyroidSurface( 
    p + vec3(-0.020,0.01,0.01)*fftI, 
    5.0 + sin(fftI*0.02)*1.0, 
    0.08+0.04* sin(fftI*0.02), 
    0.7 + fftS*10.0
  );
  //s1 = gyroidD;//
  s1 = max(s1, gyroidD);
  return vec3( s1, 1.0, 0.0);
}

vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2(0.01, 0.0);
  return normalize( vec3(
    map( p + e.xyy).x,
    map( p + e.yxy).x,
    map( p + e.yyx).x
    
  ) - c.x );
}

/* March */
vec3 march( vec3 from, vec3 rd, out vec3 p, out float travel)
{
  float mindist = 999.99;
  travel = 0.5;
  for( int i = 0; i < 100; i++)
  {
    p = from + rd*travel;
    vec3 res = map(p);
    travel += res.x;
    mindist = min(mindist, res.x);
    if(res.x < 0.0001) {
      res.z = mindist;
      return res;
    }
    if(travel > 50.0){
      travel = 50.0;
      return vec3(-1.0,-1.0, mindist);
    }
  }
  return vec3(-1.0, -1.0, mindist);
}

float diffuse( vec3 p, vec3 n , vec3 l)
{
  return max( 0.0, dot(n, normalize(l-p)));
}


void main(void)
{
  time = fGlobalTime;
  fftI = texture( texFFTIntegrated, 0.15).r;
  fftS = texture( texFFTSmoothed, 0.125).r;
  beat = time * 135.0 / 60.0;
  bar = floor(beat / 4.0);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = uv;

  float splitX = 5.0 + sin(floor(fftI))*4.0;
  float splitY = 5.0 + sin(floor(fftI))*4.0;
  
  uv.x += 0.1 * ( step( uv.y * splitX, 2.0)*2.0-1.0);
  uv.y += 0.1 * ( step( uv.x * splitY, 2.0)*2.0-1.0);
  
  
  
  
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
	vec3 col = vec3(0.0);
  
  vec3 cam = vec3(
    sin(time*0.3+fftI)*2,
    cos(time*0.22-fftI)*2,
    2
  ) * (smoothstep(0.0,0.2, fftS)*4.0 + 0.5);
  vec3 target = vec3(0,0,0);
  vec3 light = vec3( sin(time), cos(time), 0.0);
  float fov = 0.8;
  
  vec3 raydir = getcam( cam, target, uv, fov);
  vec3 hit = cam;
  float travel = 0.0;
  vec3 res = march( cam, raydir, hit, travel);
  if(res.y < -0.5){
    // no hit
  }
  else if(res.y < 0.5){
    // bg
  }
  else if(res.y < 1.5){
    // sphere
    col = vec3(1.0);
    vec3 n = normal(hit);
    col = vec3( 1.0) * diffuse(hit, n, light)*0.0;
    
    float d = 0.06 + fftS * 1.1;
    
    col += abs(d/sin(hit.x*30.0));
    col += abs(d/sin(hit.z*30.0));
    col += abs(d/sin(hit.z*30.0));
    col *= vec3(0.2, 1.0,1.2);
    vec3 refRD = reflect( raydir, n);
    vec3 refHit =hit+n*0.1;
    float refT = 0.0;
    vec3 refRes = march( hit+n*0.1, refRD, refHit, refT);
    vec3 refCol = vec3(0.0);
    if(refRes.y < 0.5){
       // nothing 
    }
    else 
    {
      // itself
      vec3 refN = normal(refHit);
      refCol = vec3( 1.0) * diffuse(hit, refN, light);
      
      float d = 0.06 + fftS * 1.1;
      
      refCol += abs(d/sin(refHit.x*10.0));
      refCol += abs(d/sin(refHit.z*10.0));
      refCol += abs(d/sin(refHit.z*10.0));
      refCol *= vec3(1.5, 0.6, 0.3);
      
    }
      col = mix( col, refCol, 0.5);
    
  }
  col = smoothstep(0.0, 1.0, col);
  col*=1.0- smoothstep(0.5,2.5, travel);
  
  float bm = mod(bar,4.0);
  if(bm < 1.0) col.rgb = col.grb;
  else if(bm < 2.0) col.rgb = col.brg;
  else if(bm < 3.0) col.rgb = col.rbg;
  
  
  
  ouv -=0.5;
  ouv *= 1.25 - fftS*0.15;
  ouv +=0.5;
  vec3 prev = texture( texPreviousFrame, ouv).rgb;
  col = mix(col, col+prev*0.85, smoothstep(0.0, 0.02, fftS));
  
	out_color = vec4( col, 1.0);
}

















