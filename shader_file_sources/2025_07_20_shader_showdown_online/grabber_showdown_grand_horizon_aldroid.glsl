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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// ALDROID IN THE HOUSE

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 plas2(vec2 uv) {
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	return (f*0.3 + t).rgb;
}

float smin(float a, float b, float k) {
  // dear gods of shading, let me remember this properly :D
  float h = max(0, k - abs(a-b));
  return min(a,b) - h*h*0.25/k;
}

mat2 rot (float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float map(vec3 p,out vec2 uv) {
  float mb =6;
  float res = 1e7;
  p.xz *= rot(sin(fGlobalTime));
  p.xy *= rot(sin(fGlobalTime*0.7));
  float cs = sin(fGlobalTime)*2 + 6; 
  p.x=mod(p.x+cs/2,cs)-cs/2;
  p.y = abs(p.y);
  p.xz *= rot(sin(fGlobalTime*0.9));
  p.x += 2+sin(fGlobalTime);
  p.x = abs(p.x);
  for (float i=0;i<mb;++i) {
    p.x += cos(fGlobalTime*i);
    p.y += sin(fGlobalTime);
    uv.x = atan(p.z,p.x);
    uv.y = sin(p.y);
    res = smin(res,length(p)-1-texture(texFFT,0.1).x*10-texture(texFFTSmoothed,0.1).x*10,0.2);
  }
  return res;
}

vec3 gn( vec3 p) {
  vec2 e=vec2(0.01,0);
  vec2 j;
  return normalize(map(p,j)-vec3(map(p-e.xyy,j),map(p-e.yxy,j),map(p-e.yyx,j)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1));
  float t=0,d;
  
  vec2 tuv;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t, tuv);
    if (d<0.01)break; //brleeeekk
    t += d;
    if (t>100) break;
  }
  
  float rgbt = texture(texFFTIntegrated,0.1).x;
  
  
  vec3 bgcol = plas2(floor(uv*20)/20*(1-40*texture(texFFTSmoothed,0.4).x)+0.1*vec2(cos(rgbt),sin(rgbt)))*0.2;
  vec3 col = bgcol;
  
  if (d<0.01) {
    col = plas2(tuv);
    vec3 n = gn(ro+rd*t);
    col = mix(bgcol,plas2(tuv),clamp(-dot(rd,n),0,1));
  }
  
	out_color.rgb = col;
}