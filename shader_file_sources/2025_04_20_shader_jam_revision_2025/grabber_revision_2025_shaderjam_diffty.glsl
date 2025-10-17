 #version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void main(void)
{
	float bpm = 180.;
	
	float bpmFreq = 1. / (bpm / 60.);
	
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	
	vec2 uv1 = uv;
	uv1.x = 0. - abs(uv1.x); //abs(0.-uv.x);
	
	/* vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t; */
	
	float bpmPulse = mod(fGlobalTime, bpmFreq) * (1. / bpmFreq);
	
	/* cc = cc * ((uv.x + 1.) / 2.); */
	
	float cc = step(min(abs(uv1.x), 0.1) * 10., bpmPulse*2.);
	
	float circle = sqrt(uv1.x * uv1.x + uv1.y * uv1.y);
	float circle2 = sqrt(uv1.x * uv1.x + uv1.y * uv1.y) * floor(mod(fGlobalTime * (bpmFreq*10.), 10.));
	cc = cc - circle - circle2;
	
	float mask = uv1.x;

	vec4 c = vec4(circle2*bpmPulse, 0., circle*bpmPulse, 1) * cc* mask;
	
	vec2 uv2 = vec2(cos(fGlobalTime*bpmPulse*0.01) * uv.x, sin(fGlobalTime*bpmPulse*0.01) * uv.y);
	
	float angleRot = mod(fGlobalTime * 3., 3.14);
	vec2 uv3 = uv; //vec2(mod(uv.x, 0.2), mod(uv.y, 0.2));
	uv3.x = 0. - abs(uv3.x); //abs(0.-uv.x);
	uv3 = vec2(uv3.x * cos(angleRot) - uv3.y * sin(angleRot), uv3.x * sin(angleRot) + uv3.y * cos(angleRot));
	float ligneVert = 1. - step(abs(uv3.x * 10.), 0.5);
	float ligneHoz = 1. - step(abs(uv3.y * 10.), 0.5);
	
	c = c * ligneVert * ligneHoz;
	

	//circle3 = sqrt(uv1.x * uv1.x + uv1.y * uv1.y);
	
	// c = step(circle3;
	
	c = (1. - c) * (bpmPulse) + (c) * (1. - bpmPulse);
	//c = c * step(bpmPulse, 0.5);
	
	c = c + texture(texPreviousFrame, vec2(uv.x, uv.y+0.5)) * 0.9;
	c = 1.-c;
	out_color = c;
}