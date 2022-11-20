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
float time = fGlobalTime;
float PI = 3.1415926535;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything



vec2 pmod(vec2 p,float n){
  float np = 2.0*PI/n;
  float r = atan(p.x,p.y)-0.5*np;
  r = mod(r,np)-0.5*np;
  return length(p.xy)*vec2(cos(r),sin(r));
  
  }

float func(float x, float y, float z) {
    z = fract(z), x /= pow(2.,z), x += z*y;
    float v = 0.;
    for(int i=0;i<6;i++) {
        v += asin(sin(x)) * (1.-cos((float(i)+z)*1.0472));
        v /= 2., x /= 2., x += y;
    }
    return v * pow(2.,z);
}


mat2 rot (float r){
  
  return mat2(cos(r),sin(r),-sin(r),cos(r));
  }

 vec3 outco(vec2 p){
  vec3 col = vec3(0);
   vec2 ssp = p;
  float iter = 6.;
  float sit = 1.+floor(mod(time*108/60.,iter));
  for(int i = 0;i<6;i++){
    if(sit>i){
       p *= rot(PI*float(i)/iter);
       p = pmod(p,3.);
    
      col += vec3(func(p.x,time*3.,-0.1*time));
      p = ssp;
     }
   
  }
  col /= sit;
  col *= (12.+sit)/12.;
  return col;
  }
  
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 p =uv- 0.5;
	p /= vec2(v2Resolution.y / v2Resolution.x, 1);
vec2 sp = p;
  vec3 col = vec3(0);
  
    p *= 100.;
  
  vec3 param = vec3(p.x,p.y,-10.+20.*fract(0.5*time));
 
  col.r = func(param.x,param.y,param.z);
  
  
  col.g = func(param.z,param.x,param.y);
  
  
 col.b = func(param.x,time,time*0.);
  col.r = col.b;
  col.g = col.b;
  //col = clamp(col,0.,1.);
  col = vec3(0);
  p = sp;
   p += 0.1*func(uv.x*100.,uv.y*100.,time)*pow(abs(sin(8.*time*108/60.)),16.);
  float  scale = 800.;
  p *= scale;
  vec2 ep = 0.5*scale*vec2(0.01,0.01)*(uv-0.5);
 col.r += outco(p).r;
 p += ep;
 col.g += outco(p).r;
 p -=2.*ep; 
 col.b += outco(p).r;
//  float c = func();
  
  //col = vec3(c);
  
  col *= 0.2+pow(abs(sin(4.*time*108/60.)),2.);
  col = 1.5*pow(col,vec3(1.4,1.4,1.2));
   out_color = vec4(col,0);
}