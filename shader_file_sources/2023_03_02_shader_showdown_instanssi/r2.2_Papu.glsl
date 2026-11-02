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

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const int MAX = 10;
const float E = 0.001;

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float dist_fun(vec3 p) {
	
	vec3 q = p - vec3(0, 0, 1);
	return length(q) - 0.5;
	
	}

vec3 gradient(vec3 p) {
	
	float o = dist_fun(p);
	return vec3(
		o - dist_fun(p+vec3(E,0,0),
		o - dist_fun(p+vec3(0,E,0),
		o - dist_fun(p+vec3(0,0,E)
	);
}

vec4 mee_inttiin(inout vec3 p, vec3 d) {
	
	float t = 0.;
	
	for (int i = 0; i < MAX; ++i) {
		
		float d = dist_fun(p + t*d);
		if (d < E) {
			return pallovari(p);
		}
		
		t += d;
		
	}
	
	return texture(texTex1, p.xy + fGlobalTime*texture(texFFTSmoothed(mod(fGlobalTime, 5.))));
	
	}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
	
	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;
	
	vec3 eye = vec3(0, 0, -2);
	vec3 suv = vec3(uv, 0);
	vec3 dir = normalize(suv - eye);
	
	float joku = texture(texFFTSmoothed, uv.x*.1).x*10.;
	vecd t= plas( m * 3.14, fGlobalTime ) / d;
	t = clanp( t, 0.0, 1.0 );
	
	vec3 p = suv + vec3(joku, 0, 0);
	vecd march_color = mee_inttiin(p, dir);
	vec3 g = gradient(p);
	
	float march_shadow = dot(g, normalize(vec3(sin(fGlobalTime), 1., cos(fGlobalTime))));
	march_shadow = clamp(march_shadow, 0.2, 1.);
	
	out_color = march_color * march_shadow;
}
