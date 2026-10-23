#version 410 core

#define PI 3.14159265
#define lofi(i,j) ( floor( (i)/(j) )*(j) )
#define saturate(i) clamp((i),0.,1.)

float time;
float seed;

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

mat2 r2d(float t){
  return mat2(cos(t),sin(t),-sin(t),cos(t));
}

float fs(float s){
  return fract(sin(114.514*s)*1919.810);
}

float random(){
  seed=fs(seed);
  return seed;
}

vec3 randomsphere(){
  float a=2.*PI*random();
  float b=acos(random()*2.-1.);
  return vec3(cos(a)*sin(b),cos(b),sin(a)*sin(b));
}

vec3 randomhemisphere(vec3 n){
  vec3 d=randomsphere();
  return dot(d,n)<0.?-d:d;
}

float func(float x, float y, float z) {
    z = fract(z), x /= pow(2.,z), x += z*y;
    float v = 0.;
    for(int i=0;i<6;i++) {
        v += asin(sin(x)) * (1.-cos((float(i)+z)*1.0472));
        v /= 2., x /= 2., x += y;
    }
    return v * pow(2.,z);
}

vec4 isectplane(vec3 p,vec3 rd,vec3 n){
  float d=dot(n,p)/dot(n,rd);
  d=d<0.?1E9:d;
  return vec4(d,1,0,0);
  // oboetenaiyo~~~~~
  // wakaruyo
}

void main(void)
{
  vec2 uv=gl_FragCoord.xy/v2Resolution;
	vec2 p = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y)*2.-1.;
	p /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time=fGlobalTime;
  seed=texture(texNoise,p).x+time;
  random();
  
  vec3 ro=vec3(0,2,5);
  vec3 ro0=ro;
  vec3 rd=normalize(vec3(p,-1.));
  rd.yz=r2d(.1*sin(time))*rd.yz;
  rd.zx=r2d(.1*sin(1.6+.5*time))*rd.zx;
  vec3 rd0=rd;
  
  float g=0.;
  float rem=1.;
  float samples=1.;

  vec3 col=vec3(0.);
  
  for(int i=0;i<64;i++){
    float rl=1E-2;
    vec3 rp=ro+rd*rl;
    vec4 isect=vec4(1E9);
    vec3 isectn=vec3(0.);
    vec4 isectb;
    
    {
      vec3 n=vec3(0,0,1);
      isectb=isectplane(vec3(0.,0.,-1.)-rp,rd,n);
      if(isectb.x<isect.x){
        isect=isectb;
        isectn=n;
      }
    }
    
    {
      vec3 n=vec3(0,1,0);
      isectb=isectplane(vec3(0.,-1.,0.)-rp,rd,n);
      if(isectb.x<isect.x){
        isect=isectb;
        isectn=n;
        isect.y=2.;
      }
    }
    
    if(isect.x<1E8){
      rp=ro+rd*isect.x;
      if(isect.y==1.){
        vec2 pt=lofi(rp.xy*.25,.0625)*vec2(1.,2.);
        float fuck=func(200.0+100.0*sin(time),pt.x,pt.y+time);
        fuck=clamp(.5*fuck,0.,1.);
        g+=rem*fuck;
        rem*=.1;
        ro=rp;
        rd=reflect(rd,isectn);
      }else if(isect.y==2.){
        vec2 pt=rp.xz*vec2(.4,2.);
        float fuck=func(200.0,pt.y,pt.x);
        float rough=.2+.07*clamp(fuck,-1.,1.);
        //g+=fuck;
        rem*=.3;
        ro=rp;
        rd=normalize(mix(reflect(rd,isectn),randomhemisphere(isectn),rough));
      }
    }else{
      rem*=0.;
    }
    
    if(rem<.01){
      rd=rd0;
      ro=ro0;
      rem=1.;
      samples++;
    }
  }
  
  for(int i=0;i<40;i++){
    float aaa=float(i)/40.;
    float z=1.-.04*aaa*pow(length(p),2.);
    vec2 uvt=z*(uv-.5)+.5;
    vec3 mul=saturate(2.-abs(aaa*6.-vec3(1,3,5)))/40.*3.;
    float tex=texture(texPreviousFrame,uvt).w;
    col+=vec3(tex)*mul;
  }
  
  col=pow(col,vec3(.4545));
  col=vec3(
    smoothstep(.1,.9,col.x),
    smoothstep(.0,.9,col.y),
    smoothstep(-.1,1.1,col.z)
  );
  
	out_color = vec4(col,g/samples);
}