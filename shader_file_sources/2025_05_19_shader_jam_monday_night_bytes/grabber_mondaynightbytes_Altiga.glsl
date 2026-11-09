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

vec2 ep = vec2(0.002, 0);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec2 map(vec3 p) {
  return vec2(length(p) - 2., 0);
}

vec2 march(vec3 p, vec3 rd) {
  vec2 d = vec2(0, 0);
  vec3 pp = p;
  
  for (int i = 0; i < 256; i++) {
    vec2 dd = map(p + rd * d.x);
    d.x += dd.x;
    d.y = dd.y;
    if (dd.x < 0.001 || d.x > 1000.) break;
  }
  
  return d;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv.x += texture(texFFT, uv.y - .5).x * 3;

	//vec2 m;
	//m.x = atan(uv.x / uv.y) / 3.14;
	//m.y = 1 / length(uv) * .2;
	//float d = m.y;
  vec3 cp = vec3(0,0,5), ct = vec3(0,0,0);
  
  vec3 ro = cp;
  vec3 fo = normalize(ct - ro);
  vec3 left = normalize(cross(fo, vec3(0,1,0)));
  vec3 up = normalize(cross(left, fo));
  
  vec3 rd = mat3(left,up,fo) * normalize(vec3(uv,.5));
  vec2 m = march(ro, rd);
  vec3 p = ro + rd * m.x;
  vec3 normals=normalize(ep.xyy*map(p+ep.xyy).x+ep.yyx*map(p+ep.yyx).x+ep.yxy*map(p+ep.yxy).x+
                               ep.xxx*map(p+ep.xxx).x);

	//vec4 t = vec4(sin(m.y), cos(m.y), sin(m.x), 1.);
	//t = clamp( t, 0.0, 1.0 );
	//out_color = t;
  
  vec3 c = vec3(step(m.x, 100));
  c += mix(vec3(0,.5,1), vec3(0,1,.5), texture(texFFT, uv.y / 50. - .5).x);
  out_color = vec4(c, 1);
}