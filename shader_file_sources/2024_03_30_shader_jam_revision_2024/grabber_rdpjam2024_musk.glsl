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
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define T fGlobalTime
#define O(X) sin(X*T*0.8)
#define M(X,Y) (mod(X,Y+Y)-Y)

mat2 rot(float a){ float c=cos(a), s=sin(a); return mat2(c,s,-s,c); }

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

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

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  
  
  vec3 col = vec3(0);
  float pwr=0.52;
  
  for (float i=0; i<1; i+=0.01)
  {
    float r=0.1+T*4+i*O(0.2)*0.1+O(4)-T;
    r=mix(sin(r*0.02)*16.0,cos(r*0.1)*4.0,smoothstep(-1,1,O(0.1)));
    mat2 rm=rot(r+i*O(4));
    vec2 p2 = uv.xy*(9.0+O(2)+O(4)*2+i*O(0.1)*0.1)*(1);
    p2*=rm;
    p2=M(p2,1);
    vec2 p3=M(p2,0.5);
    float sz = O(1.5)*0.05+0.2;
    float sz2 = O(2.5)*0.01+0.05;
    float fi=T+i;
    vec3 ch=abs(vec3(sin(vec3(fi,fi+3,fi+5))));
    col+=ch*0.0005;
    ch.xyz*=vec3(O(.19),O(0.12),O(1.4)*0.5+0.5);
    col = max(col,smoothstep(sz,sz-1e-2,max(abs(p2).x, abs(p2).y))*pwr*ch);
    p2*=4.5;
    col = max(col,smoothstep(sz2,sz2-1e-2,max(abs(p3).x, abs(p3).y))*pwr*ch);
    
  }
  for (int i=0; i<2; i+=1){
    col*=smoothstep(-0.4,0.4,sin(T*4+uv.y*(999.0+float(i)*10.0+sin(T*0.1)*100.0)))*0.29+0.96;
  }
  for (int i=0; i<2; i+=1){
    col*=smoothstep(-0.4,0.4,sin(T*4+uv.x*(999.0+float(i)*10.0+sin(T*0.1)*100.0)))*0.29+0.96;
  }
  col*=1-length(uv)*0.2;
  col=mix(col, vec3(length(col))*0.2, -1);
  col=1.9*col/(1+col);
  

  
	out_color = vec4(col,1);
}