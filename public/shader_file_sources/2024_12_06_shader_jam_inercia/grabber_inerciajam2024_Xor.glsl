#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float dist(vec3 p)
{
    float t = clamp(cos(fGlobalTime*6.2831*135./60./64.+p.x*.1)-.2,0.,.5);
 
    p.xy *= mat2(cos(t+vec4(0,11,33,0)));
    float d = max(p.y,min(1.-abs(p.x),p.y+2.));
  
    vec3 v = p;
  
    float m = min(v.x,min(v.y,v.z));
    float M = max(v.x,max(v.y,v.z));
    
    float s = 20.;
    float a = clamp(cos(fGlobalTime*6.2831*135./60./32.+p.y*.01)*5.,0.,1.);
  
    for(float i = 0.0; i<8.0+4.*cos(2.*fGlobalTime+.5*p.z); i++)
    {
        s *= .5;
        v = s*.6-abs(mod(v+cos(i)*.01*texture(texFFTIntegrated,.1).r,2.*s)-s);
        m = min(v.x,min(v.y,v.z));
        M = max(v.x,max(v.y,v.z));
        d = max(d,length(max(m,0.0))+min(M,0.0));
        v.xz *= mat2(cos(a+i+.05*texture(texFFTIntegrated,.1).r+vec4(0,11,33,0)));
    }
    return d;
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 suv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1) * (texture(texFFT,.2).r+1.);
  
  vec3 dir = normalize(vec3(uv,0.5));
  dir.zy *= mat2(cos(cos(fGlobalTime*.2)*.2-.5+vec4(0,33,11,0)));
  vec3 cam = vec3(0,-.1+cos(fGlobalTime*.1),.4*fGlobalTime);
  vec3 pos = cam;
  
  for(int i = 0; i<40; i++)
  {
      pos += dist(pos)*dir;
  }
  
  float f = length((pos-cam)*vec3(1,7,1));
  float a = 1.0;
  for(float r = .01; r<.5; r*=1.5)
  {
    a *= clamp(mix(dist(pos+r*normalize(cam-vec3(0,5,20)-pos))/r,1.,.8),0.,1.);
  }
  vec3 o = 5.*vec3(a)*clamp(cos(pos.y*10.+cos(pos.y*16.18)*6.)*5./(1.+dist(pos)*80.),1.,1.5)/f;
  o += texture(texInerciaLogo2024,suv*vec2(1,-1)+texture(texFFTSmoothed,suv.x*.2).r*pow(cos(fGlobalTime*135.*6.2831/60.),3.0)).rgb
  *clamp(sin(fGlobalTime*.1+cos(fGlobalTime*16.7)*.1)*40.-38.,0.,1.);
  o.gb = texture(texPreviousFrame,suv).rg/.9;
 
	out_color = vec4(o,1);
}