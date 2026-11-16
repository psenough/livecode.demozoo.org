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
  return mat2(cos(a),-sin(a), sin(a), cos(a));
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 10.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

// glsl oklab conversion from https://www.shadertoy.com/view/WtccD7
// credit to mattz
const mat3 fwdA = mat3(1.0, 1.0, 1.0,
                       0.3963377774, -0.1055613458, -0.0894841775,
                       0.2158037573, -0.0638541728, -1.2914855480);
                       
const mat3 fwdB = mat3(4.0767245293, -1.2681437731, -0.0041119885,
                       -3.3072168827, 2.6093323231, -0.7034763098,
                       0.2307590544, -0.3411344290,  1.7068625689);

vec3 okl(vec3 c) {

    vec3 lms = fwdA * c;
    
    return fwdB * (lms * lms * lms);
    
}

float cog(vec3 p, float a) {
  
  float cedge = length(p.xy)-3.;
  cedge += smoothstep(-0.01,0.01,sin(atan(p.y,p.x)*10+a));
  return max(max(abs(p.z)-0.5,cedge),-length(p.xy)+.7);
}

float map(vec3 p) {
  p.xz *= rot(sin(fGlobalTime));
  float ca = fGlobalTime*10+texture(texFFTSmoothed,0.01).x*100;
  return min(cog(p-vec3(2.5,0,0),ca),cog(p-vec3(-2.5,0,0),-ca));
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy), map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro=vec3(0,0,-10+texture(texFFT,0.1).x*100),rd=normalize(vec3(uv,1));
  
  float d,t=0;
  
  for (int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    if (d<0.01)break;
    t+=d;
  }
  
  vec3 ld=normalize(vec3(-3,4,13));
  
    float ch= length(uv)+fGlobalTime;
    
    float a = 0.7*cos(ch);
    float b = 0.7*sin(ch);
  vec3 col=vec3(okl(vec3(0.01,a,b)));
  
  if (d<0.01) {
    vec3 al= okl(vec3(1.,a,b));
    vec3 p=ro+rd*t;
    vec3 n=gn(p);
    float flash = texture(texFFT,0.1).x*100;
    float ao=clamp(map(p+n*0.1)/.1,0.,1.);
    float s=pow(max(dot(reflect(-ld,n),-rd),0),30);
    col = dot(ld,n)*al*ao+s*(1+flash);
  }
	out_color = vec4(col,1);//f*0.1 + t;
}