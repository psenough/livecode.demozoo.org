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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hex(in vec2 p, in float r)
{
  const vec3 k = vec3(-0.86,0.5,0.57);
  p = abs(p);
  p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
  p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
  return length(p)*sign(p.y);
}

void rot(inout vec2 p, float a) {
  p = cos(a)*p +sin(a)*vec2(-p.y,p.x);
}


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

  
  //float gt=fGlobalTime;
  float gt=texture(texFFTIntegrated,.02).r*.12;
  float bm=texture(texFFT,.05).r*10;
  float bms=texture(texFFTSmoothed,.05).r*20;
  
  vec2 zom=uv+.5;
  
  uv=round(uv*(bm*700))/(bm*700);
  
  
  zom+=.5;
  zom*=vec2(.99);
  zom-=.5;
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFTSmoothed, pow(abs(m.x),2) ).r * 10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  vec3 col = vec3(1);
  vec2 pp = uv;
  
	float uvf = texture( texFFTSmoothed, pow(abs(pp.x/pp.y),2) ).r * 10;
  
  for(int i=0;i < 4; ++i){
    pp= abs(pp)-vec2(.1,.2)*(1.2-bms*.2);
    rot(pp,gt*4+bm*.02);
    pp=abs(pp)-vec2(0,bms*.1+.1)*uvf;
  }
  
  vec3 prev=texture(texPreviousFrame,zom).rgb;
  
  col *= smoothstep(0.0,hex(pp,.1*(1+bm)+f*.02),1.0);
  col -= smoothstep(0.0,hex(pp/uvf,.3*(1+bm)+f*.02),1.0);
  
  if(col.r+col.b+col.g<.1){
    col=prev*.3*vec3(3,.5,1.8);
  }
  
  col=clamp(col,-0.1,1.2);
  
	out_color = vec4(col*vec3(10,1,4),1)-vec4(prev*vec3(40,2,2),1);
}