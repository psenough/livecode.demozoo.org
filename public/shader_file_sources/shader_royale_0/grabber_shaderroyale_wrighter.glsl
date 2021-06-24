#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasingfdgdgds
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define xor(a,b,c) min(max(a,-(b)), max(-(a) + c, b))


vec4 intersectPlane(vec3 ro, vec3 rd, vec3 n){
    n = normalize(n);
    
    float dron = dot(ro, n); 
    if(dron > 0.){
    	ro -= n * dron*2.;
    	rd = -rd;
    }
    
    float nominator = dot(ro,n); 
        
    float denominator = dot(rd,n);
        
    if (denominator > 1e-9) { 
        return vec4( -nominator / denominator, n); 
    
    } else {
    	return vec4(99.);
    }
}

vec3 getRd(vec3 ro, vec3 lookAt, vec2 uv){
  vec3 dir = normalize(lookAt - ro);
  vec3 right = normalize(cross(vec3(0,1,0), dir));
  vec3 up = normalize(cross(dir, right));
  return normalize(dir + right*uv.x + up*uv.y);
}
#define rot(j) mat2(cos(j),-sin(j),sin(j),cos(j))

#define T fGlobalTime


float map(vec3 p){
  float d = 10e6;


  float m = sin(p.y*4. + T);
  
  d = length(p) - 0.1  + sin(p.y*15.)*0.1;
  
  d = xor(d,length(p.xz) +  0.01 + m *0.1,0.1);
  
  d = xor(d,max(length(p.x) +  0.01 + m *0.1, abs(p.y)),0.4);
  
  
  
  //d = xor(d, -length(p) - 0.1,0.6);
  
  
  d -= 0.1;
  d = abs(d) + 0.005 ;
  
  return d;
}


void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  

  vec3 col = vec3(0.3,0.1,0.1);
  
  col.xz += uv*0.2;
  col.xy += uv*0.1;
  
  vec3 ro = vec3(0.3,0.4,-0.3)*1.6;
    
    
  ro.xz *= rot(T*0.1 + cos(T + sin(T)*0.4)*0.2 - cos(T*0.4)*0.2);
    
  ro.xy *= rot(T*0.1 - cos(T - sin(T*0.5)*0.4)*0.3 - cos(T*0.2)*0.5);

  
    
  vec3 lookAt = vec3(0);

  vec3 rd = getRd(ro, lookAt, uv);
    
    
    
  float mi = -0.5;
  float ma = 0.5;
  float it = 40.;
  
  float d = 10e5;
  float df = dFdx(uv.x);
  
  vec2 luv = uv;
  
  for(float i = 0.; i < it ; i++){
   vec3 lro = ro + vec3(0,mi + i*(ma - mi)/it,0);
   float plane = intersectPlane(lro,rd,vec3(0,1,0)).x; 
   
   vec3 p = lro + rd*plane;   
  
   float m = map(vec3(p.x,i*(ma - mi)/it - 1.,p.z));
   
   m -= texture(texNoise,p.xz).x*0.03 + texture(texNoise,p.xz*4.).x*0.01 + texture(texTex2,p.xz*1.).x*0.003;
   
   
   if(m < d){
    luv = p.xz;
    df = length(vec2(dFdx(plane),dFdy(plane)));
    d = m;
   }
  
  }    
  
  
  col += smoothstep(df,0.,d)*(1 - texture(texNoise,luv*1.).y*4.);
  
  col = pow(col,vec3(0.454545));
  out_color = vec4(col,1);
}