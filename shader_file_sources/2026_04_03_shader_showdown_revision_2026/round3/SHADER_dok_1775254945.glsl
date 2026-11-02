#version 420 core

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
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{ 
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
#define time fGlobalTime
const float bpm=150/60.;
vec4 s=time*bpm/vec4(1,4,8,16), t= fract(s);
const float pi = acos(-1);
#define r2(a)mat2(cos(a),sin(a),sin(-a),cos(a))

float sd_box(vec3 p, vec3 e) {
  p = abs(p)-e;
  return length(max(p,0))-min(0,max(p.x,max(p.y,p.z)));
}

float M;
float map(vec3 p){
  
  float d, m = 1e9;
  M =0;
  {
    vec3 q = p;
    
    q.y=abs(q.y)-2;
    d = sd_box(q, vec3(2,.1,2));
    if (d< m) {
      M=1;
      m=d;
    }
  }
  {
    vec3 q = p;

    q.xz = abs(q.xz)-1;
    q.xy *= r2(floor(s.x)+pow(fract(s.x),.5));

    q.xz = abs(q.xz)-1;
    q.zy *= r2(pi*(floor(s.x)+pow(fract(s.x),.5))*.5);
    q.xy = abs(q.xz)-1;
    q.zy *= r2(floor(s.x)+pow(fract(s.y),.25));
    q.xy = abs(q.xz)-1;
    
    d = abs(sd_box(q, vec3(0,1.,0))-.1)+0.00001;
    if (d< m) {
      M=2;
      m=d;
    }
  }
  
  return m;
}


vec3 nrm(vec3 p)
{
  vec2 e=vec2(-1,1);
  float h=5e-3;
  return normalize(
  e.yyx*map(p+e.yyx*h)+
  e.yxy*map(p+e.yxy*h)+
  e.xyy*map(p+e.xyy*h)+
  e.xxx*map(p+e.xxx*h));
}

float b(ivec2 p) {
  int m = 0x1320;
  p%=2;
  int r = (m >> 4*(p.x*2+p.y))&0xf;
  return r/4.0;
}

uint hashi(uint x){
  const int c = int(-1u*(1.-sqrt(5)/2))|1;
  x ^= x>>16; x*=c;
  x ^= x>>15; x*=c;
  x ^= x>>16;
  
  return x;
}

float hashf(vec3 p) {
  uint x = hashi(floatBitsToInt(p.z));
  x = hashi(floatBitsToInt(p.y)+x);
  x = hashi(floatBitsToInt(p.x)+x);
  return x/float(-1u);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 UV=uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 col = vec3(0);
  float fv = mix(.6,.75,fract(s.x));
  vec3 ro = vec3(0,0,4);
  
  ro.xz *= r2(pi*(floor(s.z)+pow(t.z,.5)));
  vec3 cz = normalize(-ro),
  cx=normalize(cross(cz,vec3(0,1,0))),
  cy=normalize(cross(cx,cz)),
  rd=mat3(cx,cy,cz)*normalize(vec3(uv,fv));
  float i,r,d,h;
  h=10;
  vec3 p, n;
  r=d=0;
  for (i =0;i<100;i++) {
    p = ro+r*rd;
    d= map(p);
//    d+=.1*pow(1.-t.y,.5)*(.1*hashf(vec3(floor(gl_FragCoord.yy/2),time)));
    d*=1+pow(1.-t.z,.5)*.9*(.5-hashf(vec3(floor(gl_FragCoord.xy/2),time)));

    r+=d*.9;;
    if (d<1e-3) {
          n = nrm(p);
        if (M==1&&h-->0) {
          rd = reflect(rd,n);
          ro=p+.1*n;
          r=0;
          continue;
        } 
        if (M==2) {
          i=100;
          break;
        }
        break;
      }
      if(r>1e3)break;
  }
  float gl = i/100;
 float bb = b(ivec2(gl_FragCoord.xy/2));
   gl = pow(gl,1.5);

  gl = mix(gl, gl *step(gl, bb), pow(t.x,.5));

  col = vec3(gl); 
    
//  gl = pow(gl,1.5);
  col.r = pow(col.r,mix(1.05,1.5,t.x)); 
  col.g = pow(col.g,mix(1.15,1.1,t.z)); 
  col.b = pow(col.b,mix(1.15,0.9,t.y)); 
  
  col = pow(col,vec3(1.1)); 
  {
   vec3 pre = texture(texPreviousFrame, UV).rgb;
  col = mix(pre,col,0.8*pow(1.-t.x,.5));    
  }
	out_color = vec4(col,1);
}








