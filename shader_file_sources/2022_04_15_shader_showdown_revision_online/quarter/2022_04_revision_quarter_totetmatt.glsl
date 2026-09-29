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
// I CERTIFY ITS NOT A BOT

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
float diam(vec2 p,float s){
   p = abs(p);
   return (p.x+p.y-s)*inversesqrt(3.);
     
  }
float smin(float a,float b,float r){
    float k = max(0.,r-abs(a-b));
  return min(a,b) -k*k*.25/r;
  
  }
float bpm = (fGlobalTime*60/130*4);
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  bpm = floor(bpm)+pow(fract(bpm),.5);

vec3 col = vec3(.1);
    vec3 p,d = normalize(vec3(uv,1.));
  
  for(float i=0,g=0,e;i++<128;){
    
      p = d*g;
      p.z -=5.;
       
     vec3 gp = p;
    gp.xy *=rot(gp.z*.1);
    gp.y =-abs(gp.y);
     gp.y +=1;
 
     
   
    
float dd,c=20./3.141592;
  
 gp.xz = vec2(log(dd=length(gp.xz)),atan(p.x,p.z))*c;
                                       // ^^--- MAIS OUI CT SUR ENFAITE !
  gp.y/=dd/=c;
     gp.y +=sin(gp.x)*.5;
       gp.xz = fract(gp.xz+fGlobalTime)-.5;
    
     for(float j=0.;j<(4.-texture(texFFT,.3).r*10);j++){
     
        gp.xzy = abs(gp.xzy)-vec3(.1,.01,.1);
         gp.xz *=rot(-.785);
     }
    float ha_grid = dd*.8*min(diam(gp.xy,.01),diam(gp.zy,.01));

    
    
    float f = ha_grid;
    
    float blob = length(p)-.5-texture(texFFT,.3).r*2.;
    float gy = dot(sin(p*4),cos(p.zxy*2))*.1;
    for(float j=0.;j<16;j++){
      
           vec3 off = vec3(cos(j),tan(bpm+j),sin(j*3.33))+gy;
            blob = smin(blob,length(p-off)-.125,.25);
           
      }
    
      f= smin(f,blob,.5);
      g+=e=max(.001,f);;
       col+= mix(vec3(1.,.2,sin(p.z+bpm)*.5+.5),vec3(.5,sin(p.z)*.5+.5,.9),fract(2.*i*i*e))*.25/exp(i*i*e);
    
    }
	out_color = vec4(col,1.);
}