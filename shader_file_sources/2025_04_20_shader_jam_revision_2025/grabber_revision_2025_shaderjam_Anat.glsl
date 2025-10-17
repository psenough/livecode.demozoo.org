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

#define time fGlobalTime
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}


mat2 rot(float v) {
   float a = cos(v);
   float b = sin(v);
  return mat2(b,-b,a,a);
}
float map(vec3 p) {
  float d = dot( cos(p), sin(p.zxy));
  float freq = 2.;
  float amp = 0.5;
  
  for(int i=0; i<5; i++) {
    d += dot( cos(p*freq), sin(p.zxy*freq))*amp;
    amp *= 0.5;
    freq *= 2.;
  }
  
  return d*.8;
}

vec3 normal(vec3 p) {
  vec2 eps = vec2(0.001, 0.);
  float d = map(p);
  vec3 n;
  
  n.x = d - map(p+eps.xyy);
  n.y = d - map(p+eps.yxy);
  n.z = d - map(p+eps.yyx);
  return normalize(n);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 pp = uv;
	pp -= 0.5;
	pp /= vec2(v2Resolution.y / v2Resolution.x, 1);
  pp *= 2.;

  float bass = texture( texFFTSmoothed, 0.1).r*10.;
  float bassInt = texture( texFFTIntegrated, 0.1).r*3.;
  vec2 pos = vec2(cos(time*2.1), sin(time))*.5;
  
  vec3 ro = vec3(1., 0., -bassInt*.1);
  vec3 rd = normalize(vec3(uv*2.-1., 1.));
  
  rd = abs(rd);
  rd.xy = rot(-bassInt*.1) * rd.xy;
  
  
  vec3 p = ro;
  float glow = 0.;
  for(int i=0; i<128; i++) {
    float d = map(p);
    p += rd * d;
    glow += .1;
  }
  vec3 n = normal(p);
  
  float t = length(p-ro);
  
  
  vec3 col = vec3(1., .7, .3)*10. / exp(length(pp-pos)*10.);  
  col = vec3(n.b*.5+.5, n.y*.75+.5, n.r) * t*bass;
  
  vec2 q = uv*2.-1.;
  float angle = atan(q.y, q.x)*.1;
  float frequency = texture(texFFT, angle).r;
  col += vec3(1.) * smoothstep(0.1, .0, abs(length(q)+frequency-.5));
  col.r = mix(texture(texPreviousFrame, uv).r, col.r, .05);
  col.g = mix(texture(texPreviousFrame, uv).g, col.g, .1);
  col.b = mix(texture(texPreviousFrame, uv).b, col.b, .15);
  
  //col = vec3(bass);
	out_color = vec4( col, 1.);
  
  
}