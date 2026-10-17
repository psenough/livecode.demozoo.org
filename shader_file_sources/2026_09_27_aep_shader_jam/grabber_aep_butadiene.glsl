#version 420 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

#define BPM 132.
#define eps 0.001
#define time fGlobalTime
#define PI acos(-1.)

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float r){
  return mat2(cos(r),sin(r),-sin(r),cos(r));
  }
  
  vec2 pmod(vec2 p, float n){
    float np = 2.*PI/n;
    float r = atan(p.x,p.y)-0.5*np;
    r = mod(r,np)-0.5*np;
    return length(p)*vec2(cos(r),sin(r));
    }
    
      vec3 pmod2(vec2 p, float n){
    float np = 2.*PI/n;
    float r = atan(p.x,p.y)-0.5*np;
    float r2 = mod(r,np)-0.5*np;
    return vec3(length(p)*vec2(cos(r2),sin(r2)),(r-r2)/PI);
    }
    
    float cube(vec3 p, vec3 s){
      vec3 q = abs(p);
      vec3 m = max(s-q,0.);
      return length(max(q-s,0.))-min(min(m.x,m.y),m.z);
      }

      vec3 path(vec3 p){
        float s = 1.;
        p.x = s*1.1*sin(p.z*0.4);
        p.y = s*1.6*sin(p.z*0.27);
        p.z = 0.;
        return p;
        }

        float ease(float t, float s){
          t *= BPM/60.;
          return floor(t)+min(1.,mod(t*s,s));
          }
          
      vec4 dist(vec3 p){
        p += path(p);
        vec3 sp = p;
        
        p.xy = pmod(p.xy,3.+mod(floor(time*BPM/60.),5.));
        
        p.x -= 2.1;
        vec3 col = vec3(0.45);
        float k = 1.;
        p.yz  = mod(p.yz,k)-0.5*k;
        
        float dist1 = 99999999.;
        float scale = 1.;
        for(int i = 0;i<3;i++){
        p.yz = abs(p.yz);
        p.xy *= rot(0.25*PI);
        p.yz *= rot(ease(time*0.5,7.));
        float disttemp = cube(p,vec3(0.7));
          if(disttemp<dist1&&i>0){col = vec3(0.4,0.1,0.4);}
          dist1 = min(dist1,disttemp);
          scale *= 1.1;
          p.xz *= rot(0.3*ease(time*0.5,7.));
        }
        col = (1.5+6.*pow(abs(sin(PI*0.5*time*BPM/60.+0.4*PI)),6.))*col* exp(-1.3*dist1);
        
        float dist = dist1;
        
        sp.z += time*14.;
        sp.xy *= rot(sp.z*0.3);
        float k2 = 1.;
        sp.z = mod(sp.z,k2)-0.5*k2;
        vec3 sp2 = pmod2(sp.xy,3.);
        sp.xy = sp2.xy;
        sp.x -= 0.4;
        float dist2 = cube(sp,vec3(eps,eps,0.3));
        if(dist2<dist1){
          if(sp2.z<-0.8){col = vec3(1.,0.1,0.1);}
          else if(sp2.z<0.1){col = vec3(0.1,1.,0.1);}
          else{col = vec3(0.1,0.1,1.);}
          col = 0.05*col/(dist2+eps);
          }
        
        dist = min(dist,dist2);
        
        return vec4(col,dist);
        
        }
        
        vec3 gn(vec3 p){
          vec2 e = vec2(eps*4.,0.);
          return normalize(vec3(dist(p+e.xyy).w-dist(p-e.xyy).w,
          dist(p+e.yxy).w-dist(p-e.yxy).w,
          dist(p+e.yyx).w-dist(p-e.yyx).w));
          }
          
          float rand(vec2 p){
            return fract(sin(dot(p,vec2(12.7878,76.5432)))*45678.9123);
            }
        
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 p = uv - 0.5;
	p /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float sxt = texture(texFFTIntegrated,0.1).r;
  
  vec3 tar = vec3(0.,0.,-10.*time);
  vec3 cpos = tar + vec3(0.,0.,1.);
  tar -= path(tar);
  cpos -= path(cpos);
  vec3 cdir = normalize(tar-cpos);
  
  vec3 side = normalize(cross(cdir,vec3(0.,1.,0.)));
  vec3 up = normalize(cross(side,cdir));
  vec3 rd  = normalize(p.x*side+p.y*up+1.2*cdir);
  
  float t =0.;
  vec4 rsd = vec4(0.);
  vec3 ac = vec3(0.);
  for(int i = 0;i<99;i++){
    rsd = dist(cpos+rd*t);
    t += rsd.w*0.8;
    ac += rsd.xyz;
    if(rsd.w<eps)break;
    }
     if(rsd.w<eps){
       cpos = cpos + rd*t;
       vec3 nor = gn(cpos);
       cpos += 0.5*nor;
       rd = reflect(rd,nor);
       t = eps;
       for(int i = 0;i<66;i++){
          rsd = dist(cpos+rd*t);
          t += rsd.w*0.8;
          ac += rsd.xyz;
          if(rsd.w<eps)break;        
         }

       }
       
    
    vec3 col = 0.02*ac;
       vec2 glf = gl_FragCoord.xy*0.96+v2Resolution*0.02;
       float uvys = 1.+10.*mod(floor(time*BPM/60.),5.);
       float uvyfl = floor(uvys*uv.y+time);
       float randy1 = rand(vec2(uvyfl,1.))-0.5;
       randy1 *= 0.5*0.3*gl_FragCoord.y;
       float randy2 = rand(vec2(uvyfl,2.))-0.5;
       randy2 *= 0.5*0.3*gl_FragCoord.y;
       float randy3 = rand(vec2(uvyfl,3.))-0.5;
       randy3 *= 0.5*0.3*gl_FragCoord.y;
       
       imageAtomicAdd(computeTex[0],ivec2(gl_FragCoord.xy),int(255.*col.x));
       imageAtomicAdd(computeTex[1],ivec2(gl_FragCoord.xy),int(255.*col.y));
       imageAtomicAdd(computeTex[2],ivec2(gl_FragCoord.xy),int(255.*col.z));
       vec3 col2;
       col2.x = imageLoad(computeTexBack[0],ivec2(glf+randy1)).x;
       col2.y = imageLoad(computeTexBack[1],ivec2(glf+randy2)).x;
       col2.z = imageLoad(computeTexBack[2],ivec2(glf+randy3)).x;
       
       col2 /= 255.;
       
       col2 = mix(col,col2,floor(2.*abs(fract(0.125*BPM/60.*time))));

	out_color = vec4(col2,1.);
}