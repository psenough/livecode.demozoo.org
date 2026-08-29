#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

float r11(float g){return fract(sin(g*3.223)*43.20);}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// WRIGHTER HERE 
// I HAVE NO CLUE WHAT IM GONNA MAKE LOL

#define rot(j) mat2(cos(j), sin(j), -sin(j),cos(j))
#define pi acos(-1.)

float sdLine(vec2 p, vec2 a, vec2 b){
  vec2 dir = normalize(b - a);
  float slope = atan(dir.y,dir.x);
  vec2 op = p;
  p -= a;
  p = p*rot(slope);
  float d = length(p.y);
  
  d = max(d, -p.x);
  
  d = max(d, p.x - (b-a).length*0.3 );
  return d;
  }
#define xor(a,b,c) min(max(a,-b), max(-a + c,b))

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float T = fGlobalTime;
  float tbetween = 6.;
  float seg = floor(T/tbetween);
  
  vec3 col = vec3(0);
  vec2 p = uv;
  float d = 10e5;
  float dir = floor(r11(seg)*8)*pi/4.;
  
  
  float id = seg;
  
  for (int chrab = 0; chrab < 8 ; chrab ++){
    
    p = uv;
    p += ( normalize(p)*.2*float(r11(id*241.512) < 0.5)+ chrab*0.04*sin(T))*1.7*length(p);
    p *= rot(dir);
    if (r11(id*1.2 + 0.5) < 0.5){
      d = 10e5;
    
    }
    //T = fGlobalTime;
    for ( int i = 0; i < 6 + r11(id)*10. ; i ++){
      
      T += (1.*r11(id) + 0.1);
      float r = r11(id + i + 1.45463*i*id);
      
      
      if (r < 0.05){
        p *= rot((0.2 + T*0.0001*r11(id + 0.4) + (T)*0.4*r11(id + i))*pi);
        //p = abs(p) - 0.5;
      }
      p -= (T - seg*tbetween)*0.01*(r11(id + i*0.04));
        
      for (int k = 0; k < (7*r11(id*42.231+i) + 4.); k++){
        vec2 luv = p;
        luv.y += r11(i*421.1*id);
        d = xor(d,sdLine(p,vec2(-0.4,0),vec2(0.4,0)) - .05*r11(id+i*0.042), 0.1*r11(id + i));
      }
      if(r11(id*i + 0.4) < 0.4){
        d = xor(d, abs(length(p) - r11(id + i)) - 3.6*r11(id*21.4 + i*float(r11(id)> 0.5)), .7*r11(id));
      }
      p.y -= r11(id*1.231)*0.1;
      p.x -= r11(id*1.231 + i)*0.5*sign(r11(id + i*4.)*2. - 1.);
    
      if (r11(id) > 0.7){
        d = xor(d,p.y,0.1);
      }
      
      if (r11(id + 0.24) < 0.1){
        d = xor(d,p.x,0.4);
      }
    
      
    }
    
    #define pal(a,b,c,d,e) ((a) + (b)*sin((c)*(d) + e))
    float coco = smoothstep(0.004,0.,d);
    
    if(r11(id*6.02351) > 0.5){
    
    //col += pal(0.5,0.5);
      col += coco*pal(0.5,0.5,vec3(4.7,1.4,1.4),1 + vec3(sin(T*0.24),cos(T*0.1),sin(T*0.5)),id + T*0.1 + chrab*0.1);
    
    } else {
      col[int(mod(chrab,3))] += coco;
    }
    
  }
  
  if(r11(id*1.02351) > 0.5){
    //col = 1- col;
  } 
  
  
  
  
  col = pow(col,vec3(0.4545));
  out_color = vec4(col,1);
}