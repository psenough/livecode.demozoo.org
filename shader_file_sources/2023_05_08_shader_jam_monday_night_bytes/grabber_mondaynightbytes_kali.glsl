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

#define iTime fGlobalTime
#define iResolution v2Resolution
float so=0.;

#define ringstart 0.
#define ringend 30.
#define ringcaos .05
#define ringthickness .2
#define rotationspeed .2
#define bubbleradius 4.
#define bubblepulse 1. 
#define bubblespeed 1.
#define rayslength 10. 
#define rayswidth .05
#define lightoffset .3
#define colorintensity 1.
#define reflectionintensity .7
#define stripes true
#define scanlines true
#define noiselevel .15

float det=.001;
float maxdist=100.;
float coredist;
float it=0.;
vec3 pos;

float hash(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

mat2 rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c,s,-s,c);
}

float aro(vec3 p, float inner, float outer, float thickness, float it) {
    p.xz*=rot((iTime+0.)*rotationspeed*(1.+it*.02));
    float inring=length(p)-inner;
    float outring=length(p)-outer;
    float d=max(outring,-inring);
    d=max(d,abs(p.z)-thickness);
    coredist=min(coredist,max(abs(p.z)-rayslength,length(p.xy)-rayswidth));
    return d;
}

float de(vec3 p) {
    coredist=1000.;
    vec3 p2=p;
    float d=1000.,m=d;
    float der=1.;
    for (float i=ringstart; i<ringend; i++) {
        p.xy*=rot(i*ringcaos);
        float ar=aro(p, i*.5, ringthickness+i*.5, i*ringthickness*.05,i);
        d=min(d,ar);
        if (d==ar) {
            it=i;
        }
    }
    float s=so*50.;
    coredist=min(coredist, length(p2)-bubbleradius-s*bubblepulse);
    coredist=max(.005,abs(coredist));
    d=min(d,coredist);
    return d;
}

vec3 normal(vec3 p) {
    vec2 e=vec2(0.,det);
    return normalize(vec3(de(p+e.yxx),de(p+e.xyx),de(p+e.xxy))-de(p));
}

vec3 march(vec3 from, vec3 dir, vec2 uv) {
    vec3 p=from, col=vec3(0.), pref=p;
    float d=0., td=0., g=0., ref=0.;
    for (int i=0; i<100; i++) {
        p+=dir*d;
        d=de(p);
        if (d<det&&ref<1.) {
            pref=p;
            ref+=1.;
            p-=dir*.1;
            vec3 n=normal(p);
            dir=reflect(dir,n);
            d=.1;
        }
        if (d<det||td>maxdist) break;
        td+=d;
        if (ref<1.) g+=.1/(.1+coredist);
    }
    dir.xy*=rot(iTime*rotationspeed*.5);
    if (scanlines) col+=exp(-5.*length(dir.xy+lightoffset))*vec3(2.,1.,.5)*2.*mod(gl_FragCoord.y,3.)+.1;
    else col+=exp(-5.*length(dir.xy+lightoffset))*vec3(2.,1.,.5)*2.;
    col+=g*.03*vec3(1.,0.5,0.3);
    if (ref>0.) {
        vec3 n=normal(pref);
        vec3 ringcol=vec3(1.,0.,0.);
        ringcol.rb*=rot(it);
        ringcol.gb*=rot(it*.5);
        ringcol=abs(ringcol);
        col=mix(col*reflectionintensity,ringcol*colorintensity,.1);
    }
    dir.xy*=rot(-iTime*rotationspeed*.5*2.);
    col.rb*=rot(-abs(dir.x)*.7);
    if (ref<1.&&stripes) col-=abs(.5-fract(atan(dir.x,dir.y)*10.))*.1;
    col+=(hash(uv*500.+iTime)-.5)*noiselevel;
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
     vec2 uv=fragCoord/iResolution.xy;
     vec2 p=(fragCoord-iResolution.xy*.5)/iResolution.y;
     vec3 from=vec3(0., 0., -11.);
     vec3 dir=normalize(vec3(p,.4));
     vec3 col=march(from, dir, uv);
     fragColor = vec4(col,1.0);
}

void main(void)
{
  for (float i=0.; i<10.; i++)
  {
    so+=texture(texFFT,i/10.).x*.2;
  }
  vec4 fragColor;
  mainImage(fragColor, gl_FragCoord.xy);
	out_color = fragColor;
}