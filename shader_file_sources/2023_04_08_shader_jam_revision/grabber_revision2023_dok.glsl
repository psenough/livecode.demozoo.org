#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float ff(vec2 a, int x){
	vec2 v = clamp(fract(a),0,1);
	int i = int(fract(1.0-v.x) * 4) + 4*int(fract(v.y)*6);
	return (x & (1<<i)) != 0? 0.0 : 1.0;
}

float rd(float a, float x) {
	return sin((a+x)*sin(a+x));
	}
void main(void)
{
	vec2 uv = (gl_FragCoord.xy - 0 * v2Resolution);// / v2Resolution.y;
vec3 col = vec3(0);
	

	
	vec2 UV = gl_FragCoord.xy/vec2(40,60);
	uv = gl_FragCoord.xy/vec2(40,60);
	uv += 0.5;
	//uv /=mix(1,2,0.5+0.5*sin(fGlobalTime/10.0));
	uv.x /= mix(1,5,0.5+.5*sin(fGlobalTime/10.0));
	uv = fract(floor(uv*vec2(4,6))/vec2(4,6));

	int ch = 0;
	float X=0;
	if (fract(fGlobalTime/6)>0.5)
		X=0.5*UV.x+fGlobalTime;
	if (fract(fGlobalTime/8)>0.5)
		X=0.25*UV.y+fGlobalTime;

	switch (int(fract(X+fGlobalTime/3)*6)) {
	case 0:
		ch = 0x7131; break;
	case 1:
		ch = 0x1113; break;		
	case 2:
		ch = 0x71317; break;		
	case 3:
		ch=0x1311; break;
	case 4:
		ch=0x7122; break;
	case 5:
		ch = 0x22202; break;
	}
	if (texture(texFFTSmoothed, 0.04).r > 0.7)
		ch += int(fGlobalTime);
	col.r = ff(uv, ch);

	
//	col.r = ff(uv, int(0xf45f * rd(fGlobalTime/10, uv.x)));
	
	col = 1.0-col.rrr;
	float x = 0.0;
	UV/= 5;
	UV = clamp(UV,0,1)+0.001;
	x = ff(UV, int(0x7131));

	uv = (gl_FragCoord.xy - 0 * v2Resolution)/ v2Resolution.y;

	float a=1;
	        for (float i =0; i<1.0; i+=0.05) {
                vec2 d = vec2(0.35, 0.69);
                vec2 p = d * (fGlobalTime-i*mix(0.5,1.5,sin(fGlobalTime)));
                vec2 r = v2Resolution / v2Resolution.y;
                vec2 v = (0.5 - fract(p/r))*r;
                a *= step(0.1,length((2*sign(v) * v)- uv));
        }
	a=1-a;
	col.r = 1.-x;
	if (texture(texFFTSmoothed, 0.01).r > 0.7)
	col = 1.0-col;
	if (a > 0)
		col.g = 1.0-col.g;
	col = col.g * vec3(0,1,0.2);
	out_color = vec4(col,1);
}