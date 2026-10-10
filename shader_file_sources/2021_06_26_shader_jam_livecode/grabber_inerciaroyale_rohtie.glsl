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
uniform float fMidiKnob;

#define time fGlobalTime

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

mat2 rotate(float a) {
	return mat2(-sin(a), cos(a),
		     cos(a), sin(a));
}

float map(vec3 p) {
	
	//p.zy *= rotate(sin(time * 20.) * .2);
	p.xz *= rotate(sin(time * 20.) * .5 + 2.);
	
	float r = 1.;
	
	
	p.x = abs(p.x);
	
	{
		float head = length(p * vec3(1.0, 1.5 + sin(p.x) * .4 + sin(time * 2.) * .5, 1.0)) - 1.2;
		//head = max(head, -(length(p - vec2(0.5, 0.)) - .5);
		
		float arms = length(p - vec3(1.0, sin(time * 2.) * .2 + 0.5 + sin(p.x * 5. + 3.), 0.)) - .4;
		
		head = min(head, arms);
		
		float eyes = length(p - vec3(.5, 0. + sin(time * 2.) * .05, 1.2)) - .2;
		float eyes_sock = length(p - vec3(.5, 0. + sin(time * 2.) * .05, .8)) - .45;		
		
		head = min(head, eyes);
		head = max(head, -eyes_sock);
		
		float body = length(p * vec3(1., .4, 1.) - vec3(0., -1.5, -1.5)) - 1.5;
		head = min(head, body);
		
		
		r = min(r, head);
	}
	
	{
		
	}
	
	
	return r - smoothstep(0.1, 0.3, texture(texNoise, p.xz * .5 + time * 0.05 + sin(p.y * 4.)).r) * 0.03;
	
/*	float r = 1.;
	
	for (int i=0; i<5; i++) {
		p.y += sin(p.x * 6. + time * 4.) * .5;
		p.x += sin(p.y * 2.);		
		
		p.xz *= rotate(i * .1);
		p.x += 1.5;
		
		r = min(r, length(max(abs(p) - .4, 0.)) - .5);
	}
	
	return r;*/
}

void main(void)
{
	float time = fGlobalTime;
	
	vec2 p = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = p;
	p -= 0.5;
	p /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec2 uv = p;
	

	float ket = 0.;

	if (p.x > 0.) {
		p.y += sin(p.x * 2 + time * 4.) * .15;
		p.y = 1. - p.y - 1.;
		ket = 1.;
	}
	
	
	if (length(max(abs(p) - vec2(.75, .35), 0.)) > .1) {
		out_color = vec4(1.);
		return;
	}
	

	p.x += texture(texFFT, p.y * .5 + .5).r * 6.;
	
	p.y += 0.075;
	p.x = abs(p.x) - .5;
	p *= 0.8;
	
	
	vec3 cam = vec3(0., 0., 5.);
	vec3 ray = vec3(p, -1.);
	
	float dist = 0.;
	
	for (int i=0; i<25; i++) {
		vec3 p = cam + ray * dist;
		
		float tmp = map(p);
		
		if (tmp < 0.01) {
			vec3 light = vec3(sin(time * 0.5) * 1.2, 0., -1.);
			float shadow = map(p - light);
			out_color = vec4(1. - ket, 1., p.y * 1. + 0.85 + ket * 200., 0.) * shadow * smoothstep(0.1, 0.3, texture(texNoise, p.xz * .5 + time * 0.05 + sin(p.y * 4.)).r) * 1.2 + abs(p.x) * .1 + vec4(mod(p.y, .2), 0., 0., 0.);
			return;
		}
		
		dist += tmp;
	}
	
	
	
	
	
	//p.y = abs(p.x) * .5;
	
	p.x += abs(p.y);
	
	p.y += sin(p.x * 4. + tan(time * .2)) * .5 * ket;
	p.x += sin( + time * 2. + p.y * 5. + tan(p.x * 2. + time * .5)) * .4 * ket;
	p.y += texture(texFFT, p.x).r * 20.;
	

	
	if (length(p) > 0.5) {
		//q *= 1.05;
		q -= 0.0025;
		
		if (ket > 0.) {
			q.x *= .99;
		}
		
		//q.x -= 0.005;
		//q.y /= 1.1 + sin(p.x);
		out_color = texture(texPreviousFrame, q).brgr * vec4(.5, 1., sin(time * 20.), 2.);
		return;
	}
	
	out_color = vec4(1. + sin(time), 5.5 + tan(time * 5.) + p.y * 1.5, abs(p.y), 0.).ggrr * .05 + tan(time * 5.);
	
	if (ket > 0.) {
		out_color = vec4(1. + sin(time * 20.), 1.5 + tan(time * 5.) + p.y * 1.5, abs(p.y), 0.) * 20.;
	}
	return;
	
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
}