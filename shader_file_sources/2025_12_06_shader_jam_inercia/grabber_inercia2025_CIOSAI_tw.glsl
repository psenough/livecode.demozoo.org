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

#define rot(n) mat2(cos(n), sin(-n), sin(n), cos(n))

vec3 blur(vec2 p) {
  float px = 2./max(v2Resolution.x, v2Resolution.y);
  vec3 c=vec3(0);
  mat3 kern;
  kern[0]=vec3(1./9.);
  kern[1]=vec3(1./9.);
  kern[2]=vec3(1./9.);
  for(int i=-1; i<=1; i++){
    for(int j=-1; j<=1; j++){
      c += texture2D(texPreviousFrame, p+vec2(float(i), float(j))*px).rgb * kern[i+1][j+1];
    }
  }
  return c;
}
vec3 sharpen(vec2 p) {
  float px = 2./max(v2Resolution.x, v2Resolution.y);
  vec3 c=vec3(0);
  mat3 kern;
  kern[0]=vec3(0.0  , 1./4., 0.0);
  kern[1]=vec3(1./4., -1.  , 1./4.);
  kern[2]=vec3(0.0  , 1./4., 0.0);
  for(int i=-1; i<=1; i++){
    for(int j=-1; j<=1; j++){
      c += texture2D(texPreviousFrame, p+vec2(float(i), float(j))*px).rgb * kern[i+1][j+1];
    }
  }
  return c;
}

float box(vec3 p) {
  vec3 q = abs(p);
  return max(max(q.x, q.y), q.z);
}

void main(void)
{
	vec2 p = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	p -= 0.5;
	p /= vec2(v2Resolution.y / v2Resolution.x, 1);
	

	vec3 c = vec3(0);

  float t = fGlobalTime*2.6;
  t = floor(t)+1.-exp(-fract(t)*3.);
	vec2 samp_uv = (p*(1-fract(t)*.02))*vec2(v2Resolution.y / v2Resolution.x, 1)+0.5;
	
	vec3 here = texture2D(texPreviousFrame, samp_uv).rgb;
  vec3 b = blur(samp_uv-here.rb*.001);
  vec3 s = sharpen(samp_uv-here.rb*.001);
  c = clamp(b+s,vec3(-1), vec3(1));

  int hit_status = 0;
	
	float ball = 99.;
	int ballAmount = 5;
	vec2[16] balls; 
	for (int i=0; i<ballAmount; i++) {
		float j = float(i+1);
		balls[i] = vec2(cos(t*.16*j+j),cos(t*.07*j+j));
	}
	for (int i=0; i<64; i++) {
		int meId = (i*427+i)%ballAmount;
		int nbId = (i*541+i)%ballAmount;
		if (meId==nbId) {continue;}
		vec2 toward = normalize(balls[nbId]-balls[meId]);
		toward *= rot(3.1415/2.);
		balls[meId] += toward*0.1;
	}
	for (int i=0; i<ballAmount; i++) {
		ball = min(ball, length(p*3.-balls[i]));
	}
	if (ball<0.05) {
		hit_status=1;
	}
	
	float fan = p.x;
	if (abs(fan-(fract(t*.15)*2.-1.))<.05) {
		hit_status=2;
	}

  if (hit_status==1) {
    c = vec3(0.5)+sin(vec3(0.,1.,1.1)+length(p)*64.)*0.5;
  }
  if (hit_status==2) {
    c = vec3(0);
  }
	
	out_color = vec4(vec3(c),1);
}