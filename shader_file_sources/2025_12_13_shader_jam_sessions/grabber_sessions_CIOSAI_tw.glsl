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
uniform sampler2D texShort;
uniform sampler2D texSessions;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define rot(n) mat2(cos(n), sin(-n), sin(n), cos(n))
#define R v2Resolution
#define PI acos(-1.)
#define TAU (PI*2.)
#define BPM 148.

uint seed_;
uint hashi_( uint x) {
    x ^= x >> 16;
    x *= 0x7feb352dU;
    x ^= x >> 15;
    x *= 0x846ca68bU;
    x ^= x >> 16;
    return x;
}
float hash_f_s_(uint s) {return ( float( hashi_(uint(s)) ) / float( 0xffffffffU ) );}
float hash_f_()  { seed_ = hashi_(seed_);
  return ( float( seed_ ) / float( 0xffffffffU ) );}
vec2 hash_v2_() {return vec2(hash_f_(),hash_f_());}
vec3 hash_v3_() {return vec3(hash_f_(),hash_f_(),hash_f_());}

vec3 shortt(vec2 uv){
    vec2 size = textureSize(texShort,0);
    float ratio = size.x/size.y;
    return texture(texShort,uv*vec2(1,-1*ratio)-.5).rgb;
}

vec3 long(vec2 uv){
    vec2 size = textureSize(texSessions,0);
    float ratio = size.x/size.y;
    return texture(texSessions,uv*vec2(1,-1*ratio)-.5).rgb;
}

void savePtc(ivec2 dataLoc, vec4 data) {
	if (dataLoc == ivec2(gl_FragCoord)) {
		out_color = data/4.+0.5;
	}
}

vec4 readPtc(ivec2 dataLoc) {
	return (texelFetch(texPreviousFrame, dataLoc, 0)-0.5)*4.;
}

vec3 blur(vec2 p, float size) {
  float px = size/max(v2Resolution.x, v2Resolution.y);
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
vec3 sharpen(vec2 p, float size) {
  float px = size/max(v2Resolution.x, v2Resolution.y);
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
	// define particles
	ivec2 BALL = ivec2(500,500);
	vec2 ballpos = vec2(0);
	vec2 ballvel = vec2(0);
	const int BALLZ = 16;
	vec2 ballsP[BALLZ];
	vec2 ballsV[BALLZ];
	for (int i=0; i<BALLZ; i++)
	{
		ballsP[i] = vec2(0);
		ballsV[i] = vec2(0);
	}
	// read particles
	{
		vec4 r = readPtc(BALL);
		ballpos = r.xy;
		ballvel = r.zw;
		
		for (int i=0; i<BALLZ; i++) {
			vec4 uwu = readPtc(BALL+ivec2(i,0));
			ballsP[i] = uwu.xy;
			ballsV[i] = uwu.zw;
		}
	}

	vec2 p = vec2(gl_FragCoord.x / R.x, gl_FragCoord.y / R.y);
	p -= 0.5;
	float ratio = R.y / R.x;
	p /= vec2(ratio, 1);
	

	vec3 c = vec3(0);

  float o_t = fGlobalTime/(60./BPM);
  float t = floor(o_t)+1.-exp(-fract(o_t)*5.);
	
	
	// iterated process
	float dt = fFrameTime;
	float direction = 1.-exp(-fract(o_t)*5.)*1.; // 1 for toward, 0 for push apart
	for (int i=0; i<BALLZ; i++){
		
		float j = float(i);
		float force = exp(-fract(o_t)*5.)*11.;
		vec2 acc = vec2(0);
		acc += force*normalize(vec2(cos(o_t*.2+sin(j)*6.),sin(o_t*.2+cos(j)*6.)));
		vec2 nbP = ballsP[(i+1)-int(floor(float(i+1.)))];
		acc += mix(-18.,18.,direction)*normalize(nbP-ballsP[i])/(1.+length(nbP-ballsP[i]));
		
		ballsV[i] += acc * dt;
		ballsV[i] *= min(1., max(0., mix(1., 0., sqrt(dt*60.)/(60.-47.))));
		ballsP[i] += ballsV[i] * dt;
		
		if (ballsP[i].y>.501 || ballsP[i].y<-.501) {
			ballsP[i].y = fract(ballsP[i].y+0.5)-0.5;
		}
		float funny = 1.8;
		float funnierRatio = ratio*funny;
		if (ballsP[i].x>funnierRatio+.001) {
			ballsP[i].x = (ballsP[i].x-floor(ballsP[i].x/funnierRatio+funny*0.5)-funny*0.5)*funnierRatio;
		}
		if (ballpos.x<-funnierRatio-.001) {
			ballsP[i].x = (ballsP[i].x-floor(ballsP[i].x/funnierRatio+funny+0.5)+funny*1.6)*funnierRatio;
		}
		
		// reset
		if (fract(t/32.)<0.02) {
		ballsP[i] = vec2(0);
		ballsV[i] = vec2(0);
		}
	}
	
	
	vec2 samp_uv = (p*(1-fract(t)*.0))*vec2(v2Resolution.y / v2Resolution.x, 1)+0.5;
	
	float width = exp(-fract(t)*2.)*10.;
	
	vec3 here = texture2D(texPreviousFrame, samp_uv).rgb;
  vec3 b = blur(samp_uv-here.rb*.001, width);
  vec3 s = sharpen(samp_uv-here.rb*.001, width);
  c = clamp(b+s,vec3(-1), vec3(1));

  int hit_status = 0;
	
	float ball = 99.;
	for (int i=0; i<BALLZ; i++) {
		ball = min(ball, length(p-ballsP[i]));
	}
	if (ball<0.025) {
		hit_status=1;
	}
	
	if (sin(p.y*TAU+t*.1)>0.995) {
		hit_status=2;
	}

  if (hit_status==1) {
		vec2 i_p = floor(p*8.);
		seed_ = uint(abs(i_p.y*8.+i_p.x*27.));
    c = vec3(abs(hash_v3_()));
  }
		vec3 anotherC = vec3(0);
		vec3 rd = normalize(vec3(p, 1.)),
		     ro = vec3(0);
		float td=0., ld=0.;
		for (int i=0; i<32.; i++) {
			vec3 pos = ro+rd*td;
			pos.z -= 1.;
			pos.yz *= rot(t*.03);
			pos.zx *= rot(t*.07);
			
			ld = box(pos)-0.25;
			ld = max(.0015, ld);
			anotherC += .1/(ld*ld*float(1+i)*420.);
			td += ld;
		}
		anotherC = min(vec3(1.), max(vec3(0.), anotherC));
		c = min(c, mix(c, anotherC, 0.8));
  if (hit_status==2) {
    c = vec3(0);
  }
	
	out_color = vec4(vec3(c),1);
	
	out_color -= vec4(long(p+vec2(o_t*.02,0))*0.1, 1);
	
	// save particles
	{
		savePtc(BALL, vec4(ballpos, ballvel));
		for (int i=0; i<BALLZ; i++) {
			savePtc(BALL+ivec2(i,0), vec4(ballsP[i], ballsV[i]));
		}
	}
}