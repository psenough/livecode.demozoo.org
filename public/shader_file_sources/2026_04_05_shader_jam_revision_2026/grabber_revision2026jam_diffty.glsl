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
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;
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
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	// float f = texture( texFFT, d ).r * 100;
	int MAX_STEP = 100;
	
	float c = 0;
	
	for (int i = 0; i < MAX_STEP; i++) {
		float distance = 1. - sqrt((uv.x - 0.0) * (uv.x - 0.0) + (uv.y - 0.0) * (uv.y - 0.0));
	}
	
	float BPM = 144.;
	float BPS = BPM / 60.;
	float beat = mod(fGlobalTime, 60. / BPM * 4.);

	vec2 roundPos = vec2(0., 0.);
	c = (uv.x - roundPos.x);
	
	out_color = vec4(c, c, c, 1.0);
	out_color = out_color * beat + (1.-out_color) * (1.-beat);
	
	// uv.x = mod(uv.x, 0.2);
	
	float c1 = 1. - sqrt((uv.x - 0.0) * (uv.x - 0.0) + (uv.y - 0.0) * (uv.y - 0.0)) * 5. * (beat);
	float c3 = 1. - sqrt((uv.x - 0.0) * (uv.x - 0.0) + (uv.y - 0.0) * (uv.y - 0.0)) * 2. * (beat);
	
	float final_color = c1;
	out_color = vec4(final_color, final_color, final_color, 1.0);

}