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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define UV gl_FragCoord.xy  //Shortcut for gl_FragCoord
#define R v2Resolution.xy   //Shortcut for v2Resolution
float t;                    //Time global variable

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Add(ivec2 u, vec3 c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  imageAtomicAdd(computeTex[1], u,q.y);
  imageAtomicAdd(computeTex[2], u,q.z);
}
vec3 Read(ivec2 u){       //read pixel from compute texture
  return 0.001*vec3(      //unsquish int to float
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  );
}

//HASH NOISE FUNCTIONS: Make particles random
uint seed = 1; //hash noise seed
uint hashi( uint x){x^=x>>16;x*=0x7feb352dU;x^=x>>15;x*=0x846ca68bU;x^=x>>16; return x;}// hash integer
float hash_f(){return float(seed=hashi(seed))/float(0xffffffffU);}                      // hash float
vec3 hash_v3(){return vec3(hash_f(),hash_f(),hash_f());}                                // hash vec3
vec2 hash_v2(){return vec2(hash_f(),hash_f());}                                         // hash vec2

//DISC FUNCTION: Use this function to make a disc filled with random particles
vec2 hash_disc(){ vec2 r=hash_v2();return vec2(cos(r.x*6.28),sin(r.x*6.28))*sqrt(r.y);}

//POINT PROJECTION FUNCTION: Project points in 3d, use classic raymarching camera or some transform on p
ivec2 proj_point(vec3 p,vec3 cameraPostion,mat3 cameraDirection){
  // Classic camera example
  p-=cameraPostion;                                             //Shift p to cameraPosition
  p=p*cameraDirection;                                          //Multiply by camera direction matrix

  //No camera example: careful, order matters
  //p.xz*=rotate2D(t);
  //p.z+=50;

  if(p.z<0) return ivec2(-1); //REMOVE particles behind camera (see Add function call)
  float fov=0.5;              //FIELD OF VIEW amount
  p.xy/=p.z*fov;              //Perspective projection using field of view above

  //DOF code:
  float dofFocus=20;          //dofFocus is 20 as the camera is 20 unit away (orbit camera has 20 radius), change this to change the focus distance
  float dofScale=0.7;         //scale of dof, how fast it kicks in
  float dofAmount=0.005;      //amount of dof
  p.xy+=hash_disc()*abs((p.z-dofFocus)*dofScale)*dofAmount; //Add dof to scene

  ivec2 q=ivec2((p.xy+vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R); //Convert to int
  return q;
}

void main(void){
  t=fGlobalTime*.1;                               //Set global time variable
  seed=0;                                         //Init hash
  seed+=hashi(uint(UV.x))+hashi(uint(UV.y)*125);  //More hash
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); //Default uv calc from Bonzo
  //uv-=.5;                                                                         //We want uv range 0->1 not -.5->.5 so things start at zero
  uv/=vec2(v2Resolution.y / v2Resolution.x, 1);                                     //uv now hold uv coordinates in 0->1 range

  //PLEASE NOTE: we have two uv coordinates variables: uv and UV
  //uv is from 0 -> 1
  //UV is from 0 -> screen resolution, and is basically a shortcut to gl_FragCoord.xy
  //Depending on what we want to achieve, sometimes we'll use uv, sometimes UV. Generally because the uv range simplifies the calculation, stick around yeah?

  // Classic camera example: remove this if not using camera and just using transforms in proj_point function
  vec3 cameraTarget=vec3(0,0,0),                                //Camera target
  cameraPosition=vec3(cos(t)*20,2,sin(t)*20),                   //Camera position
  cameraForward=normalize(cameraTarget-cameraPosition),         //Camera forward
  cameraLeft=normalize(cross(cameraForward,vec3(0,1,0))),       //Camera left
  cameraTop=normalize(cross(cameraLeft,cameraForward));         //Camera top
  mat3 cameraDirection=mat3(cameraLeft,cameraTop,cameraForward);//Camera direction matrix
  float ptc = 0;
  if(UV.x<100){     //Amount / Density of particles. If you change this and want to keep system in middle then adapt 50 in line 93 below with half of this number
    vec3 p=vec3(0); //Set p as 0,0,0 with no hash to avoid noise and keep sharp line look
    float tubeLength=0.1;
    p.z=UV.x*tubeLength; //We extrude system along z using UV rather than uv so that the calculation to move in middle is more simple
    //Yes you CAN extrude using uv instead of UV, so with a uv range 0->1 and with a different tube length range...
    //...But then to move the system in the middle, it would be more complex calculation than this:
    p.z-=50*tubeLength; //Move tube in middle, 50 is simply half of the amount of particles. Yes if you change 100 on line 97 you should change 50 to half of it
    ptc=texture(texFFTSmoothed,fract(abs(p.z)/100)).x*(10+10*fract(p.z/100));
    float radius=1.+cos(p.z*.5)*.3+ptc;  //Tube radius with bulge deform using cosinus of p.z. You could use UV.x or uv.x as well, but p.z is based on UV.x and it's shifted at 0,0,0
    p.xy+=vec2(cos(uv.y*6.283)*radius,sin(uv.y*6.283)*radius);  //Push particles along a circle on XY to create tube. Here we using uv.y rather than UV.y as its range is 0->1 so it's simpler to make a full circle by mutiplying by 2*PI
    ivec2 q=proj_point(p,cameraPosition,cameraDirection);       //Project point in 3d using camera or not, see function itself
    //If point is NOT behind camera, draw point with gradient along p.z. Removing if(q.x>0) will make it trippy where things behind camera appear at front
    //CAREFUL when calling Add function. Here we are not doing it in a loop so it's ok. But if you were inside a loop, then you shouldnt do this like 100 times, if you do have loop of 100 make sure to exit early and / or not call Add every iterations
    if(q.x>0)Add(q,mix(vec3(1.,.1,.2),vec3(.0,.1,1.)+vec3(ptc,0,-ptc),cos(p.z*.5)*.5+.5));

  }
  vec3 s = vec3(0);
  vec2 uo = vec2(smoothstep(0.3,0.39+texture(texFFT,0.01).x,length(uv-vec2(0.5+sin(t*3),0.5))),0)*100;
  
  for (int i = -30; i <= -26; ++i) {
    for (int j=-3; j <= -1; ++j) {
      s += Read(ivec2(UV+uo)+ivec2(i,j))*.1; //Read back compute texture pixel, *.1 controls the brightness of the  whole thing as it's additive
    }
  }
  s *= 2.;
  if (length(s) > 1.) {
    Add(ivec2(UV),s.yzx/9);
  }

  //Recalculate uv for vignette: This is only done to simplify making a vignette background by using uv in range -.5,.5. It's the original uv calc you get in bonzomatic start tunnel
  uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); //Default uv calc from Bonzo, used for vignette
  uv-=.5;                                                                      //Default uv calc from Bonzo, used for vignette
  uv/=vec2(v2Resolution.y / v2Resolution.x, 1);                                //Default uv calc from Bonzo, used for vignette

  vec3 col = vec3(.2,.35,.5)-pow(length(uv+vec2(texture(texFFT,0.01).x,0)),4)*.75;                                    //Background colour and vignette
  col+=pow(mix(s,s.xxx,length(uv))/1000,vec3(.45));                                                       //Particle colour and gamma correction
  for (float i=0;i<3;++i) {
    col += smoothstep(0.21-i/12,0.2-i/12,length(uv+vec2(sin(t)*(3-i),-0.4+i*0.1)))*(0.2-i/11);
  }
  out_color = vec4(col,0);                                                     //Return final colour for pixel
}