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


float PI=3.1415;
float g=9.81;
float tt;

vec3 PosBob1;
vec3 PosBob2;
vec3 colorTerrain;

//--- Simulation

// Compute second order derivatives using the differential equations derived with Euler-Lagrange
vec2 computeAccelerations(in float theta, in float psi, in float theta_dot, in float psi_dot)
{
    float delta = theta - psi;
    float M = 2.;
    float alpha = 1+sin(delta)*sin(delta);
    float theta_dot_square = theta_dot*theta_dot;
    float psi_dot_square = psi_dot*psi_dot;

    // This is instead the simplest case equations when mA=mB=LA=LB, keeping it here because
    // could come in handy
    float new_theta_ddot = (-sin(delta) * (theta_dot * theta_dot * cos(delta) + psi_dot * psi_dot)
        - g * (M * sin(theta) - sin(psi) * cos(delta))) / (alpha);
    float new_psi_ddot = (sin(delta) * (M * theta_dot * theta_dot + psi_dot * psi_dot * cos(delta))
        + g * (M * sin(theta) * cos(delta) - M * sin(psi))) / (alpha); 
    return vec2(new_theta_ddot,new_psi_ddot);
}

void RK4Step(inout float theta, inout float psi, inout float theta_dot, inout float psi_dot, float h)
{
    // First estimate
    vec2 acc1 = computeAccelerations(theta, psi, theta_dot, psi_dot);
    float k1_theta     = theta_dot;
    float k1_theta_dot = acc1.x;
    float k1_psi       = psi_dot;
    float k1_psi_dot   = acc1.y;

    // Second estimate
    vec2 acc2 = computeAccelerations(theta+0.5*h*k1_theta,
        psi+0.5*h*k1_psi,
        theta_dot+ 0.5*h*k1_theta_dot,
        psi_dot+0.5*h*k1_psi_dot);
    float k2_theta = theta_dot + 0.5*h*k1_theta_dot;
    float k2_theta_dot = acc2.x;
    float k2_psi = psi_dot + 0.5*h*k1_psi_dot;
    float k2_psi_dot = acc2.y;

    // Third estimate
    vec2 acc3 = computeAccelerations(
        theta+0.5*h*k2_theta,
        psi+0.5*h*k2_psi,
        theta_dot+0.5*h*k2_theta_dot,
        psi_dot+0.5*h*k2_psi_dot);
    float k3_theta = theta_dot + 0.5*h*k2_theta_dot;
    float k3_theta_dot = acc3.x;
    float k3_psi = psi_dot + 0.5*h*k2_psi_dot;
    float k3_psi_dot = acc3.y;

    // Fourth estimate
    vec2 acc4 = computeAccelerations(
        theta+h*k3_theta,
        psi+h*k3_psi,
        theta_dot+h*k3_theta_dot,
        psi_dot+h*k3_psi_dot);
    float k4_theta = theta_dot+h*k3_theta_dot;
    float k4_theta_dot = acc4.x;
    float k4_psi = psi_dot+h*k3_psi_dot;
    float k4_psi_dot = acc4.y;

    // Final update
    theta += (h/6.0)*(k1_theta+2.0*k2_theta+2.0*k3_theta+k4_theta);
    theta_dot += (h/6.0)*(k1_theta_dot+2.0*k2_theta_dot+2.0*k3_theta_dot+k4_theta_dot);
    psi += (h/6.0)*(k1_psi+2.0*k2_psi+ 2.0 * k3_psi+k4_psi);
    psi_dot += (h/6.0)*(k1_psi_dot+2.0*k2_psi_dot+2.0*k3_psi_dot+k4_psi_dot);
}


//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Save(ivec2 u, vec3 value)
{
  //add pixel to compute texture
  ivec3 q = ivec3((value+1000)*1000);
  imageAtomicExchange(computeTex[0], u, q.x);
  imageAtomicExchange(computeTex[1], u, q.y);
  imageAtomicExchange(computeTex[2], u, q.z);
}

vec3 Read(ivec2 u){       
  return 0.001*(vec3( 
    imageLoad(computeTexBack[0],u).x,
    imageLoad(computeTexBack[1],u).x,
    imageLoad(computeTexBack[2],u).x
  ))-1000;
}

//---

mat2 Rot2(float angle) { return mat2(cos(angle), sin(angle), -sin(angle), cos(angle)); }

float sdRoundedCylinder( vec3 p, float ra, float rb, float h )
{
  vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float sdPlane( vec3 p, vec3 n, float h )
{
  // n must be normalized
  return dot(p,n) + h;
}

float Map(vec3 P)
{

  float bass = texture(texFFT, 0.1).r;
  float middle = texture(texFFT, 0.3).r;
  float high = texture(texFFT, 0.05).r;
  
  vec3 PD=P;
  PD.yz*=Rot2(PI*0.5);
  
  // Fulcrum
  vec3 PO=P;
  PO.yz*=Rot2(PI*0.5);
  float t=sdRoundedCylinder(PO,max(0.03*high*50,0.03),0.01,0.05);
  
  // Fist bob
  //vec3 PBob1 = P-vec3(0,-2,0);
  vec3 PBob1 = P-PosBob1;
  PBob1.yz*=Rot2(PI*0.5);
  t=min(t,sdRoundedCylinder(PBob1,max(0.1*bass*50,0.05),0.01,0.05));
  
  // Second bob
  //vec3 PBob1 = P-vec3(0,-2,0);
  vec3 PBob2 = P-PosBob2;
  PBob2.yz*=Rot2(PI*0.5);
  t=min(t,sdRoundedCylinder(PBob2,max(0.1*middle*80,0.05),0.01,0.05));
  
  // First rod from fulcrum to bob1
  t=min(t,sdCapsule(P,vec3(0),PosBob1,0.01));
  
  // Second rod from bob1 to bob2
  t=min(t,sdCapsule(P,PosBob1,PosBob2,0.01));
  
  colorTerrain = vec3(bass,middle,high)*3;
  
 float t1=sdPlane(P+sin(P.x)*cos(P.z)+50.*sin(tt)*sin(P.z*0.01),vec3(0,1,0),8+mix(0,10,bass));
 
 
if(t1<t)
{
  t=t1;

  colorTerrain = vec3(texture(texFFTSmoothed, (fract(abs(P.x*0.001)))).r*bass,
  texture(texFFTSmoothed, (fract(abs(P.x*0.001)))).r,
  texture(texFFTSmoothed, (fract(abs(P.x*0.001)))).r);
 

 }
  
  // Floor
  return t;
}


float CastRay(vec3 O, vec3 dir)
{
  float t=0;
  for(int i=0; i<128; i++)
  {
    vec3 P=O+t*dir;
    float d = Map(P);
    t+=d;
    if(d<0.01)
      return t;
    
    if(t>200)
      break;
  }
  
  return -1;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float t = fGlobalTime;
  tt = mod(fGlobalTime,100000);
  
  float theta, psi, theta_dot, psi_dot;
	
  vec3 pos = Read(ivec2(0,0));
  vec3 vel = Read(ivec2(1,1));
  
  theta = pos.x;
  psi = pos.y;
  theta_dot = vel.x;
  psi_dot = vel.y;
  
  if(tt==0.)
  {
    theta = (PI-0.4);
    psi = PI*0.5;
    theta_dot=0.5;
    psi_dot=-0.5;
  }
  
  if(ivec2(floor(gl_FragCoord.xy))==ivec2(0,0))
  {
     RK4Step(theta, psi, theta_dot, psi_dot, fFrameTime);
     Save(ivec2(0,0),vec3(theta,psi,0));
     Save(ivec2(1,1),vec3(theta_dot,psi_dot,0));
  }
  
  float xA = sin(theta);
  float yA = -cos(theta);
  float xB = sin(theta) + sin(psi);
  float yB = -cos(theta) - cos(psi);
  
  PosBob1=vec3(2.*xA,2.*yA,0);
  PosBob2=vec3(2.*xB,2.*yB,0);
  
  float bass = texture(texFFTSmoothed, 0.1).r;
  float middle = texture(texFFT, 0.3).r;
  float high = texture(texFFT, 0.05).r;
  
  float tc=tt;
  vec3 Eye = vec3(10*cos(tc*0.5)*mix(1,3,bass)+4*sin(tc*0.5),5*cos(tc*0.4),sin(tc*0.5)*cos(tc*1.5)+4*sin(tc*0.5));
  vec3 Target = vec3(0,-2,4);
  
  vec3 ww = normalize(Target-Eye);
  vec3 uu = cross(ww,vec3(0,1,0));
  vec3 vv = cross(uu,ww);
  vec3 dir = normalize(uv.x*uu+uv.y*vv+0.5*ww);
  
  float d = CastRay(Eye,dir);
  vec3 color = vec3(0);
  if(d>0)
  {
    vec3 P=Eye+d*dir;
    vec2 e=vec2(0.001,0);
    vec3 N = normalize(vec3(Map(P+e.xyy)-Map(P-e.xyy),Map(P+e.yxy)-Map(P-e.yxy),Map(P+e.yyx)-Map(P-e.yyx)));
    vec3 V=normalize(Eye-P);
    
    vec3 LightDir1 = normalize(vec3(0.,0,-0.5));
    vec3 LightDir2=normalize(vec3(0.2,1,0.2));
    
    float dif1 = max(dot(LightDir1,N),0);
    float dif2=max(dot(N,LightDir2),0);
    
    vec3 H1=normalize(LightDir1+V);
    vec3 spec1= pow(dot(N,H1),2)*vec3(1,1,1);
    
    float F0=0.4;
    float fresnel = F0 + (1-F0)*pow(dot(V,H1),5);
    
    vec3 H2=normalize(LightDir2+V);
    //vec3 spec2= pow(dot(N,H2),16)*vec3(1,1,0);
    //float fresnel2 = F0 + (1-F0)*pow(dot(V,H2),5);
    //color += dif1;
    //color +=  0.1*(1-fresnel2)*dif2;
    
    
    vec3 spec2= pow(dot(N,H2),32)*vec3(0.1,0.2,1.2);
    float fresnel2 = F0 + (1-F0)*pow(dot(V,H2),5);
    color += (1-fresnel)*dif1;
    color += (1-fresnel2)*dif2;
        
    vec3 color = vec3(1);
  }
  
  else
  {
    color =vec3(smoothstep(-1.3,1.,uv.y));
  }
  
  
	out_color = vec4(color,0);
}