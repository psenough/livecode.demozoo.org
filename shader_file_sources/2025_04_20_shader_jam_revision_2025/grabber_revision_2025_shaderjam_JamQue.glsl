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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 col = vec3(.23,.23,.39);
float t=fGlobalTime;
bool hit = false;
#define PI 3.141592f
#define ToRad PI / 180.0f

float strobe = 1.;//step(mod(t*10.,1),0.5);

mat2 rot (float a) {return mat2(cos(a),sin(a),-sin(a),cos(a));}
vec2 _uv;
float sdQ(vec2 p, vec2 s)
{
  vec2 d=abs(p)-s;
  return length(max(d,0.0))+min(max(d.x,d.y),0.);
}

float sdC(vec2 p, float r)
{
  return length(p) -r;
}
float fig(vec2 p)
{
  float r=0.;
  p-=0.5;
  p *=rot(t);
  r=max(r,-sdQ(p,vec2(0.3,0.3)));
  if (r>0) col = vec3(.5,.1,.1)-strobe;
  return  r;
}

float fig2(vec2 p)
{
  float r=0.;
  p *=rot(t);
  r=max(r,-sdQ(p,vec2(0.5)));
  if (r>0) col += vec3(.1,.5,.5);
  return  r;
}

float fig3(vec2 p)
{
  float r=0;
  r=max(r,-sdC(p,0.5*mod(t,0.3)));
  if (r>0) col +=vec3(.1,.5,.5)+mod(t,0.5);
  return r;
}

//---------------------------------------------------

float sphere( in vec3 p, in float r )
{
    return length(p)-r;
}

float boxpos (vec3 p, vec3 size, vec3 pos)
{
	vec3 q = abs(p-pos) - size;
	return length(max(q,0.0));
}
float swaptime = 2.;

float map(vec3 p)
{
  float r= 1.0;
  vec3 po=p;
  if (mod(t,swaptime)>swaptime/2.)
  {
    p.x+=cos(t);
    //p= mod(p,5.);
    p/=abs(sin(t))+0.2;
    p.xz*=rot(t*100.*ToRad);
    p.xy*=rot(t*100.*ToRad);
    r=min(r,boxpos(p,vec3(0.4),vec3(0.)))-0.2;
    p.x+=sin(t*50.*ToRad);
    r=min(r,sphere(p, 0.5));
    p.x=po.x;
    p.y+=cos(t*100.*ToRad+PI/4.);
    r=min(r,sphere(p, 0.5));
  }
  else
  {
    p.xy*=rot(-t);
    p.xyz=mod(p.xyz,5.0)-5.*0.3;
    //p.yz=mod(p.yz,5.0)-5.*0.3;
    //p.z-=mod(t*10.,2);
    
    r=min(r,sphere(p,0.8));
  }
  return r;
}

float sdTriangle( vec2 p, float r )
{
    const float k = sqrt(1.);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float TPMsize = 0.05;
float TPMoffset = 0.01;
float fila(vec2 p2D)
{
	float coll2D = 0.;
	coll2D = max(coll2D, -sdTriangle( p2D, TPMsize));
	p2D.x-=2.*TPMsize+TPMoffset;
	coll2D = max(coll2D, -sdTriangle( p2D, TPMsize));
	p2D.x-=2.*TPMsize+TPMoffset;
	coll2D = max (coll2D, -sdTriangle(p2D,TPMsize));
	return coll2D;
}

float modelTPM(vec2 p2D)
{
	float coll2D;
	coll2D = max(coll2D, fila(p2D));
	p2D.y += 4*TPMsize+4.*TPMoffset;
	coll2D = max(coll2D, fila(p2D));
	p2D.y -= 3*TPMsize+-3.*TPMoffset;
	coll2D = max (coll2D, -sdTriangle(p2D,TPMsize));
	p2D.x -= 4*TPMsize+2.*TPMoffset;
	coll2D = max (coll2D, -sdTriangle(p2D,TPMsize));
	// Sueltos
	p2D.x +=TPMsize+0.5*TPMoffset;
	p2D.y +=4*TPMsize-2.*TPMoffset;
	coll2D = max (coll2D, -sdTriangle(p2D,TPMsize));
	p2D.x +=3.5*TPMsize-0.5*TPMoffset;
	p2D.y -=2*TPMsize-3*TPMoffset;
	p2D *=rot(-PI/2.);
	coll2D = max (coll2D, -sdTriangle(p2D,TPMsize));
	return coll2D;
}

float TPM( vec2 p2D)
{
	vec2 p2DO = p2D;
	float coll2D = 0.;
	p2D.y-= 2.*TPMsize;
	p2D.x+= 1.*TPMsize;
	coll2D = max(coll2D, modelTPM(p2D));
	p2D *= rot(PI);
	p2D.y -= 7*TPMsize-TPMoffset;
	p2D.x += 4*TPMsize+2.*TPMoffset;
	coll2D = max(coll2D, modelTPM(p2D));
	return coll2D;
}
float TPMNegro(vec2 p2D)
{
	vec2 p2DO = p2D;
	float coll2D = 0.;
	p2D.y -= TPMsize-TPMoffset;
	p2D.x-= 2.*TPMsize+1.5*TPMoffset;
	coll2D = max(coll2D, -sdTriangle( p2D, TPMsize));
	p2D = p2DO;
	p2D *=rot(PI/2.);
	p2D.y -= TPMsize-.5*TPMoffset;
	p2D.x += TPMoffset;
	coll2D = max(coll2D, -sdTriangle( p2D, TPMsize));
	p2D *=rot(PI/2.);
	p2D.y -= 3.5*TPMsize-.5*TPMoffset;
	p2D.x += 1*TPMsize;
	coll2D = max(coll2D, -sdTriangle( p2D, TPMsize));
	p2D *=rot(-PI/2.);
	p2D.y += 3.5*TPMsize-.5*TPMoffset;
	p2D.x -= 1*TPMsize;
	coll2D = max(coll2D, -sdTriangle( p2D, TPMsize));
	return coll2D;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  _uv = uv;
  
  float coll = 0;
  vec2 uvM = abs(uv);
  if (mod(t,swaptime)<swaptime/2.)
  {
    coll = max(coll,fig(uvM));
    coll = max(coll,fig2(uvM));
    coll = max(coll,fig3(uvM));
  }
  else
  {
    uvM =uv; uvM*=abs(2*sin(t*2.));
    uvM *=rot(t);
            coll = max(coll,TPM(uvM));
        if (coll>0.0)
        {
           col = vec3(0.9);
        }
		coll = 0.;
        coll = max(coll,TPMNegro(uvM));
        if (coll>0.0)
        {
           col = vec3(0.2,0.2,0.2);
        }
      }


  // SDF 3D
  float shade = 0.;
  vec3 ro;
  ro = vec3(0.,0.,2.);
  vec3 rp= ro;
  vec3 pTarget = ro; pTarget.z -=3.0;
  
 	vec3 Cfrontal = normalize(pTarget-ro);
	vec3 Cleft = normalize (cross(Cfrontal,vec3(0.,1.,0.)));
	vec3 Cup =normalize(cross(Cleft,Cfrontal));
	vec3 rd = normalize(Cfrontal+Cleft*uv.x+Cup*uv.y);

	float r = 0.0;
    float dist = 0.0;
    float st = 128.;
	for (float i=0.; i<st;++i)
	{
		r = map(rp);
	  if (r < 0.001)
	  {
		hit =true;
		shade=i/st;
		 break;
	  }
      dist += r;
      if (dist > 18.) break;
	  rp += rd*r;
	}
  
  
  if (hit)
  {
   vec3 tex;
    if (mod(t,swaptime)>swaptime/2.)
    {
      tex = vec3(0.,0.,.6)+strobe;
    }
    else
    {
      tex = vec3(0.,0.6,.6)+strobe;
    }
    // gamma
	  col = tex*vec3(1.*sqrt(1.-shade*6.));
  }
  
  
	out_color = vec4(col,1.);
}