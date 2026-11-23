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

float pen( in vec2 p, in float r){
  const vec3 k = vec3(0.8,0.58,0.72);
  p.x = abs(p.x);
  p.y*=-1;
  p -= 2.0*min(dot(vec2(-k.x,k.y),p),0.0)*vec2(-k.x,k.y);
  p -= 2.0*min(dot(vec2( k.x,k.y),p),0.0)*vec2( k.x,k.y);
  p -= vec2(clamp(p.x,-r*k.z,4*k.z),r);
  return length(p)*sign(p.y);
}


vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void rot(inout vec2 p, float a){
  p=cos(a)*p+sin(a)*vec2(-p.y,p.x);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float ft=texture(texFFTIntegrated,0.02).r*4;
  float gt = fGlobalTime*.02+ft*.01;
  float fy = texture(texFFT, pow(abs(uv.x),4)).r*1;
  
  uv=uv*vec2(1,1.2);
  
  vec2 pp = uv;
  
  vec4 prev=texture(texPreviousFrame,uv);
  
  for(int i=0;i < 50;++i){
    uv=abs(uv)-vec2(.2+abs(sin(gt+pp.x*.2)*.4),0);
    rot(uv,pow(ft*.0008,2));
    uv=abs(uv)-vec2(0,fy*.1);
  }
  prev*=.4-texture(texPreviousFrame,uv);
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.x;
  
  
  float fx = texture(texFFT, pow(abs(m.x),2) ).r *10;
  float fz = texture(texFFT, 0.2).r*100;
	float f = texture( texFFT, pow(abs(d),2) ).r * 1/(m.y-.8-fx*-.1)*10;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
	vec4 col = vec4(abs(f)*.5);
	col = clamp( col, 0.0, 1.0 )*vec4(1,5,10,1);
	col+= vec4(1,1,1,1);
  col*=step(pen(pp,.2+fx*2),.01)+prev*.5;
  
  if(col.r+col.g+col.b<.0){
    col=vec4(.1+floor(sin(gt*10)*20)*.05,.5,1.8,1);
  }
  rot(col.xy,prev.x);
  rot(col.zy,prev.y);
	out_color = (col+prev*.6)*(.1+fy*.9)*12;
}