#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

float _t = fGlobalTime;

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c,-s,s,c);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 10.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec4 sdf(vec3 p) {
  p.z -= 10.;
  
  vec3 g = p;
  p.xz *= rot(_t * 3.);
  p.yz *= rot(_t * 3.);
  

  // cube or smth idk
  vec3 q = abs(p) - vec3(.2,1,1);
  float d = min(length(q), max(max(q.x,q.y),q.z));
  
  float h = .3;
  
  for (int i = 0; i < 20; i++) {
    q = p;
    //q.yz *= rot(i * .89);
    float hh = h * 2.;
    q.yz = mod(q.yz, hh+hh)-hh;
    q = abs(q) - vec3(1.2,h,h);
    d = max(d, -max(max(q.x,q.y),q.z));
    h *= .4;
  }
  
  d = max(d, .1 - abs(p.x));
  
  g.yz *= rot(_t * 3.);
  g.xz *= rot(_t * 3.);

  vec2 zo = vec2(0,4);
  float s = .3;
  
  float dd = d;

  d = min(d, length(g - zo.xxy) - s);
  d = min(d, length(g - zo.xyx) - s);
  d = min(d, length(g - zo.yxx) - s);
  d = min(d, length(g + zo.yxx) - s);
  d = min(d, length(g + zo.xyx) - s);
  d = min(d, length(g + zo.xxy) - s);

  return vec4(d, atan(p.x, p.z), length(p), step(dd,d));
}

vec3 hue(float g) {
  return sin(vec3(0,1,2) + g)*.5+.5;
}

vec3 march(vec2 uv) {
  vec3 rd = normalize(vec3(uv, 1.));
  float d = 0.; vec4 sd = vec4(0.);
  
  for (int i = 0; i < 100; i++) {
    sd = sdf(rd * d);
    d += sd.x;
    
    if (sd.x < 0.001 || d > 100.) break;
  }
  vec3 bg = mix(hue(sd.x / 5.), vec3(sd.x), smoothstep(.2,-.4,length(uv)));
  
  vec3 fg = mix(hue(d + sin(sd.y)*3.), vec3(0), sd.w);
  
  return mix(bg, fg, step(d,20.));
}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	//vec2 m;
	//m.x = atan(uv.x / uv.y) / 3.14;
	//m.y = 1 / length(uv) * .2;
	//float d = m.y;

	//float f = texture( texFFT, d ).r * 100;
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;

	//vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0., 1. );
  //out_color = f + t;
  out_color = vec4(march(uv), 1.);
}