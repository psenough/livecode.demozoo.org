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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float t = fGlobalTime;
  float m=texture(texFFTSmoothed, 0.02).x;

  float r = length(uv);
  float f=fract(r*5+t);
  vec2 fn = (fract(f*2)-.5)*normalize(uv);
  float fnl=dot(fn,vec2(-1,1))*.5+1;
  vec3 color = f<.5?vec3(.2,.3,.5):vec3(.2,.6,.5);
  color*=fnl;

  float a=atan(uv.x,uv.y);
  float edge=.5+.2*sin(a*4+t*1.313)+.1*sin(a*5+t*2.217);
  if (r>edge) {
    color*=1.3;
  }
  
  float sum=0;
  vec3 colsum = vec3(0);
  vec3 nsum=vec3(0);
  for(int i=0;i<10;i++) {
    vec2 pos = vec2(sin(t*(.23+i*.0345)+0.4),sin(t*(.277+i*.1745)))*.3;
    vec2 d=uv-pos;
    float v=exp(-dot(d,d)*(20-m*50));
    float e=max(0,sin(i/1.6+t*.5)-0.9)*13;
    vec3 col = vec3(.7,.2+i*.07,.3);
    float ea=i*2.4;
    vec2 ev=vec2(sin(ea),cos(ea));
    if (e>0 && fract(dot(uv,ev)*10+t*2)>0.5) {
      col.bg+=e*ev;
    }
    vec3 n=normalize(vec3(d,v*.2));
    sum+=v;
    colsum+=col*v;
    nsum+=n*v;
  }
  if (sum > 2) {
    color = (colsum/sum)*pow(sum-2,.2);
    vec3 n=normalize(nsum/sum);
    float l = dot(n,vec3(-1,1,1));
    color *= l;
    int nj=20;
    for (int j=0;j<nj;j++) {
      float y=(j*2+1)/float(nj);
      float rr=sqrt(1-y*y);
      float an=j*2.4;
      vec3 p=vec3(rr*sin(an),y,rr*cos(an));
      float pl=max(0,dot(n,p));
      //pl*=1-texture(texFFT,.3+j*0.03).x*10;
      color+=vec3(.4,.6,.7)*pow(pl,100);
    }
  } else if (sum > 1) {
    color*=sqrt(2-sum);
  }
  
	out_color = vec4(color,1);
}