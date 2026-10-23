#version 410 core

uniform float fGlobalTime; // in seconds
#define T fGlobalTime
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
    
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
  
  
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define pi acos(-1.)

vec3 getPath(vec3 p){
  return vec3(normalize(vec2(sin(T*0.5), cos(T*0.7))), 0.);
}

mat3 getOrtho(vec3 ro, vec3 lookAt){
  vec3 dir = normalize(lookAt - ro);
  vec3 right = normalize(cross(vec3(0,1,0), dir));
  vec3 up = normalize(cross(dir, right));
  return mat3(right, up, dir);
  }
vec3 getRd(vec3 ro, vec3 lookAt, vec2 uv){
  vec3 dir = normalize(lookAt - ro);
  vec3 right = normalize(cross(vec3(0,1,0), dir));
  vec3 up = normalize(cross(dir, right));
  return normalize( dir + right*uv.x + up*uv.y);
  }
  
#define pmod(p,a) mod(p - 0.5*a, a) - 0.5*a
  

vec2 getF(vec3 po){
  vec4 p = vec4(po,1);
  
  float sc = 1.29;
  
  p.z = pmod(p.z,4.);
  
  
  p.xy = pmod(p.xy,5.);
  
  for(int i = 0; i < 4; i++){
  
    p = abs(p);

    if(i == 3 || i ==4){
    
      p.x = pmod(p.x,10)/dot(p.xyz,p.xyz);
    }
    p.xyz -= vec3(0.18, 2.4,9.2);
     p.xy *= rot(sin(T)*0.4 + 0.5);
    
    
    if(p.x > p.y) p.xy = p.yx;
    if(p.y > p.z) p.yz = p.zy;
    if(p.x > p.z) p.xz = p.zx;
   
    p *= sc;
  
  }
  p /= sc;
  
  vec2 d = vec2(10e4);
  
  d.x = length(p.xy)/p.w - 0.01;
  
  return d;
}

vec2 map(vec3 p){
  vec2 d = vec2(10e4);

  vec3 v = p;
  
  d = getF(v);
  
  
  //d.x = length(v.xy) - 0.1;
  return d;
}

float nois(vec3 p){
  
  float n = 0.;
  float amp = 1.;
  float gain = 0.5;
  
  float lac = 1.5;
  mat3 r = getOrtho(vec3(0), vec3(1,-1.5,0.5));
  float warp = 0.2;
  float warpTrk = 0.5;
  
  for(int i = 0; i < 5; i++){
    
    p += sin(p*warp)*warpTrk*amp;
    n += abs(dot(sin(p), cos(p.zxy)))*amp;
    
    p *= r;
    p *= lac;
    amp *= gain;
  }
  
  
  return n;
}

float voln;
float mapCloud(vec3 cloudP){
  float d= 0.;
  
  d = voln = nois(cloudP*3. + vec3(T*1.,T*1.,-T)*1.02);
  
  
  d = pow(smoothstep(0.,1.,d),2.);
  return d*0.2;
}


float mapBall(vec3 p){
  p.z -= T;
  p -= getPath(p)*2.;
  float di = length(p.xy) - .4 - nois(p*6.)*0.1;
  float d = smoothstep(0.14,0., di) ;
  
  
  return d;
}
  
  
vec3 getNormal(vec3 p){
vec2 t = vec2(0.001,0);
return normalize( map(p).x - vec3(
  map(p - t.xyy).x,
  map(p - t.yxy).x,
  map(p - t.yyx).x
));
}
    
void main(void)
{ 
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0);
  
  ro.z += T;
  
  ro += getPath(ro);
  
  ro.xy += normalize(vec2(sin(T)+ cos(T*0.4),cos(T*1.) + sin(T*0.6)))*1.7;
  
  
  vec3 lookAt = vec3(0,0,ro.z + 3);
  
  lookAt += getPath(lookAt);
  
  mat3 vp = getOrtho(ro, lookAt);
  
  
  vec3 lDir = normalize(vec3(1));
  //vec3 rd = normalize(vec3(uv,1))*vp;
  vec3 rd = getRd(ro, lookAt, uv);
  
  vec3 p = ro;
  float t = 0.; bool hit = false;
  vec2 d = vec2(10e5);
  for(int i = 0; i < 150; i++){
    d = map(p);
    if(d.x < 0.001){
      hit = true;
      break;
    }
    
    
    p = ro + rd * (t += d.x*0.5);
  }
  
  vec3 cloudP = ro;
  float cloudSteps = 20.;
  float cloudStepSz = min(t,25.)/cloudSteps;
  vec3 cloudAccum = vec3(0);
  float cloudT = 0.;
  for (float i = 0.; i < cloudSteps; i++){
    float dens = mapCloud(cloudP);
    //float densO = mapCloud(cloudP + lDir*0.2);
  
    //float diff = clamp(dens - dens,0.,1);
    
    dens *= (1. - cloudT)*cloudStepSz;
  
    

    cloudT += dens;
    cloudAccum += dens*vec3(0.5,0.4,0.8)*(0.5 + 0.5*sin(vec3(3,2,1) + 3.*sin(voln*3. + cloudP.z))  )*1.64;
    cloudP += rd*cloudStepSz;
    if(cloudT > 1.){
      break;
    }
    
  }
  
  vec3 ballP = ro;
  float ballSt = 4.;
  float ballStSz = min(t,4.)/ballSt;
  vec3 ballAccum = vec3(0);
  float ballT = 0.;
  for (float i = 0.; i < ballSt; i++){
    float dens = mapBall(ballP);
    float densO = mapBall(ballP + lDir*0.44);
  
    float diff = clamp(dens - densO*0.4,0.,1.);
    //float abs = vec3();
  
    vec3 c = vec3(0.6,0.2,0.5);

    c = mix(c*c*0.4, c,diff);
    
    dens *= (1. - ballT)*ballStSz;
  
    ballT += dens;
    //ballAccum += dens*vec3(0.5,0.4,0.8)*(0.5 + 0.5*sin(vec3(3,2,1) + 3.*sin(voln*1. + ballP.z))  )*1.64;
    ballAccum += dens*c;
    
    ballP += rd*ballStSz;
    if(ballT > 1.){
      //break;
    }
    
  }
  
  
  vec3 hitCol = vec3(0);
  if(hit){
    vec3 n = getNormal(p);
  
    #define ao(a) smoothstep(0.,1., map(p + n*a).x/a)

    float AO = ao(0.5)*ao(.4)*ao(.12)*1.;
    
    hitCol += 0.5 + n;
    
    
    hitCol *= AO;
  }
  
  col += hitCol*1.;
  
  col = mix(col,cloudAccum,pow(smoothstep(0.,1.,cloudT ),1.));
  col = mix(col,ballAccum,pow(smoothstep(0.,1.,ballT ),1.));
  
  
  //col += ballAccum;
  
  col += 1.;
  col.xz *= rot(sin(T + t*0.5 + length(uv))*0.02);
  
  col.yz *= rot(sin(T+t*0.5)*0.04);
  col -= 1.;
  
  col = pow(col,vec3(0.454545));
  
  out_color = vec4(col,1);
}