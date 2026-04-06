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

void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    vec2 old_uv = uv;
    
    uv.x /= uv.y+0.5*sin(fGlobalTime);
    uv = rot(fGlobalTime*0.1)*uv;
    uv = rot(length(old_uv)*sin(fGlobalTime))*uv;

    
    float dir = int(uv.y*10+100)%2==0?5.0:-5.0;
    vec2 texcoord = fract(uv*10.0+vec2(dir*fGlobalTime,0l));
    vec3 col = texture(texRevisionBW, texcoord).xyz;
    
    
    
    float bpm = 142;
    float m = fract(fGlobalTime*bpm/60);
    float s = int(fGlobalTime*bpm/60)%2;
    if(sqrt(length(old_uv))<m) col = mix(col,vec3(0.8,0.2,0.8),m);
    
    col = mix(col, vec3(1,0,1), 0.1);
    float d2 = int(old_uv.y*3+100)%2==0?4.0:-4.0;
    vec2 tx2 = fract(old_uv*3.0+vec2(d2*fGlobalTime, 0.5*fGlobalTime));
    col = mix(col, texture(texRevisionBW,tx2).www, 0.2);
    


    //vec3 col = vec3(fract(fGlobalTime*134.0/60.0));
    //vec3 col = 0.1*texture(texFFTSmoothed, 0.2);
    //vec3 col = texture(texFFTSmoothed, uv.x).xxx;
    //vec3 col = vec3(fft);
    /*
    col = vec3(fft);
    
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

*/
    out_color = vec4(pow(col,vec3(1.0/2.2)),1.);
}
