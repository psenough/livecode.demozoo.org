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
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time fGlobalTime
float hash(float t) {return fract(sin(t)*15652.23156);}
float hash(vec2 t) {return hash(dot(t, vec2(12.323,23.12414)));}
mat2 mr(float t) {float c=cos(t),s=sin(t); return mat2(c,s,-s,c);}
#define rep(p,s) mod(p,2.*s)-s
#define rep2(p,s) abs(rep(p, 2.*s))-s

float ffts(float t) {return texture(texFFTSmoothed, t).r;}
vec4 prev(vec2 p) {return texture(texPreviousFrame, p);}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0.);
  vec3 O=vec3(0.), D=normalize(vec3(uv, 6.));
  O.z -= 64. + 128*smoothstep(-.03, .03, sin(time/4.));
  
  float t=time*.2;
  mat2 m1=mr(.7*sin(t+sin(.33*t))),
    m2=mr(.6*sin(t+sin(.5*t)));
  O.xz *= m1;D.xz*=m1;
  O.yz *= m2;D.yz*=m2;
  float mrays = 16., mi=8.;
  vec3 OO=O, DD=D;
  for(float ray = 0.; ray<mrays; ++ray) {
    O=OO, D=DD;
    vec4 rcol=vec4(0.);rcol.a=1.;
    for(float i=0.; i<mi; ++i) {
      float fact = (i+1.*hash(uv*1.22+ray+time))/mi;
      float pd = 5.*fact;
      float d = pd-O.z/D.z;
      vec3 p=O+D*d;
      O=p;
      float seed = time+ray*1.73;
      vec3 rand=vec3(
        hash(uv+seed),
        hash(uv*1.32+seed),
        hash(uv*1.24+seed)
      );
      D += (rand-.5)*.5;
      D=normalize(D);
      float xdiv=1.;
      vec2 fl, fr;
      p.x += .2*time;
      
      float cl=.4, thresh;
      thresh = sin(time/2.)*.5+.5;
      if(hash(floor(p.x/xdiv/2.)) < thresh) {
        p.x += clamp(rep2(p.y+time, 1.8), -cl, cl);
        p.y += clamp(rep2(p.x+time, 2.6), -cl, cl);
      } else {
        p.x += clamp(rep(p.y+time, 1.8), -cl, cl);
        p.y += clamp(rep(p.x+time, 2.6), -cl, cl);
      }
      fl.x=floor(p.x/xdiv);
      fr.x = fract(p.x/xdiv);
      float ydiv = 4. + 12.*floor(5.*hash(fl.x+.16));
      p.y += 4.*hash(floor(p.y/8.));
      p.y += 2.*hash(floor(p.x*8.))*(hash(fl.x+.22)<.5?1.:0.);
      p.y -= time*(.5+4.*(floor(hash(fl.x)*5.)-2.));
      fl.y = floor(p.y/ydiv);
      fr.y=fract(p.y/ydiv);
      float h=step(0.4,fr.y) * step(abs(fr.x-.5), .4);
      h *= step(mix(.4, 0., min(1., ffts(fl.x*.37)*40.)), fact);
      
      //float h=hash(floor(p.xy) + 23*floor(p.z*.25+2.*time+hash(floor(p.xy))));
      //h=pow(h, 5.);
      //h=step(h, .1);
      if (h>0.) rcol.a *= exp(-(fact-.25)*5.);
      rcol.rgb += h*rcol.a*normalize(rand)*.6;
    }
    col += rcol.rgb/mrays;
  }
  
  col = sqrt(col);
	out_color = vec4(col, 1.);
}