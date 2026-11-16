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
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float sphere(vec3 rayPos, vec3 objPos, float r) {
	return r - distance(rayPos, objPos);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	//mod(uv.y * 10, 1.)
	uv.x = abs(uv.x);
	//uv.y = abs(uv.y);
	
	float c = 0.;
	float dist = 0.;
	
	int NB_STEPS = 64;
	
	float bpm = 170;
	float beat = mod(fGlobalTime, 60. / bpm);
	
	vec3 camPos = vec3(0., 0., -1.);
	
	camPos.x += sin(fGlobalTime)*0.1;
	camPos.y -= cos(fGlobalTime)*0.1;
	camPos.z -= 3.0 * sin(beat);
	
	float wave = 0;
	float colId = 0.;
	float inObj = 0.;
	vec3 normal;
	
	for (int i = 0; i < NB_STEPS; i++) {
		vec3 spherePos = vec3(1., 1., 2.);
		
		vec3 rayPos = normalize(camPos - vec3(uv.x, uv.y, 0.)) * dist;
		rayPos.x += 0.5;
		rayPos.y += 0.3;
		
		float depth = rayPos.z;
		vec3 initRayPos = rayPos;
		rayPos.z += fGlobalTime;
		
		rayPos.z = mod(rayPos.z, 5.);
		rayPos.x = mod(rayPos.x + sin(fGlobalTime*10.)*cos(rayPos.x) * 0.5, 2.);
		rayPos.y = mod(rayPos.y + cos(fGlobalTime*7.)*sin(rayPos.y) * 0.5, 2.);
		
		colId = mod(initRayPos.x, 2.);
		
		float d = sphere(rayPos, spherePos, 0.7);
		dist += d*.7;
		
		float fCoef = beat; //mod(fGlobalTime, beat);

		wave = mod(abs(initRayPos.x) + fGlobalTime*5.5, 10.);
		
		
		if (abs(d) < 0.01) {
			normal = spherePos - rayPos;
			//c = 1.0 * fCoef * (mod(rayPos.z, 0.5) * mod(depth + fGlobalTime, 20.));
			c *= 1.-abs(initRayPos.x)*0.2;
			inObj = 1.;
			break;
		}
	}
	
	vec4 f = texture(texFFT, uv.x);
	float pulse = smoothstep(c, 1.-c, beat);

	float l = dot(normal, vec3(cos(fGlobalTime), sin(fGlobalTime), 0.0));
	float lg = dot(normal, vec3(1.0, 0.0, 0.0));
	float ld = dot(normal, vec3(-1.0, 0.0, 0.0));
	
	vec4 w = vec4(1.0);
	vec4 b = vec4(0.0, 0.0, 0.0, 0.0);
	c = inObj * step(beat*1., 0.1);
	out_color = vec4(c + max(1.-abs(wave*0.1), 0.)*inObj,
	                 mix(0., 1., step(beat, 0.2))*ld,
	                 mix(0., 1., step(1.-beat, 0.3))*lg,
	                 1.0);
	out_color = mix(out_color, 1.-out_color, step(beat*2., 0.1));
	//out_color = vec4(f.r);
	
}
