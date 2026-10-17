#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texCatJam;
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 path(float z){
  
  float a = sin(z*.007-fGlobalTime*.5)*2000.;
  float b = cos(z*.009-fGlobalTime*.5)*3000.;
  
  return vec2(a*4.-b*2.,b+a*.5);
  }

float sdf( vec3 p){
  
  vec3 p3 = p;
  
  p.x = abs(p.x)-200.;
  p.xy -= path(p.z)/100.;
  p.xz -= path(p.y)/200.;
  
  vec3 p2 = p;
  
  p.z = mod(p.z-fGlobalTime*10.,20.)-10.;
  p.y = mod(p.y-fGlobalTime*10.,40.)-20.;
  p2.y = mod(p2.y-fGlobalTime*5.,40.)-20.;
  
  float sp = length(p)-13.;
  
  float sf = dot(p2,vec3(0,1,0.))+10.;
  float sf2 = dot(p2,vec3(0,-1,0.))+10.;
  float sf3 = dot(p2,vec3(1,0,0.))+10.;
  float sf4 = dot(p2,vec3(-1,0,0.))+10.;
  
  sf = min(min(min(sf,sf2),sf3),sf4);
  
  return max(sf,sp);
}

float raymarch(vec3 ro,vec3 rd){
  
  float dist = 0.;
  for(float i = 0.;i++<256.;){
    
    float d = sdf(ro+rd*dist);
    
    if(d<.001||dist>10000.)break;
    
    dist += d;
    
  }
  return dist;
}

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  uv = abs(uv);
  
  float tex = texture(texFFTSmoothed,0.).x;
  
  float modu = mod(fGlobalTime,6.);
  float it = 1.;
  
  if(modu> 2.)it=9.5;
  if(modu>4.)it=6.7;
  
  vec2 R2D = uv*R2D(it);
  vec3 col = vec3(0.);
  vec3 ro = vec3(0.,0.,0.);
  vec3 target = vec3(0.,0.,0.);
  target.xy += path(target.z); ro.xy += path(ro.z);
  ro = vec3(0.,400.,1.);
  target = vec3(0.,000.,0.);
  vec3 front = normalize(target-ro);
  vec3 right = normalize(cross(front,vec3(0.,1.,0.)));
  vec3 up = normalize(cross(right,front));
  vec3 rd = normalize(right*R2D.x+up*R2D.y+front*2.);
  
    float dist = raymarch(ro,rd);
    
    if(dist<10000.){
      
      vec2 e = vec2(.001,-.001);
      vec3 p = ro+rd*dist;
      #define q(s) s*sdf(p+s)
      vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
      
      float mod2 = mod(fGlobalTime,15.);
      float it2 = 4.;
      
      if(mod2 > 10.)it2 = 10;
      
      vec3 lightpos = vec3(sin(fGlobalTime*it2)*100.,50.,50.);
      p.z = mod(p.z,20.)-10.;
      p.x = mod(p.x,20.)-10.;
      p.y = mod(p.y,50.)-25.;
      
      vec3 lightvector = p - lightpos;
      vec3 lightcolor = vec3(1.);
      vec3 lightdir = normalize(lightvector);
      float lightpow = 400000.;
      float lightIntensity = (pow(.1,2.) / pow(length(lightvector), 2.))*lightpow;
      
      vec3 dif = max(-dot(lightdir,n),.04)*lightcolor*lightIntensity;
      
      col = mix(vec3(.7,.1,0.)*length(uv),vec3(.5,.2,0.)/length(uv)+.2,dif);
      }
	out_color =vec4(col,0.);
}