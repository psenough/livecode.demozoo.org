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
uniform float fMid1;
uniform float fMid2;
uniform float fMid3;
uniform float fMid4;
uniform float fMid5;
uniform float fMid6;
uniform float fMid7;
uniform float fMid8;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }
  

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

float permute(float x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip)
{
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 

  return p;
}

#define F4 0.309016994374947451

float snoise(vec4 v)
{

  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
  
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
  
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );
  
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;
  
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));
           
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0,   ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);
  
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));
  
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;
               
 }

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


void main(void)
{
 float f;
  for (int i = 0; i < 16; i++) {
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv-=0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv*=1.+distance(vec2(0.0),uv*(texture(texPreviousFrame,gl_FragCoord.xy*0.).gb*0.5))*cos(fGlobalTime*0.5)*4.;


  f = fGlobalTime*0.005;
  
  
  float s = 1.0+sin(fGlobalTime*0.1*fMid2+uv.x)*1.;
  float s2 = 1.0+sin(fGlobalTime*0.1*fMid3+uv.x)*1.;
  float s3 = 1.0+sin(fGlobalTime*0.1*fMid4+uv.x)*1.;
  
  s+=f;
  s2+=f;
  s3+=f;
  
  float ox = fGlobalTime*6.;
  float oy = -fGlobalTime*1.;
  
  
  float zz = distance(vec2(s*0.5*cos(fGlobalTime*0.5*float(i)*0.1))*cos(uv.x*cos(fGlobalTime*0.1)),vec2(s2,s3))*1.;
  
  // torus mapping: 2d periodic tiling texture by embedding a 4d torus
  float noise = snoise(vec4(sin(ox+uv.x*s+zz), cos(ox+uv.x*s-zz), sin(oy+uv.y*s-zz), cos(oy+uv.y*s+zz)));
	float noise2 = snoise(vec4(sin(ox+uv.x*s2+zz), cos(ox+uv.x*s2-zz), sin(oy+uv.y*s2-zz), cos(oy+uv.y*s2+zz)));
	float noise3 = snoise(vec4(sin(ox+uv.x*s3+zz), cos(ox+uv.x*s3-zz), sin(oy+uv.y*s3-zz), cos(oy+uv.y*s3+zz)));

  vec3 col = vec3(noise,noise2, noise3);
  out_color += vec4(col,1.0);
  }
  
	out_color/=1;
  out_color=vec4(out_color.r*1.4+f*0.001,out_color.b*0.6+f*0.001,out_color.g*2.5+f*0.001,1.0);
}