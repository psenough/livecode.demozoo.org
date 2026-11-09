#version 410 core
uniform float fGlobalTime;
uniform vec2 v2Resolution;
uniform sampler1D texFFT;
uniform sampler1D texFFTSmoothed;
layout(location=0) out vec4 out_color;

float plyg(vec2 p,float n){
    float a=atan(p.y,p.x),r=6.2831853/n;
    return cos(floor(.5+a/r)*r-a)*length(p);
}

void main(){
    vec2 uv=gl_FragCoord.xy/v2Resolution;
    float bass=texture(texFFTSmoothed,.03).r;
    uv=uv*1.8-1.0;
    uv.x*=v2Resolution.x/v2Resolution.y;

    
    vec2 osc=vec2(sin(fGlobalTime*1+bass*100.),cos(fGlobalTime*.5-bass*4.));
    float h=fract(sin(fGlobalTime*50)*20.);
    vec2 nse=vec2((h*2.-1.)*.02);
    uv-=osc*.1+nse;

    //float amnt=1.+floor(clamp(pow(bass,1)*3.,1.,10.));
    float amnt=5+floor(clamp(bass*25.,0.,100.));
    float edgs=3.+floor(5.5+.5*sin(fGlobalTime*10.));
    float mrph=.5+.5*sin(fGlobalTime*.8);
    float rad=.2+bass*3;
    float blur=0.01+bass*1+bass*bass*1;

    vec3 col=vec3(0.);
    for(int i=0;i<8;i++){
        float fi=float(i);
        float on=step(fi,amnt-1.);
        float a=fi*6.2/max(amnt,1.)+fGlobalTime*.3;
        float dst=(.5+.08*sin(fGlobalTime+fi*3.3))*step(1.5,amnt);
        vec2 p=uv-vec2(cos(a),sin(a))*dst;
        float d=mix(length(p),plyg(p,edgs),mrph);

        float cr=smoothstep(rad,rad-blur,mix(length(p+vec2( blur,0)),plyg(p+vec2( blur,0),edgs),mrph));
        float cg=smoothstep(rad,rad-blur,d);
        float cb=smoothstep(rad,rad-blur,mix(length(p+vec2(-blur,0)),plyg(p+vec2(-blur,0),edgs),mrph));

        col=max(col,vec3(cr,cg,cb)*on);
    }

    out_color=vec4(col,1.);
}