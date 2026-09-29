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

vec2 rot(vec2 a, float angle){
  angle = angle * 3.14159/180.;
  return vec2(a.x*cos(angle)-a.y*sin(angle),
  a.x*sin(angle)+a.y*cos(angle));
  }

float noise(vec3 p){
  return fract(sin(p.x*201.+p.y*142.+p.z*123.)*100.+cos(p.x*234. + p.y*12.3+p.z*542.)*243.);
  }
  
  float noised(vec3 p){
    vec3 f = floor(p);
    vec3 i = fract(p);
    
    float n1 = noise(f);
    float n2 = noise(f+vec3(1.,0.,0.));
    float n3 = noise(f+vec3(0.,1.,0.));
    float n4 = noise(f+vec3(1.,1.,0.));
    
    float n5 = noise(f+vec3(0.,0.,1.));
    float n6 = noise(f+vec3(1.,0.,1.));
    float n7 = noise(f+vec3(0.,1.,1.));
    float n8 = noise(f+vec3(1.,1.,1.));

    i = smoothstep(0.,1.,i);
    float a = mix(mix(n1,n2,i.x), mix(n3,n4,i.x),i.y);
    float b = mix(mix(n5,n6,i.x), mix(n7,n8,i.x),i.y);
    return mix(a,b,i.z);
    }
    
    float fbm(vec3 p){
      return noised(p)*0.5+noised(p*2.)*0.25+noised(p*4.)*0.125;
      }
      vec3 pal(float t, vec3 a, vec3 b){
        return 0.5 + 0.5*cos(2.*3.14159*t*a+b);
        }
      
      float escape = 0.;
      float fbm2(vec3 p0){
        p0 = mod(p0, 3.)-1.5;
        escape = 0.;
        vec4 p = vec4(p0, 1.);
        p *= 2./min(dot(p.xyz,p.xyz),50.);
        for(int i = 0; i < 14; i++){
          p.xyz = vec3(1.,4.,2.)-(abs(p.xyz)-vec3(1.,4.,1.));
          p.xyz = mod(p.xyz-3., 6.)-3.;
          p *= 9./min(dot(p.xyz,p.xyz),19.);
          escape += exp(-0.2*dot(p.xyz,p.xyz));
          }
          p.xyz -= clamp(p.xyz, -1.5, 1.5);
        float dist = length(p.xyz)/p.w;
          return (dist < 0.001)?0.8:0.05;
        }
        

      vec3 clouds(vec3 p, vec3 d){
        vec3 lig = normalize(vec3(0.2,0.6,0.1));
        vec3 energy = vec3(0.);
        vec3 powder = vec3(0.);
        float tr = 1.;
        float ss = 0.05;
        float minus = 0.5;
        float mult = 1.0;
        
        bool hit = false;
        
        //for(int i = 0; i < 50; i++){
        //  float dist = length(mod(p, 3.)-1.5)-1.4;
        //  if(dist < 0.01){hit=true;break;}
        //  p+=d*dist;
        //  }
        //  if(!hit)return vec3(0.);
        
        for(int i = 0; i < 40; i++){
          float dens = max(fbm(p*mult)-minus,0.);
          if(dens > 0.01){
            vec3 l = p;
            float densl = 0.;
            for(int k = 0; k < 15; k++){
              densl += max(fbm(l*mult)-minus,0.);
              l+=lig*0.01;
              }
              tr *= 1.0-dens;
              
              energy += exp(-densl*vec3(0.5,1.,2.)*3.)*dens*tr*pal(escape, vec3(0.9),vec3(0.9,0.6,0.2));
              powder += (1.0-exp(-densl*vec3(0.5,1.,2.)*6.))*dens*tr;
            }  
          p+=d*ss;
          }
        
        return energy*powder*4.;
        }
      
      
void main(void)
{
  //if(gl_FragCoord.x > v2Resolution.x*0.5)discard;
 // if(gl_FragCoord.y > v2Resolution.y*0.5)discard;
  //if(int(gl_FragCoord.x)%4 != 0)discard;
  
  int a = int(gl_FragCoord.x)/62;
  int b = int(gl_FragCoord.y)/62;
 //if((a+b)%2 == 0)discard;
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
 // uv *= 0.5;
	uv -= 0.5;
	
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  vec3 col = vec3(0.);
  
  vec3 d = normalize(vec3(uv.x, 1., uv.y));
  d.yz = rot(d.yz, 45.);
  d.xy = rot(d.xy, 45.);
  
  vec3 p = vec3(0.,fGlobalTime,0.);
 
       col = clouds(p,d);
       col = pow(col, vec3(1./2.2)); 
      
	out_color = vec4(col,1.);
}