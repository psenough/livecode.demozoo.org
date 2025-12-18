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

float PI=3.14;
float e=2.71828;

float sdHex( in vec2 p, in float r ){
  const vec3 k = vec3(-0.866025404,0.5,0.577350269);
  p = abs(p);
  p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
  p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
  return length(p)*sign(p.y);
}
float sdBox( in vec2 p, in vec2 b ){
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y,p.x);
}
float sum( in vec2 a) {
  return a.x+a.y;
}
float sum( in vec3 a) {
  return a.x+a.y+a.z;
}
float sum( in vec4 a) {
  return a.x+a.y+a.z+a.w;
}
float sdEqTri( in vec2 p, in float r ){
  const float k = sqrt(3.0);
  p.x = abs(p.x) - r;
  p.y = p.y + r/k;
  if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
  p.x -= clamp( p.x, -2.0*r, 0.0 );
  return -length(p)*sign(p.y);
}


void main(void)
{
  float Gt=fGlobalTime;
  float Ft=mod(texture(texFFTIntegrated,0.1).r*.5,PI);
  float bm=pow(texture(texFFTSmoothed,0.001).r*5,2.0);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float reso=50+bm*3000;
  uv=floor(uv*reso)/reso;
  vec2 zom=uv;
  vec2 zom2=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv*=.7;
  // pol.x = r, .y = ang
  vec2 uv_=uv;
  vec2 pol=vec2(uv_.x*uv_.x+uv_.y*uv_.y,atan((uv_.y/uv_.x)/PI));
  pol=mod(pol+vec2(-Gt*.8,0),1.1);
  zom-=.5;
  zom*=1-bm*.5;
  zom+=.5;
  zom2-=.5;
  zom2*=1+bm*.05;
  zom2+=.5;
  vec4 prev=texture(texPreviousFrame,zom);
  vec4 prev2=texture(texPreviousFrame,zom2);
	float d = abs((pol.x-.1)/(e*4));

	float f = texture( texFFTSmoothed, exp(d) ).r ;
	float f2 = texture( texFFTSmoothed, exp(abs(uv_.x*.7)/e) ).r*10 ;
  rot(uv_,PI/2);
  vec2 uu=abs(uv_)-vec2(0,.30);
  float b = sdBox(uu,vec2(.2*f2,.4+f2));
  rot(uu,Gt*.1+Ft*3);
  float he = sdHex(uu,.2+bm);

	vec4 t = vec4(0);
	t = clamp( t, 0.0, 1.0 );
  if(abs(pol.y-f*2-abs(pol.x))<PI/10){t=vec4(1.8,.5,1.7,1)*bm;}
	t = clamp( t, 0.0, 1.0 );
  t+=step(b,0)*vec4(10,2,1,1);
  rot(t.xy,Ft);
  rot(t.yz,Gt);
  t+=f*10;
  t*=.8+prev;
  t*=.1+step(he,0)*vec4(10,2,1,1);
  t+=step(b,0.01)*vec4(10,2,1,1)*step(1,bm);
  vec4 o=mix(t,prev,abs(pol.x)*1.1);
  vec4 ou=vec4(0);
  ou+=o.rrra;
  ou+=o.ggga;
  ou+=o.bbba;
  ou/=3;
  //ou*=vec4(.5+mix(o.rbg,-prev.rgb*1.1,.9),1);
  ou*=vec4(1.7,1.1,0.5,1);
	out_color = ou*2-prev2*20;
}