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
#define time fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float eps = 0.001;

#define r2d(p,a) p=cos(a)*p+sin(a)*vec2(-p.y,p.x);

vec3 hash(vec3 p) {
  p = fract(p * vec3(443.897,441.423,437.195));
	p += dot(p, p.yxz + 19.19);
	return fract((p.xxy + p.yxx) * p.zyx);
}

float pDist(vec3 p, vec3 d, vec4 plane) {
	float dist = dot(plane.xyz * plane.w - p, plane.xyz) / dot(d, plane.xyz);
  return dist<0 ? 9999999. : dist;
}

float check(vec2 p, float s, vec2 o) {
	ivec2 t = ivec2(p*s+o);
 	return float((
		t.x%2+t.y%2
	)%2);
}

float feedback() {
  float fb=0;
  return fb;
}

void main(void)
{
  float fft = texture(texFFT, 0.01).x;
  float ftime = texture(texFFTIntegrated,0.01).x;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);

  vec3 o = vec3(0,0,0);
//  o.rgb += texture(texPreviousFrame, (uv-.5)*.99+.5).rgb;

	uv -= 0.5;
  vec2 aspect = vec2(v2Resolution.y / v2Resolution.x, 1);
	uv /= aspect;

  vec3 p = vec3(sin(ftime/8)/90,sin(ftime/12)/190,-1);
  r2d(uv, pow(sin(ftime/7),5)/30.);
  vec3 d = normalize(vec3(uv, 1));
  
  float dist = pDist(p,d, vec4(normalize(vec3(sin(ftime/3)*.03,cos(ftime/2)*.03,-1)),-.11));
  p += d * dist;
  
  if (mod(ftime, 8.) < 4.)
  p.xy=abs(p.xy);
  float fb = texture(texPreviousFrame, p.xy * aspect / (9./16.) * .5 + .5).a;
  int s = int(ftime*4)%8+4;
//  fb += (((int(p.x*s+time)%2+int(p.y*s+time+10)%2)%2)
  // -.5)*fft/4.;
  //o.rgb = vec3(dist/4.);
  fb += (check(p.xy, float(s), vec2(time + 10))-.5)*fft/3.;
  o.r += (1.-smoothstep(0.,0.01,abs(length(uv) - .5))) * fft*8.;
  fb += hash(vec3(uv, time)).x*.1-.05;
  fb=fract((fb-.5)*(pow(sin(ftime), 5.)*0.05+1.05)+.5);
	//float f = texture( texFFT, d ).r * 100;
  o += fb;
	out_color = vec4(o, fb);
}