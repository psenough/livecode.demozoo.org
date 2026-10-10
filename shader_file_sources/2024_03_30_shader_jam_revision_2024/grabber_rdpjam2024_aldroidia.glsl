#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texEmboss;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 plas( vec2 v, float time )
{
  v *= 20;
	float c = 0.5 + sin( v.x * 1.0 ) + cos( sin( time + v.y ) * 20.0 );
  c /= 20;
	return vec3(c);//vec3( sin(c * 0.2 + cos(time+v.y)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

mat2 rot(float a) {
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

vec3 plas2(vec2 uv) {
  
  uv *= rot(fGlobalTime);
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, floor(d*100)/100 ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec3 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	return (f -t)*(1-d)*vec3(0,1,1);
}


float map(vec3 p) {
  p *=0.5;
  p.z -=8+texture(texFFTSmoothed,0.02).x*100;
  p.yz *= rot(0.5*3.1415);
  p.xz *= rot(0.25*3.1415);
  vec3 q=p-vec3(3,0,3);
  return max(max(length(p.xz)-4, abs(p.y)-1),-max(abs(q.x)-3,abs(q.z)-3));
 }

vec3 gn(vec3 p) {
  vec2 e = vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 puv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uv = floor(puv*240)/240;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(0,0,-10), rd=normalize(vec3(uv+vec2(0,-texture(texFFTSmoothed,0.15).x*20),1));
  float t=0,d;
  
  float flex=0;
  
  vec3 ld=normalize(vec3(3,4,-3));
  
  for (int i=0;i<100; ++i) {
    d=map(ro+rd*t);
    if (d<0.01) {
      break;
    }
    t += d;
  }
  vec3 col = 0.1*flex*vec3(1,0,0)+10*plas2(rd.xy);
  //col += t*texture(texPreviousFrame,abs(uv)*10).xyz*0.004;
  
  if (d<0.01) {
    col=vec3(1,1,0)*dot(gn(ro+rd*t),ld);
  }
  
  out_color=vec4(col,1);
}