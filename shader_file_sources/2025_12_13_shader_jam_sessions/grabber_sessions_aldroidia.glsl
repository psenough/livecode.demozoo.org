#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 erot(vec3 p,vec3 ax,float a) {
  return mix(dot(p,ax)*ax, p,cos(a)) + cross(p,ax)*sin(a);
}

float trz;

vec3 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec3( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25 );
}

void fold(inout vec3 p) {
  p=abs(p);
  float k=dot(p,vec3(1,-1,0));
  if (k<0.0) {
    p -= 2*k*normalize(vec3(1,-1,0));
  }
}

float kfs(vec3 p) {
  vec3 q = p;
  
  float scale=1;
  float res = 1e7;
  float SC=2+texture(texFFT,.3).x*25;
  
  for (int i=0;i<2;++i) {
    fold(q);
    q=erot(q,normalize(vec3(.5,1+0.5*sin(texture(texFFTIntegrated,0.5).x),.3)),.3+cos(fGlobalTime)*.1);
    q *= SC;
    q -= vec3(.7,.45,.2)*(SC-1);
    scale *= SC;
  }
  q = abs(q)-1;
  float d = max(q.x,max(q.y,q.z));
  return d/scale;
}
int mat;

float map(vec3 p) {
  vec3 q = p + vec3(3,0,0);
  float tnl=1e7;
  mat = 0;
  for (float i=0;i<10;++i) {
    float tub = length(q.xy)-1-sin(i*10+p.z)*.1;
    if (tub<tnl) {
      tnl=tub;
      mat = int(i);
    }
    q=erot(p,vec3(0,0,1),.7*i) + vec3(4,0,0);
  }
  
  float k = kfs(erot(erot(p - vec3(0,0,trz),vec3(0,1,0),texture(texFFTIntegrated,.7).x*10),vec3(1,0,0),fGlobalTime));
  
  float res = tnl;
  
  if (k<res) {
    mat = 1;
    res = k;
  }
  
  vec3 fq = abs(p+vec3(0,1.2,0))-vec3(1.5,.15,0);
  float fl = max(fq.x,fq.y);
  
  if (fl<res) {
    mat = 1;
    res = fl;
  }
  
  return res;
}

float sk(vec2 uv) {
  uv *= 5;
  float s=0;
  for (int i =0;i<3;++i) {
  s +=texture(texNoise,uv).r;
    uv *= 1.3;
  }
  
  s*=s;
  s=smoothstep(0.94,0.95,s);
  return s;
  
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx)));
}

void main(void)
{
  float rt = -fGlobalTime + texture(texFFT,0.1).x*4;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  if (sin(texture(texFFTIntegrated,0.1).x)>0.9) {
    uv = floor(uv*50)/50;
  }
  if (sin(texture(texFFTIntegrated,0.3).x)>0.9 && length(uv.y)>.4) {
    uv.x += 0.7;
  }
	
  trz = texture(texFFTIntegrated,0.1).x*10;
  
  float mt=(fGlobalTime-sin(fGlobalTime)*2)*.5;
  vec3 ro=vec3(-cos(mt),-sin(mt)+1,trz-10);
  
  
  vec3 la = vec3(.3*cos(mt),.3*sin(mt),trz);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,-1,0));
  vec3 u = cross (f,r);
  
  vec3 rd = normalize(3*f+ r*uv.x+u*uv.y);
  
  float t=0,d;
  
  float tlf=0;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) {
      if (mat != 1) break;
      ro += rd * t;
      rd = reflect(rd,gn(ro));
      t = .1;
      tlf += .3;
    }
    t += d;
    if (t>200) break;
  }
  
  vec3 ld = normalize(vec3(3,2,-1));
  
  vec3 bgcol = sk(rd.xy*4)*vec3(0.9,0.9,1)*.5;
  vec3 col = bgcol;
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    col = plas(vec2(10,cos(rt-p.z)),20)*dot(ld,n);
    col += vec3(1,1,0)*pow(max(dot(reflect(-ld,n),-rd),0),30)*10;
  }
  
  col = mix(col,vec3(0.3,0.4,0.9),tlf*.4);
  
  col = mix(bgcol,col,exp(-t*t*t*0.0001));
  
  col = pow(col,vec3(0.45));
  
	out_color.rgb=col;
}