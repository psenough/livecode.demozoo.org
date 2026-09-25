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

	float f = texture( texFFTSmoothed, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	return (1.-(f + t).rrb)*vec3(1.,0.5,0.5);
  
}

float map(vec3 p) {
  p.x += sin(fGlobalTime/7.);
  p.y += sin(fGlobalTime/11.);
  p.z += texture(texFFTSmoothed,0.1).x*20.;
  return length(p) -5.;
}

vec3 gn(vec3 p) {
  vec2 e = vec2(0.001,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(0,0,-10),rd=normalize(vec3(uv,1.));
  
  float t=0, d;
  
  for (int i=0; i<100; ++i) {
    d=map(ro+rd*t);
    if (d<0.01)break;
    t += d;
  }
  
  vec3 col=plas2(floor(uv*10.)/10.)*0.05;
  
  vec3 ld=normalize(vec3(3,4,-13));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n=gn(p);
    
    
    col = plas2(floor(n.xy*30)/10)*dot(n,ld);
    col += min(1., pow(1.+dot(n,rd),3.))*vec3(2.2,0.7,0.8);
  } else {
    col=texture(texPreviousFrame,uv*0.59*rot(sin(fGlobalTime/10.))+0.5).rgb*0.2;
  }
  
  out_color = vec4(col,1);
}