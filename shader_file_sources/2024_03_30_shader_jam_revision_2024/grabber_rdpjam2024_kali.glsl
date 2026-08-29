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

#define iTime mod(fGlobalTime,1000.)
#define iResolution v2Resolution
float so=0.;


precision highp float;
#define col1 vec3(0,1,0)*so*20
#define col2 vec3(0,.10,0.)
#define col3 vec3(2.,0.5,0.)*so*20
#define col4 vec3(1,1.,1.)*.7
#define col5 vec3(w*2,w,w*.5)*.3
#define spex .1
#define spey -1.
#define fa .1211
#define amp 0.
#define focus 20.
#define ospe 2.
#define mx .5
#define bri 2.
#define zoom .7

#define rnd01 rnd(01.)
#define rnd02 rnd(02.)
#define rnd03 rnd(03.)
#define rnd04 rnd(04.)
#define rnd05 rnd(05.)
#define rnd06 rnd(06.)
#define rnd07 rnd(07.)
#define rnd08 rnd(08.)
#define rnd09 rnd(09.)
#define rnd10 rnd(10.)
#define rnd11 rnd(11.)
#define rnd12 rnd(12.)
#define rnd13 rnd(13.)
#define rnd14 rnd(14.)
#define rnd15 rnd(15.)
#define rnd16 rnd(16.)
#define rnd17 rnd(17.)
#define rnd18 rnd(18.)
#define rnd19 rnd(19.)
#define rnd20 rnd(20.)



float cuad;


#define PI 3.14159

// vec3 col1 = vec3(0.2,.5,.7);
// vec3 col2 = vec3(0.,0.,1.);
// vec3 col3 = vec3(0.,.0,.5);
// vec3 col4 = vec3(0.,.5,.5);

float w=0.;


float rnd(float p)
{
    p*=fa+w;
    p*=1234.;
    p = fract(p * .1031);
    p *= p + 33.33;
    return fract(2.*p*p);
}


float det=.005;
float maxdist=5.;
vec3 ldir=vec3(1.,1.,-1.);
vec3 fcol;


float hash12(vec2 p)
{
    p*=1232.231;
    vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


float segment(vec3 p, vec3 a, vec3 b) {
	float h = max(0.,min(1.,dot(p-a, b-a)/dot(b-a, b-a)));
    return length(p-a-h*(b-a));

}


mat2 rot(float a) {
	float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
}

//rnd04


vec2 polarUV(vec2 uv) {
    float angle = atan(uv.y, uv.x); // Obtener el ángulo polar
    float radius = length(uv)-.5;       // Obtener la distancia radial desde el centro

    // Normalizar el ángulo al rango [0, 1] (opcional)
    angle = (angle + 3.14159265359) / (2.0 * 3.14159265359);

    // Devolver las coordenadas UV transformadas
    return vec2(angle, radius);
}


vec3 render(vec2 p) {
    vec2 po=p;
    //p*=100.-sin(iTime*.2)*95.;
    float m=100.;
    float l=100.;
    float s=100.;
    float it=0.;
    p*=1.+rnd04*3.+so*amp;
    if (rnd13>.5) p/=clamp(dot(p,p),.2+rnd01*.3,1.+rnd02*2.);
    p+=vec2(floor(rnd02*4.)*.5,floor(rnd03*4.)*.5)*(.5+step(rnd14,.7)*.5);
    if (rnd14>.7) p=polarUV(p);
    p.x+=iTime*spex;
    p.y+=iTime*spey;
    p=mod(p,4);
    for (float i=0.; i<5.; i++) {
//        if (i>floor(rnd11*3.)+4.) break;
        p=abs(p)/clamp(abs(p.x*p.y),.5*rnd06,2.+rnd07*3.)-vec2(1.+rnd08*.5,1.+rnd09*.5);
        float a=abs(p.x+step(.5,fract(p.y+iTime+i*.25+so*ospe))*.5);
        if (i>rnd10*3.) m=min(m, a);
        if (m==a) it=i;
        //l=min(l,length(p)-.03);
        l=min(l,length(max(vec2(0),abs(p)-(.2+rnd05*.3)*step(fract(p.y*20.+iTime*.0),.4))));
        s=min(s,length(p));
    }
    float w=rnd12*.05;
//    m=smoothstep(.03+w,.02+w,m);
//    l=smoothstep(.03+w,.02+w,l);
    m=step(m,.07+w);
    l=step(l,.0);
    s=exp(-10.*s);
    vec3 col=mix(col1, col2, step(.5,abs(p.y)))*m;
    col=mix(col,col3, it*.2)*m;
    col=mix(col, col5, step(length(col),.01));
    col=mix(col,col4,l*.5);
    col=mix(col,.9-col5,s*.8*step(.6,rnd17));
    return col;
}

vec2 rand2(vec2 co){
	return
	vec2(fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453),
		fract(cos(dot(co.xy ,vec2(4.898,7.23))) * 23421.631));
}

vec2 uniformDisc(vec2 co) {
	vec2 r = rand2(co);
	return sqrt(r.y)*vec2(cos(r.x*6.28),sin(r.x*6.28));
}


void main()
{
  for (float i=0.; i<10.; i++)
  {
    so+=texture(texFFT,i/10.).x;
  }
  vec3 prev=texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution).rgb;
  vec2 uv = gl_FragCoord.xy/v2Resolution - .5;
  uv/=.7+uv.y*sin(iTime*.5)*2.;
  uv*=zoom;
  float b=smoothstep(.5,.3,max(abs(uv.x),abs(uv.y)));
  uv.x*=iResolution.x/iResolution.y;
  w=max(step(.5,uv.x+sin(iTime)),step(1.,uv.y+cos(iTime)));
  vec2 jit=uniformDisc(uv+iTime*.1);
  uv*=rot(PI/4.*floor(rnd12*4.));
  vec2 pix=1./iResolution;
  float y=smoothstep(.6,.3,abs(uv.y));
  uv+=jit*pix*(1.+focus*length(uv));
  vec3 col = render(uv);
  col=mix(col5,col*1.1,b);
  //col+=(hash12(uv+iTime*.1)-.5)*.5;
  if (rnd18>.9) col=vec3(pow(length(col)*.8,2.));
  col=mix(col*bri,prev,mx);
  //col=1-col*2;
  out_color = vec4(col,1.);
}
