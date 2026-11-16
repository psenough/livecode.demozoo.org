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
#define pi acos(-1.)

#define iTime fGlobalTime
#define R v2Resolution
#define U fragCoord
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define T(u) texture(texPreviousFrame, (u)/R)
#define pmod(p,a) mod(p,a) - 0.5*a


mat3 getOrthBas( vec3 dir){
  vec3 r = normalize(cross(vec3(0,1,0), dir));
  vec3 u = normalize(cross( dir, r));
  return mat3(r,u,dir);
  }
  
float r21(vec2 id){
  return fract(sin(id.x*10.*cos(id.y*4.) + sin(id.x)*sin(id.y)*16.)*200.);
  }

float cyclicNoise(vec3 p){
  float n = 0.;
  p *= getOrthBas(normalize(vec3(-4,2.,-2 + sin(iTime)*0.1)));
  float lac = 1.5;
  float amp = 1.;
  float gain = 0.5;
  
  mat3 r = getOrthBas(normalize(vec3(-4,2.,-2)));
  

  for(int i = 0; i < 8; i++){
    p += cos(p + 2 + vec3(0,0,iTime))*0.5;
    n += dot(sin(p),cos(p.zxy + vec3(0,0,iTime)))*amp;
    
    p *= r*lac;
    amp *= gain;
    }
    return n;
  }
float sdBox(vec2 p, vec2 s){p = abs(p) - s; return max(p.x,p.y);}
  
  
float pxSz;
vec3 getLines( vec3 col,vec2 uv){
  for(float i = 0.; i < 120; i++){
    vec2 p = uv + vec2(0 + (iTime + sin(iTime + i))*0.2,sin(i*10.)*0.7);
    //float r = sin();
    float md = 0.5 + 0.5*sin(i*3.);
    md *= 0.4;
    float id = floor(p.x/md);
    p.x = pmod(p.x,md);
    p.x += sin(id + iTime)*md*0.45;
    float d = abs(p.x) - 0.02;
    d = max(d,abs(p.y) - 0.001);
    col = mix(col,1.-col,smoothstep(pxSz,0.,d));
    
  }

  return col;
}

vec3 getCrosses( vec3 col,vec2 uv){
  vec2 p = uv + vec2(0 +iTime*0.3,0.);
  float md = 0.1;
  vec2 id = floor(p/md);
  
  p = pmod(p,md);
  p = abs(p);
  p *= rot(0.5*pi);
  
  vec2 s = vec2(0.001,0.2+ 0.2*sin(id.x*4.*sin(id.y*16.) + sin(id.y*12. + iTime)*4. + iTime))*0.1;
  float d = sdBox(p,s);
  
  
  col = mix(col,1.-col,smoothstep(pxSz,0.,d));
  //col = 1. - col;
  
  return col;
}
vec3 getBlocks( vec3 col,vec2 uv){
  vec2 md = vec2(0.2,0.1);
  vec2 p = uv;
  p.x += iTime*0.1;
  vec2 id = floor(p/md);
  p = pmod(p,md);
  p.x += iTime;
  
  if(r21(id) < 0.04){
    col = vec3(0.1,0.2,0.1);;
  }
  
  //col = mix(col,1.-col,smoothstep(pxSz,0.,d));
  
  

  return col;
}
vec3 getCircls(vec3 col,vec2 uv){
  
  for(float i = 0.; i < 41; i++){
    float lt = iTime*(1. + sin(i))*0.1;
    vec2 p = uv + vec2(
      mod(lt,1)*3. - 1.5,sin(i*10.)*0.7);
    //float r = sin();
    float d = length(p) - 0.1;
    p = pmod(p,0.01);
    d = max(length(p) - 0.001,d);
    col = mix(col,1.-col,smoothstep(pxSz,0.,d));
    
  }
  return col;
}
vec3 getCirclsWithCircls(vec3 col,vec2 uv){
  
  for(float i = 0.; i < 41; i++){
    float lt = iTime*(1. + sin(i*25.))*0.1;
    vec2 p = uv + vec2(
      mod(lt,1)*3. - 1.5,sin(i*10.)*0.7);
    //float r = sin();
    float d = length(p) - 0.1;
    d = max(abs(pmod(d,0.01)) - 0.001,d);
    col = mix(col,0.-col*vec3(1.),smoothstep(pxSz,0.,d));
    
  }
  return col;
}
vec3 getSideLn(vec3 col,vec2 uv){
  
  for(float i = 0.; i < 111; i++){
    float lt = iTime*(1. + sin(i*24.))*0.1;
    vec2 p = uv + vec2(
      mod(lt,1)*3. - 1.5,sin(i*10.)*0.7);
    //float r = sin();
    float d = sdBox(p,vec2(0.05 + sin(i)*0.1));
    p *= rot(0.25*pi);
    p = pmod(p,0.01);
    d = max(abs(p.x) - 0.0025,d);
    col = mix(col,1.-col*vec3(0.,0.3 + sin(i)*0.5,0.7 + sin(i)*0.4),smoothstep(pxSz,0.,d));
    
  }
  return col;
}
vec3 getArrows(vec3 col,vec2 uv){
  
  for(float i = 0.; i < 101; i++){
    float lt = iTime*(1. + sin(i*12.))*0.1;
    vec2 p = uv + vec2(
      mod(lt,1)*3. - 1.5,sin(i*10.)*0.7);
    //float r = sin();
    vec2 s = vec2(0.05 + sin(i)*0.1)*0.4;
    s.y *= 0.4;
    float d = sdBox(p,s);
    p.y = abs(p.y);
    p *= rot(0.25*pi);
    p.x = pmod(p.x,0.01);
    d = max(abs(p.x) - 0.004,d);
    col = mix(col,1.-col*vec3(0.9,0.8 + sin(i)*0.5,0.7 + sin(i)*0.4),smoothstep(pxSz,0.,d));
    
  }
  return col;
}

vec3 getNew(vec3 col, vec2 uv){
  
  float minD = 10e4;
  float id = -1.;
  //vec2 currP = 
  for(float i = 0.; i < 100; i++){
    float lt = iTime*(1. + sin(i*24.))*0.1;
    
    vec2 p = uv + vec2(mod(lt,1)*3. - 1.5,sin(i*10.)*0.7);
    
    float dC = length(p) - 0.1;
    float dSq = sdBox(p,vec2(0.1));
    float dL = sdBox(p,vec2(100,0.03));
    
    if(dC < 0.){
      id += 1;
    }
    if(dSq < 0.){
      id += 1;
    }
    if(dL < 0.){
      id += 1;
    }
    //if(r21(id) < 0.33){
      
      //col = mix(col,,smoothstep(pxSz,0.,d));
    //}
  }
  id = mod(id,1);
  
  if(id == 0){  
    vec2 p = uv;
    p *= rot(0.36);
    //p.x += iTime;
    p.x = pmod(p.x,0.07);
    float d = abs(p.x) - 0.0;
    
    col = mix(col,vec3(0),smoothstep(pxSz,0.,d));
  }
  return col;
}
  
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  pxSz = fwidth(uv.y);
  
  vec2 U = gl_FragCoord.xy;
  vec3 col = vec3(0);
  
  col = getBlocks(col,uv);
  //col = getLines(col,uv);
  col = getCrosses(col,uv);
  
  col = getCircls(col,uv);
  col = getCirclsWithCircls(col,uv);
  col = getSideLn(col,uv);
  col = getArrows(col,uv);
  
  /*
  col = getNew(col,uv);
  if(mod(iTime,10.) < 5)
    col = 1. - col;
  */
  col = pow(max(col,0),vec3(0.4545));
  out_color = vec4(col,1);
}