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

float time=mod(fGlobalTime, 300);

// 26 letters + some numbers
const int Letters[31] = int[31](23535,31471,25166,31595,29391,4815,31310,23533,29847,13463,23277,29257,23423,23403,15214,5103,26474,23279,14798,9367,27501,12141,32621,23213,31213,29351,31727,448,5393,29671,31599);

float textcolor=7.;
void String6(inout float prev, inout vec2 uv, int val) {
    float a = 0.;
    uv = floor(uv);
    for(int i=0; i<6; ++i) {
        int cdig = int(val)%32;
        if(cdig!=0) {
			vec2 mask = step(abs(uv-vec2(1.3,2.5)),vec2(1.5,2.5));
			a += float((Letters[cdig-1]>>int(uv.x+uv.y*3.))&1)*mask.x*mask.y;
        }
        uv.x -= 4.;
        val/=32;
    }
    
    if(a>.1) prev=textcolor;
}

// TIC-80 palette

const vec3 Paltic[16] = vec3[16](vec3(0.1, 0.11, 0.17), vec3(0.36, 0.15, 0.36), vec3(0.69, 0.24, 0.33), vec3(0.94, 0.49, 0.34)
                            , vec3(1.0, 0.8, 0.46), vec3(0.65, 0.94, 0.44), vec3(0.22, 0.72, 0.39), vec3(0.15, 0.44, 0.47)
                            , vec3(0.16, 0.21, 0.44), vec3(0.23, 0.36, 0.79), vec3(0.25, 0.65, 0.96), vec3(0.45, 0.94, 0.97)
                            , vec3(0.96, 0.96, 0.96), vec3(0.58, 0.69, 0.76), vec3(0.34, 0.42, 0.53), vec3(0.2, 0.24, 0.34));



const vec3 Palpico[16] = vec3[16](vec3(0),vec3(0.125,0.2,0.48),vec3(0.494,0.145,0.325),vec3(0,0.513,0.192),
                              vec3(0.74,0.321,0.211),vec3(0.27),vec3(0.76,0.764,0.78),vec3(1,0.945,0.91),
                              vec3(1,0,0.3),vec3(1,0.639,0),vec3(1,0.925,0.153),vec3(0,0.886,0.196),
                              vec3(0.16,0.678,1),vec3(0.513,0.463,0.611),vec3(1,0.467,0.659),vec3(1,0.8,0.667));


const vec3[16] palAppleII = vec3[16](
    vec3(217, 60, 240)/255.,
    vec3(64, 53, 120)/255.,
    vec3(108, 41, 64)/255.,
    vec3(0, 0, 0)/255.,

    vec3(236, 168, 191)/255.,
    vec3(128, 128, 128)/255.,
    vec3(217, 104, 15)/255.,
    vec3(64, 75, 7)/255.,

    vec3(191, 180, 248)/255.,
    vec3(38, 151, 240)/255.,
    vec3(128, 128, 128)/255.,
    vec3(19, 87, 64)/255.,

    vec3(255, 255, 255)/255.,
    vec3(147, 214, 191)/255.,
    vec3(191, 202, 135)/255.,
    vec3(38, 195, 15)/255.
);

vec3 Pal[16] = Paltic;

vec3 pal(float t) {
  return Pal[int(t)%16];
}

float fft(float t) {
  return texture(texFFTSmoothed, fract(t)*.1+.001).x;
}
float ffti(float t) {
  return texture(texFFTIntegrated, fract(t)*.1+.001).x;
}

float rnd(float t) {
  return fract(sin(t*452.312)*714.541);
}

vec2 rnd(vec2 t) {
  return fract(sin(t*452.312+t.yx*814.724)*714.541);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void circ(inout float prev, vec2 uv, float x, float y, float s, float c) {
  if(length(uv-vec2(x,y))<=s) prev = c;
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

float map(vec3 p) {
  
  float t=time;
  for(int i=0; i<3; ++i) {
    p.xy *= rot(ffti(0.04)*.33+p.z*.1);
    p.xz *= rot(ffti(0.06)*.23+p.y*.1);
    p.xy=abs(p.xy)-.3-sin(t+i)*.5;
  }
  float d=box(p,vec3(.3));
     
  p=abs(p)-3-sin(time/5+p.x/10.)*2.7;
  d=min(d, length(p.xy)-.2);
  d=min(d, length(p.xz)-.1);
  d=min(d, length(p.zy)-.1);
  
  return abs(d)*.7;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv.y=1-uv.y;
  uv = floor(uv * vec2(240,136));
	uv -= vec2(120,68);

  vec2 fuv=uv/136.0;
  
  time = mod(fGlobalTime, 300);
  float tm=floor(time/2-length(fuv)*.1);
  float sec=rnd(tm);
  time += sec*300.0;
  
  float ss=mod(tm,3);
  if(ss<1) Pal = palAppleII;
  else if(ss<2) Pal = Palpico;

	vec2 m;
	m.x = atan(fuv.x / fuv.y) / 3.14;
	m.y = 1 / length(fuv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  vec4 cola = f + t;
  
  float value = texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy).a*16;
  if(rnd(uv+fract(time)).x<0.5) {
    value *= 0.9;
  }
  
  //value += clamp(cola.x,0,1)*16.;
  /*
  for(int i=0; i<10; ++i) {
    vec2 id=rnd(floor(time*20)*vec2(1,0.3)+i*100.0);
    circ(value, uv, id.x*240-120, id.y*136-68, 10, 7+i);
  }
  */
  if (mod(time,8)<2) {
    vec2 ruv=uv*rot(time*.1);
    value = (ruv.x+ruv.y)*16.0/240.0+ffti(.05)*.3;
  }
  
  
  for(int i=0; i<30; ++i) {
    textcolor = time*3+i;
    float t1=ffti(0.02)*.05+i;
    vec2 tuv=uv+vec2(sin(t1)*100,sin(t1*.7)*64);
    String6(value, tuv, 4592934);
    String6(value, tuv, 774);
  }
  
  vec3 s=vec3(0,0,-5);
  s.xy += (rnd(sec)-.5)*vec2(2,4);
  vec3 r=normalize(vec3(fuv, 1));
  vec3 p=s;
  for(int i=0; i<100; ++i) {
    float d=map(p);
    if(d<0.001) {
      value=7+map(p-r)*6;
      break;
    }
    if(d>100) break;
    p+=r*d;
  }
   
	out_color = vec4(pal(value), float(int(value)%16)/16.0);
}