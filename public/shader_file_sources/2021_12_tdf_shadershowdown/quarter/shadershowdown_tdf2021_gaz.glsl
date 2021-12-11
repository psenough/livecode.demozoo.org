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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define B (1-fract(t*2))

#define R(p,a,t) mix(a*dot(p,a),p,cos(t))+sin(t)*cross(p,a)
#define R(p,a,t) mix(a*dot(p,a),p,cos(t))+sin(t)*cross(p,a)

#define M(a)  mat2(cos(a),sin(a),-sin(a),cos(a)) 
#define Y p=p.x<p.y?p.zxy:p.zyx
#define N p=p.x>p.y?p.zxy:p.zyx

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

vec3 p,d=normalize(vec3(uv,1)),c=vec3(0);
  float i=0,g=0,e,a,s,t=fFrameTime;
  
  for(;i++<99;){
    p=d*g;
    p.z-=1.5;
    p=R(p,vec3(.557),t);
    s=2;
    for(int i=0;i++<8;)
    {
      p=abs(p);
      p=p.x<p.y?p.zxy:p.zyx;
      s*=e=1.8/min(dot(p,p),1.2);
      p=abs(p)*e-vec3(3,10,3);
      
    }
   
    
    g+=e=length(p.xy)/s;
    if(e<.001)c+=.5/i;
    }



	out_color = vec4(c,1);
}