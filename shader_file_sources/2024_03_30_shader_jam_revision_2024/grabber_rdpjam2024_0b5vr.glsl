#version 410 core

#define saturate(x) clamp(x,0.,1.)
#define linearstep(a,b,t) saturate( ( (t)-(a) ) / ( (b)-(a) ) )
#define lofi(i,j) (floor((i)/(j))*(j))
#define repeat(i,n) for(int i=0;i<n;i++)

const float LOG10 = log( 10.0 );

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

const vec3 PURPLE=vec3(1.,.2,0);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time;

float fetchFFT( float x ) {
  float xt = exp2( mix( -9.0, -1.0, x ) ); // 47Hz - 12,000Hz in log scale
  float v = texture( texFFTSmoothed, xt ).x;

  v = 20.0 * log( v ) / LOG10; // value to dB
  v += 24.0 * x; // +3dB/oct

  return v;
}

vec3 ponky(vec3 p,float pers){
  vec4 sum=vec4(1E-4);
  repeat(i,4){
    p=2.*p.yzx+sin(p)+sum.xyz/sum.w;
    sum=(sum+vec4(cross(sin(p.zxy),cos(p)),1))/pers;
  }
  return sum.xyz/sum.w;
}

vec2 cis(float t){
  return vec2(cos(t),sin(t));
}

vec4 smin(vec4 a,vec4 b,float k){
  vec4 h=max(k-abs(a-b),0.0)/k;
  return min(a,b)-h*h*h*k/6.;
}

vec3 smin(vec3 a,vec3 b,float k){
  return smin(vec4(a,0),vec4(b,0),k).xyz;
}

vec2 smin(vec2 a,vec2 b,float k){
  return smin(vec4(a,0,0),vec4(b,0,0),k).xy;
}

float smin(float a,float b,float k){
  return smin(vec4(a,0,0,0),vec4(b,0,0,0),k).x;
}

float sdbox(vec3 p,vec3 s){
  vec3 d=abs(p)-s;
  return min(max(max(d.x,d.y),d.z),0.)+length(max(d,0.));
}

vec4 map(vec3 p){
  vec3 pt=smin(p,-p,.5);
  pt+=.2*ponky(2.*pt+vec3(5.0*cis(time/20.0),0.02*fetchFFT(0.01)),.5);
  float d=abs(sdbox(pt,vec3(1.3,.3,.2)));
  d+=.1*ponky(3.*pt+vec3(8.0*cis(2.+time/20.0),0.04*fetchFFT(0.01)),.5).x;
  d-=.05;
  d=-smin(-d,length(p)-.5,.2);
  
  pt.y+=0.8;
  float d2=abs(sdbox(pt,vec3(5,.0,.2)));
  d2+=.1*ponky(3.*pt+vec3(8.0*cis(4.+time/20.0),0.04*fetchFFT(0.01)),.5).x;
  d2-=.1;
  d=smin(d,d2,.2);
  
  d=-smin(-d,length(p)-.5,.2);
  
  pt=smin(p,-p,.1);
  pt+=linearstep(-40.,-20.,fetchFFT(0.01))*.1*ponky(pt+vec3(5.0*cis(2.+time/10.0),0.04*fetchFFT(0.01)),.5);
  d=smin(d,length(pt)-.3,.1);
  
  pt=p;
  pt.xy=abs(pt.xy);
  d=min(
    d,
    sdbox(pt-vec3(0,1.9,1),vec3(100,1,1))
  );
  d=min(
    d,
    sdbox(pt-vec3(2.6,0,1),vec3(1,100,1))
  );
  
  return vec4(.5*d,0,0,0);
}

vec3 nmap(vec3 p){
  vec2 d=vec2(0,1E-4);
  return normalize(vec3(
    map(p+d.yxx).x-map(p-d.yxx).x,
    map(p+d.xyx).x-map(p-d.xyx).x,
    map(p+d.xxy).x-map(p-d.xxy).x
  ));
}

vec3 bg(vec2 p){
  float shape=max(
    smoothstep(.98,.99,cos(p.x*40.0)),
    smoothstep(.98,.99,cos(p.y*40.0+10.0*time))
  );
  return saturate(PURPLE*shape);
}

void main( void ) {
  time=fGlobalTime;
  
  vec2 uv = gl_FragCoord.xy / v2Resolution;
  vec2 p=uv*2.-1.;
  p.x*=v2Resolution.x/v2Resolution.y;
  
  if(abs(p.x)>1.62||abs(p.y)>.92){
    p=lofi(p,.01);
    p=smin(p,-p,.1);
    vec3 n=sin(9.0*ponky(vec3(4.0*p,time),.5));
    out_color=vec4(.2*PURPLE * step(.5,n.x),0);
    out_color.xyz=pow(out_color.xyz,vec3(.4545));
    return;
  }
  if(abs(p.x)>1.6||abs(p.y)>.9){
    out_color=vec4(PURPLE,0);
    out_color.xyz=pow(out_color.xyz,vec3(.4545));
    return;
  }

  vec3 col=bg(p);
  
  // shadow
  {
    vec3 ro=vec3(p,-1);
    vec3 rd=normalize(vec3(0,.2,1));
    float rl;
    float shadow=1.;
    repeat(i,50){
      float dist=map(ro+rd*rl).x;
      if(dist<1E-4){
        shadow=0.;
        break;
      }
      shadow=min(shadow,4.*dist/rl);
      rl+=dist;
    }
    col*=mix(1.,shadow,.99);
  }
  
  vec3 ro=vec3(0,0,2);
  vec3 rd=normalize(vec3(p,-2));
  float rl;
  vec3 rp;
  vec4 isect;
  
  repeat(i,100){
    isect=map(rp);
    rl+=isect.x;
    rp=ro+rd*rl;
  }
  
  if(isect.x<.01){
    vec3 l=normalize(vec3(1));
    vec3 n=nmap(rp);
    vec3 h=normalize(l-rd);
    col=vec3(.0)*(.5+.5*dot(n,l));
    
    vec3 refl=reflect(rd,n);
    col+=pow(.5+.5*ponky(refl+time,.5).x,5.);
    //col+=bg(.1*refl.xy);
  }
  
  col=pow(col,vec3(.4545));

	out_color = vec4( col, 1.0 );
}