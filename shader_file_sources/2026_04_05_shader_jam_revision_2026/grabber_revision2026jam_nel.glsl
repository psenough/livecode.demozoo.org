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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec3 load() {
	uint r = imageLoad(computeTex[0], ivec2(gl_FragCoord)).r;
  uint g = imageLoad(computeTex[1], ivec2(gl_FragCoord)).r;
  uint b = imageLoad(computeTex[2], ivec2(gl_FragCoord)).r;
	return vec3(r, g, b) / 255.0;
}

void store(vec2 p, vec3 c) {
	ivec2 ip = ivec2(vec2((p + vec2(.5)) * v2Resolution));
	imageStore(computeTex[0], ip, uvec4(c.r * 255.));
	imageStore(computeTex[1], ip + ivec2(0), uvec4(c.g * 255.));
	imageStore(computeTex[2], ip - ivec2(0), uvec4(c.b * 255.));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	//ivec2 size = ivec2(v2Resolution);
	
	/*vec3 pr = prev();
	
	// Compute pass
	float t = texture(texFFT, .2).r;
	float t2 = texture(texFFT, .7).r;
	float ra = hash11(length(gl_FragCoord) + t) * 2 * 3.15;
	float r2 = hash11(length(gl_FragCoord) + t + gl_FragCoord.x);
	vec2 p = 40 * t * r2 * vec2(cos(ra), sin(ra));
	p = vec2(cos(uv.x * 1000. * t), sin(uv.y * t * 70) * 1);
	p.y *= tan(p.x * 3.14 * 1. * ra + fGlobalTime);
	p.x *= tan(p.y * 3.14 * 2. + fGlobalTime);
	
	vec3 n = texture(texNoise, uv).rgb;
	
	//p += vec2(pr) * 1.;
	//p += vec2(cos(p.x), sin(p.y)) * 0.39;
	*/
	
	// Store in p
	store(uv, vec3(1.));
	
	// Read back compute texture
	out_color = vec4(load(), 1.);
	//out_color = vec4(pr, 1.0);
}