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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
float time= fGlobalTime;
float li(vec2 uv, vec2 a , vec2 b){ vec2 ua = uv-a; vec2 ba = b-a;
  float h = clamp(dot(ua,ba)/dot(ba,ba),0.,1.);
  return length(ua-ba*h);}
  float rd(float t){ return fract(sin(dot(floor(t),45.))*7845.236);}
  float no(float t){return mix(rd(t),rd(t+1.), smoothstep(0.,1.,fract(t)));}
  vec2 it(vec2 t){vec2 r = vec2(0.); float a = 0.5; for(int i = 0 ; i < 3 ; i++){
    r += vec2(no(t.x/a),no(t.y/a))*a;a*=0.5;} return pow(r,vec2(2.));}
    float it(float t){float r =0.; float a = 0.5; for(int i = 0 ; i < 3 ; i++){
    r += no(t/a)*a;a*=0.5;} return r;}
   
   vec4 mv(int i){vec2 t = vec2(time,time-fFrameTime);
      vec2 v1 = smoothstep(0.1,0.2,it(t*0.3));
     vec2 vr = mix((it(t+i*49.)-0.5)*0.1,vec2(0.),v1);
     return (vec4( cos(i*mix(vec2(1.),it(t*0.1),v1)+t),sin(i*mix(vec2(1.),it(t*0.2),v1)+t)))*0.7*
     vec4(mix(vec2( v2Resolution.y/ v2Resolution.x),vec2(1.),v1),1.,1.)+vec4(vr,vr);}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
  uv = (uv-0.5)*2.;float r1 = 0.;
  for(int  i = 1 ; i < 40 ; i++) {
    vec4 p = mv(i);
    r1 = max(r1,smoothstep(0.01,0.,li(uv,p.xz,p.yw)));
  }
  float r2 = max(r1,texture(texPreviousFrame,uc).a*0.95);
  vec2 uv2 = uv*vec2( v2Resolution.x/ v2Resolution.y,1.);
  float t = (1.-texture(texRevision,uv2+vec2(0.5)).x)*step(length(uv2),0.5)*smoothstep(0.3,0.2,it(time*0.3));
  r2 = max(t,r2);
  float c = 0.;
  vec2 ud = uc; vec2 ud2 = uv*0.005;
  for(int  i = 1 ; i< 30 ; i++){
    ud -= ud2;
    c += texture(texPreviousFrame,ud).a/i;
  }
  float f3 = max(c*(0.2+0.07*it(time*4.)),r2);
  float m = 0.;
  float b = sqrt(32.);
  float d = length(uv.y)*0.01;
  for(float i = -0.5*b; i <= 0.5*b; i +=1.)
  for(float j = -0.5*b; j <= 0.5*b; j +=1.){
    m += texture(texPreviousFrame,uc+vec2(i,j)*d).a;
  }
  m /= 32.;
  vec3 c1 = mix(vec3(1.),3.*abs(1.-2.*fract(m*.65+0.65+pow(it(time),5.)*10.+vec3(0.,-1./3.,1./3.)))-1.,0.5)*m;
  vec3 c2 = mix(c1,1.-c1,smoothstep(0.2,0.1,it(time*3.+26.)));
	out_color = vec4(vec3(c2),f3);
}