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

vec4 tex(sampler2D tx,vec2 uv) {
    return texture(tx,clamp(uv*vec2(1,-1),-.5,.5)-.5);;
}
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

vec3 uv2sp(vec2 uv) {
    vec3 p = vec3(2.0*uv.x,2.0*uv.y,uv.x*uv.x+uv.y*uv.y-1.0)/(uv.x*uv.x+uv.y*uv.y+1.0);
    return p;
}

vec2 sp2uv(vec3 p) {
    vec2 uv = p.xy/(1.0-p.z);
    return uv;
}
vec2 cmul(vec2 a,vec2 b){return vec2(a.x*b.x-a.y*b.y,a.y*b.x+a.x*b.y);}
vec2 r2d(vec2 x,float a){a*=acos(-1.0)*2.0;return vec2(cos(a)*x.x+sin(a)*x.y,cos(a)*x.y-sin(a)*x.x);}

void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 asp=1.0/vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv0=uv;
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    vec3 col = vec3(1)-(sqrt(length(uv)));
        col += sqrt(mix(vec3(.95,.4,.2)*.1,vec3(.95,.4,.2)*.5,mod(floor(uv.x*105)+floor(uv.y*105),2)*texture(texRevisionBW,clamp(uv*vec2(1,-1),-.5,.5)-.5).rrr));

    vec4 tx = vec4(0);
    for(int i=0;i<6;i++){
        float sc= fract(i/6.+fGlobalTime*.1);
        vec2 guv = uv+vec2(sin(sc*6.28),cos(sc*6.28))*.35;
        guv.xy*=rot(sin(fGlobalTime+i/3.)*.5);

        guv*=4.+atan(cos(6.28*i/6-fGlobalTime)*5);
            if(i==0) tx=tex(texAmiga,guv),col= mix(col,tx.rgb,tx.a);; 
            if(i==1) tx=tex(texAtari,guv),col= mix(col,tx.rgb,tx.a);; ; 
            if(i==2) tx=tex(texC64,guv),col= mix(col,tx.rgb,tx.a);; ; 
            if(i==3) tx=tex(texEwerk,guv),col= mix(col,tx.rgb,tx.a);; ; 
            if(i==4) tx=tex(texST,guv),col= mix(col,tx.rgb,tx.a);; ; 
            if(i==5) tx=tex(texZX,guv),col= mix(col,tx.rgb,tx.a);; ; 
    }
    vec2 txs = textureSize(texEvilbotTunnel,0);
    tx = sqrt(texture(texEvilbotTunnel,clamp(uv*vec2(txs.y/txs.s,-1)*(5-5*exp(-fract(fGlobalTime*.25))),-.5,.5)-.5));
    col= mix(col,tx.rgb,tx.a);
    int iter=20;
    vec3 acc=vec3(0);
    /*
    for(int i=0;i<iter;i++){
      float lf=float(i)/float(iter);
    vec2 uvp=uv*exp2(-0.4*lf);
      float fx=exp2(((pow(abs(uvp.x),.5))-1.0)*9.0);
    float fc= texture( texFFT, fx).r*5*pow(fx,0.5);
    fc=pow(fc*4.0*exp2(-abs(uvp.y)*3),3.0);
    acc+=vec3(1,2,3)*fc*exp2(-lf*3+1.0);
      }
      */
      
    // 
    
    vec2 u=uv;
    vec3 sp=uv2sp(uv.yx*1.0);
      //sp.xz=r2d(sp.xz,fGlobalTime*0.102);
      //u=sp2uv(sp)*.123*exp(sin(fGlobalTime*0.213)*1.0)+vec2(-.15,0)+0.0*r2d(vec2(.26,0),fGlobalTime*0.0143);
      u=(sp2uv(sp))*2.5*exp((sin(fGlobalTime*0.13)+1.0)*2.7);
      sp=uv2sp(u);
      sp.xz=r2d(sp.xz,.25);
      sp.xy=r2d(sp.xy,fGlobalTime*0.01);
      u=sp2uv(sp)*0.5-vec2(1.,0.0);
      
      //u=(sp2uv(sp)-vec2(3.5,0.0))*0.25;
     vec2 z=u;
      acc*=0.02;
      for(int i=0;i<iter;i++){
        float lf=float(i)/float(iter);
        float xf=fract(atan(z.y,z.x)/acos(-1.0)/2.0+0.250);
        float fx=exp2(((pow(abs(xf*2.0-1.0),.5))-1.0)*9.0);
        vec3 smp=pow(texture( texFFT, fx).r*15*pow(fx,0.85),3.0)*(0.5+0.5*sin(sqrt(vec3(3,5,7))+lf*3.0+.2*fGlobalTime));
        float fx2=fract(float(i)*0.052+0.6);
        fx2=lf;
        fx2=exp2((fx2-1.0)*9);
        vec3 smp2=vec3(1)*texture( texFFTSmoothed, fx2).x*pow(fx2,0.85)*3.0+0.0;
        smp2+=vec3(1)*texture( texFFT, fx2).x*pow(fx2,0.85)*.0+0.0;
        smp2*=(0.5+0.5*sin(vec3(3,5,7)*float(i)*0.015));
        if(length(z)<30.0)acc+=vec3(1)*smp*33.3003;
        //z+=r2d(vec2(.18,0),(fGlobalTime+float(i)*0.2)*0.013);
        if(abs(length(z-r2d(vec2(1.3,0.2),.2+float(i)*0.12+fGlobalTime*.130))-1.0)<0.01342+pow(length(smp2)*22.302,3.0)){acc.xyz=smp2*12;break;}
        z=cmul(z,z)+u;
      }
      acc*=17.0;
      col.rgb=vec3(1)*acc/(1.0+acc);
      //col.rgb+=0.2*fract(length(z)+fGlobalTime*0.2);
    col.rgb=mix(col.rgb*1,texture(texPreviousFrame,(uv0-0.5)*exp2(-.02)+0.5+sin(((uv0-0.5)*asp).yx*3314*exp2(sin(fGlobalTime*0.3))+fGlobalTime*3.0)*.00117/asp).rgb,0.03181);
    out_color = vec4(col,1.);
}