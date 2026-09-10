#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCIX;
uniform sampler2D texChecker;
uniform sampler2D texEwerk;
uniform sampler2D texLcdz;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texRevisionBW;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
// OUAI OUAI OUAI
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float bpm = fGlobalTime*128/60;
float diam2(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3.);}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
float box2(vec2 p,vec2 b){p=abs(p)-b; return length(max(vec2(0.),p))+min(0.,max(p.x,p.y));}


mat3 ortho(vec3 p){
    vec3 z = normalize(p),x=vec3(z.z,0.,-z.x),y=cross(z,x);
  return mat3(x,y,z);
  }
 vec3 cy(vec3 p,float pump){
    vec4 s= vec4(0.);
    mat3 o = ortho(vec3(-1.,2.,-3.));
    for(float i=0;i++<5;){
      
        p*=o;
        p+=sin(p.yzx);
        s+=vec4(cross(cos(p),sin(p.zxy)),1.);
        s*=pump;
        p*=2.;
      }
      return s.xyz/s.a;
 }
 vec3 pcg3d(vec3 p){
    uvec3 q = floatBitsToUint(p)*1234567u+1234567890u;
    q.x +=q.y*q.z;q.x +=q.y*q.z;q.y +=q.x*q.z;q.z +=q.y*q.x;
    q^=q>>16;
   q.x +=q.y*q.z;q.x +=q.y*q.z;q.y +=q.x*q.z;q.z +=q.y*q.x;
    return vec3(q)/float(-1u);
  }
float arrow(vec2 uv,float r){
      uv=erot(uv.xyy,vec3(0.,0.,1.),.8+2.*3.14/4*r).xy;
    float l = box2(uv+vec2(.09,0),vec2(.02,.1));
    float b = box2(uv+vec2(.0,.09),vec2(.1,.02));
     vec2 uuv = uv;
    uuv=erot(uv.xyy,vec3(0.,0.,1.),.785).xy;
     float d =  box2(uuv,vec2(.02,.12));
     
   l = min(l,b);
  l = min(l,d);
  
  //l = smoothstep(fwidth(l),0.,l);
  return .01/(.01+l);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(0.);
  bpm = floor(bpm)+smoothstep(.1,.9,fract(bpm));
  vec3 ro=vec3(1.,1.,-5.),rt=vec3(0.,0.,1.);
  vec3 z = normalize(rt-ro),x=vec3(z.z,0.,-z.x),y=cross(z,x);
  vec3 rd = ortho(rt-ro)*normalize(vec3(uv,1.-fract(.5-bpm)));
  vec3 p;
 
  float i=0.,e=0,g=0;
  for(i=0,e=0,g=0;i++<99.;){
      p=ro+rd*g;
    
    vec3 op=p;
    vec3 rnd = cy(op,2.);
     float txt = sqrt(texture(texFFTSmoothed,p.x).r);
    for(float j=0;j++<5.;){
        p = abs(p)-.5+5*exp(-3-fract(bpm+rnd.y*.01));
        p = erot(p,normalize(vec3(.1,.2,.3)+rnd*.1*sin(bpm*.1)),-.785+exp(-4.*fract(bpm)));
    }
    float h= min(diam2(p.xz,.01),min(diam2(p.zy,.01),diam2(p.xy,.01)));
    h= max(length(op)-7-txt*5,h);
    g+=e=max(0.001,h);
    col+=(.75+.25*cos(vec3(1.,.7,.2)+bpm-p.z))*.025/exp(i*e*e+fract(.5-bpm));
      
  }
  float id = floor(uv.x*2);
  uv.x= (fract(uv.x*2.)-.5)/2.;
  uv.y +=-fGlobalTime*128/60*.5+bpm;
  float idy = floor(uv.y*4.);
  uv.y =(fract(uv.y*4.)-.5)/4.;
  float l = arrow(uv*exp(1.5+-1.5*fract(bpm+id*.25+idy*.1)),floor(id+idy));
  vec3 rrnd = pcg3d(vec3(id,id,idy));
  if(rrnd.x>.5){col *=1-l;
   
  ivec2 gl= ivec2(gl_FragCoord.xy);
  ivec2 off = ivec2(5.+sin(bpm+rrnd.x)*5);
   vec3 pcol = vec3(
    texelFetch(texPreviousFrame,gl-off,0).a,
    texelFetch(texPreviousFrame,gl+off,0).a,
    texelFetch(texPreviousFrame,gl+off,0).a
  );
  col +=pcol;
  }
	out_color = vec4(col,l);
}