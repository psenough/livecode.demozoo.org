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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float hash(float t)  {return fract(sin(t)*35135.3135);}

#define rep(p,s) (mod(p,s)-s/2.)
#define time fGlobalTime
#define beat (time*135./60.)

mat2 mr(float t) {
  float c=cos(t),s=sin(t);
  return mat2(c,s,-s,c);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 uv0=uv;
  
  vec3 col;
  
  for(float l=0.;l<4.;++l) {
    uv=uv0;
    uv /= dot(uv,uv);
    uv += .1*vec2(sin(time+.3*l), cos(.7*time+1.5*l));
    uv *= mr(sin(time/16.)+
      .7*exp(-fract(beat))*(hash(floor(beat))-.5)
    );
    if(mod(beat, 8.)>1.)uv /= dot(uv,uv);
    
    uv*= 12.*(1.+l/mix(16., 32., exp(-fract(beat))));
    uv.y += hash(floor(beat/2.))*16.;
    uv.y *= .5+abs(sin(uv.y+time))*mix(.1, .3, hash(floor(beat/4.)));
    
  for(float i=0.; i<6.;++i) {
    vec2 p=uv;
    p.y += 2.;
    float yfl=floor(p.y);
    float b=beat-hash(i+hash(sign(uv.y)))*hash(floor(beat)+l);
    p.x += hash(floor(p.y*16.)+i+b-l)*exp(-fract(beat)*5.)*mix(2., 6., hash(floor(b+1.3)));
    p.x += time*(hash(yfl)-.5)*4.;
    p.x = rep(p.x, mix(2., 32., hash(yfl+floor(b)+1.13)));
    col[int(i)] += pow(hash(yfl+floor(p.x*mix(.5, 2.5, pow(hash(floor(beat)+.22), 4.)))), 
      mix(8., 3., exp(-fract(beat)))) * exp(-l*.5);
  }
}
  
	out_color = vec4(col, 1.);
}