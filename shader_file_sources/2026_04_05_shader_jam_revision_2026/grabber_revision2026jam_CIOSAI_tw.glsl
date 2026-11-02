#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define T fGlobalTime
#define PI acos(-1.)
#define TAU (PI*2.)
#define U gl_FragCoord.xy
#define R v2Resolution.xy
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	vec2 unmess = uv;
	
	float bayer[] = float[](
	0.,9.,2.,11.,
	13.,5.,15.,7.,
	3.,12.,1.,10.,
	16.,8.,14.,6.
	);
	
	float bass = texture(texFFTSmoothed, 0.05).x;
	
	vec3 col = vec3(1.,.5,.6);
	
	float t = T*2.7;
	float ti = floor(t);
	t = floor(t)+smoothstep(0.,1.,smoothstep(0.,1.,fract(t)));
	
	float rand = fract(sin(ti*498.475)*4573.3457);
	if (rand<0.25) {
		uv.x = abs(uv.x);
	}
	else if (rand<0.5) {
		uv = fract(uv);
	}
	
	vec2 ls = vec2(cos(t*0.1), sin(t*0.3));
	vec2 p = uv;
	float td = 0.;
	for(int i =0; i<99; i ++) {
		vec2 q = p;
		q *= rot(t);
		float ld = max(abs(q.x), abs(q.y))-bass*3.;
		td += max(ld,.0015);
		col -= vec3(.8,.6,1.)*0.05/ld;
		p = uv+normalize(ls-uv)*td;
	}
	
	col = clamp(col, vec3(0.),vec3(1.));
	
	if (rand<0.1){
	col = mix(col, vec3(1)-col, texture(texRevisionBW, unmess+0.5).r);
	}
	
	col = pow(col, vec3(.454545));
	col = step((bayer[int(fract(U.y/4.)*4.)*4+int(fract(U.x/4.)*4.)]+0.5)/16.,col);
	
	out_color = vec4(col, 1.);
}