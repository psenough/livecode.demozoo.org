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

float sdf(vec3 p, float f, out vec3 col){
  col = vec3(1.0, 0.0, 0.50);
  return length(p) - 2.0 - f;
}

vec3 sdfnormal(vec3 p, float f){
  float e = 0.001;
  vec3 c;
  return normalize(vec3(sdf(vec3(p.x + e, p.y, p.z), f, c) - sdf(vec3(p.x - e, p.y, p.z), f, c),
  sdf(vec3(p.x, p.y + e, p.z), f, c) - sdf(vec3(p.x, p.y - e, p.z), f, c),
  sdf(vec3(p.x, p.y, p.z + e), f, c) - sdf(vec3(p.x, p.y, p.z - e), f, c)));
}

float marcherdepth(vec3 eye, vec3 ray, float f, out vec3 col, out int finalsteps, out float dist){
  float depth = 0.00001;
  for(int steps =  0; steps < 30; steps++){
    vec3 p = eye + ray * depth;
    float sd = sdf(p, f, col);
    if (sd < 0.01){
      dist = sd;
      finalsteps = steps;
      return depth;
    }
    else depth += sd;
  }
  return 0.0;
}

void main(void)
{
  vec3 a;
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
  
  vec3 eye = vec3(0.0, 0.0, -11.0);
  vec3 frust = vec3(uv.x, uv.y, -10.0);
  vec3 ray = normalize(frust - eye);
  vec3 col;
  int steps;
  float dist;
  float dep = marcherdepth(eye, ray, f, col, steps, dist);
  
  vec3 p = eye + dep * ray;
  vec3 n = sdfnormal(p, f);
  
  vec3 light = normalize(-vec3(1.0));
  
  float b = dot(n, light);
//  float dtex = texture(texTex4, vec2(n.x, n.y));
  vec3 bcol = col * b;
  
  float o = float(steps) / 100.0;
  
  vec3 oc = bcol + 0.5*vec3(f + t);
  out_color = vec4(oc.x, oc.y, oc.z, 0.0);
  vec4 tex = texture(texTex1, uv);
  // out_color = tex;
}