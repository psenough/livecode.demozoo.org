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

float T=fGlobalTime;

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,s,-s,c);}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  mat2 r2=rot(T*0.1);
  float zoom=sin(T)*0.5+0.5;
  float zoom2=zoom*4.0+1.0;
  vec2 pan=sin(vec2(T*.6,T*.4+2))*5.0;
  vec2 pan2=smoothstep(-1,1,sin(T*.3))*pan;
  vec2 uv2=uv*zoom2+pan2;
  float w=0;
  for (int i=0;i<30; i+=1){
    vec2 suv=sin(uv2);
    w+=suv.x+suv.y;
    uv2=sin(uv2);
    uv2=uv2*2.0;
    uv2*=r2;
  }
  float tres=smoothstep(-1,1,sin(T+10))*4.0;
  float wave=smoothstep(-tres,tres,w);
  vec3 c4=vec3(.2,.9,.2);
  vec3 c4b=vec3(.9,.4,.1);
  vec3 c=mix(c4,c4b,cos(T))*2.0;
  vec3 c2a=vec3(.3,.4,.2);
  vec3 c2b=vec3(.4,.1,.4);
  vec3 c2=mix(c2a,c2b,sin(T*.4+4))*.22;
  vec3 c3=mix(c,c2,wave);
  vec3 cc=1.4*c3/(1.0+c3);
	out_color = vec4(cc,1);
}