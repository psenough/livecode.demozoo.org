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

#define time fGlobalTime
#define INF (1./0.)
#define rep(p,s) (mod(p,(s))-(s)/2.)
#define mr(t) (mat2(cos(t),-sin(t),sin(t),cos(t)))
#define PI 3.1415926535

#define BPM 130.
#define beat (time/60.*BPM)

float ffti(float t) {
  return texture(texFFTIntegrated, t).r * exp(t*5.5);
}


float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y, p.z));
}


float hash(float t) {return fract(sin(t)*45325.32165);}
float hash(vec2 t) {return hash(dot(t,vec2(1.44,2.46423)));}

float mybox(vec3 p, vec3 s, float h) {
  float m1 = box(p,s);
  float m = INF;
  for(float i=0.;i<3.;++i) {
    p += s*vec3(
      hash(h+i),
      hash(h+1.22+i)+time,
      hash(h+1.77+i)
    );
    s *= .69;
    p=rep(p, 2.*s);
    m=min(m, box(p, s/1.7));
  }
  return max(-m, m1);
}


vec3 glow = vec3(0.);

float map(vec3 p) {
  p.x += time*.3;
  vec3 op=p;
  float m=INF;
  
  for(float i=0.; i<2.;++i) {
    p = op;
    float sx = .5;
    if(i==1.) p.x += .5*sx;
    vec2 cell = vec2(0.);
    cell.x = floor(p.x / sx);
    p.x = rep(p.x, sx);
    
    float sy = mix(.2, 1.5, hash(cell.x));
    p.y += ffti(hash(cell.x+1.32))*.15 * (i==1. ? -1. : 1.);
    cell.y = floor(p.y/sy);
    p.y = rep(p.y, sy);
    
    vec3 bs = vec3(sx/7., sy/2.2, mix(.02, .08, hash(cell)));
    //float m1=box(p, bs);
    float m1=mybox(p, bs, hash(cell+2.11));
    if(hash(cell+1.12 + floor(beat))<.3) {
      glow += vec3(1.,1.2,1.5)*.002/(m1+.01) * exp(-3.*fract(beat));
    }
    m = min(m, m1);
  }
  
  return min(m, -op.z+.1);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float blur=smoothstep(0., 1.5, dot(uv,uv));

  vec3 c=vec3(0.);
  vec3 O=vec3(0.,0.,-6.), D=vec3(uv, 6.);
  D += .2*(hash(uv+time)-.5) * blur;
  D = normalize(D);
  O.yz *= mr(-PI/4.);
  D.yz *= mr(-PI/4.);
  if(fract(beat/32.)<.5) {
    O.xy *= mr(PI/4.);
    D.xy *= mr(PI/4.);
  }
  
  float d=0.,i;
  for(i=0.;i<64.;++i) {
    vec3 p=O+D*d;
    float m=map(p);
    d += m;
    if(m<.001*d) {
      break;
    }
  }
  c += exp(-d*.07) * pow(max(0., 1.-i/32.), 3.);
  c += glow;
  c = sqrt(c);
  c *= mix(1., .3, blur);
	
	out_color = vec4(c, 0.);
}