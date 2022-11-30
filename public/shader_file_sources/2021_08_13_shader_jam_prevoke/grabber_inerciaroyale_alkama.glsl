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

float pi = acos(-1);
float ttt = mod(fGlobalTime*80/120, 20*pi);
float ft=fract(ttt);
float dt=floor(ttt);
float t=dt+ft*ft;

float disc( vec3 p, float s )
{
	return smoothstep(.504,0.5,(length(p)-((s-51)/100.)))-smoothstep(.504,0.5,(length(p)-((s-52)/100.)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv2=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	uv = mix(uv, uv * (.25 - length(uv)), abs(sin(t+cos(t))));
  
	vec3 col = vec3(0);
	for(float j=1; j<1000; j++) {
    //float i=j;
		//float i=sqrt(j*(j+100*abs(sin(j*.001+t*.01))));
		float i=mix(j, j*j*.001*sin(t*.04), abs(sin(t*.005)));
		vec3 cd = vec3(
			uv.x+i*(.001+0.00025*sin(t))*sin(t-i*(1.+(.1+.15*sin(t*.01))+.00015*sin(t+sin(t)))),
			uv.y+i*(.001+0.00025*cos(t))*cos(t-i*(1.+(.1+.15*sin(t*.01))+.00015*cos(t+sin(t)))),
			0);
		col += disc(cd, .87+i/(300.+150.*sin(t*5+sin(t))))*abs(vec3(cos((i-ttt*500)/100),sin((i-ttt*2000)/1000), sin((i-ttt*2000)/100)));
	}
	//vec3 prev = texture(texPreviousFrame,uv2).rgb;
	vec3 prev = texture(texPreviousFrame,uv*vec2(.5+.3*sin(t),.5+.3*cos(t))+.5).rgb;
	out_color.rgb = mix(prev,col, .2+.15*sin(t));
}