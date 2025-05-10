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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

vec3 plas( vec2 v, float time )
{
  v.x=sin(v.x*3+sin(v.y))/3;
  v.y=cos(v.y*3+cos(v.x/3))/4;
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 )*0.2;
	return vec4( sin(c * 0.12 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 ).xyz;
}

vec3 plas2(vec2 uv) {
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec3 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	return t ;
}

float boll(vec3 p) {
  
  return length(p)-1-texture(texFFTSmoothed,0.1).r*10;
}

float PI=3.1415;

float gl=1e7;
float bl=0;

vec2 min2(vec2 a, vec2 b) {
  return a.x<b.x ? a : b;
}

vec2 map(vec3 p) {
  p.xy *= rot(fGlobalTime*0.2);
  float a = atan(p.x,p.z);
  a += fGlobalTime;
  
  a = mod(a+PI/6,PI/3)-PI/6;
  float r = length(p.xz);
  p.x =r*sin(a);
  p.z = r*cos(a);
  
  float bolls = boll(p+vec3(0,0,-3+texture(texFFT,0.2).r*50));
  float beem = length(p.xz)-0.5;
  bl=p.y;
  gl=min(gl,min(1e7,beem));
  return min2(vec2(bolls,1),vec2(beem,2));
}

vec3 gn (vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p).x-vec3(map(p-e.xyy).x,map(p-e.yxy).x,map(p-e.yyx).x));
}

void main(void)
{
	vec2 puv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = puv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0;
  vec2 d;
  
  for (int i=0;i<100; ++i) {
    d = map(ro+rd*t);
    if (d.x<0.01) break;
    t += d.x;
  }
  
  vec3 ld= normalize(vec3(3,4,-14));
      vec3 barcol= bl >0?vec3(0.6,0.7,0.1):vec3(0.7,0.1,0.74);
  
  vec3 col=plas2(uv).xxx;// texture(texPreviousFrame,puv).gbr*vec3(0.97,0.97,0.6);
  if (d.x< 0.01) {
    vec3 p=ro+rd*t;
    vec3 n=gn(p);
    if (d.y==1) {
    col=vec3(texture(texFFT,0.1).r>0.001?1:0)*dot(n,ld)*100;
    } else if (d.y==2) {
      col=plas2(vec2(bl,bl)/10).y*barcol;
    }
  }
  
  col += exp(-gl*gl*gl*10)*barcol;
  
  out_color.rgb = col;
}