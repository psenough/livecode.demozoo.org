#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 tex(sampler2D tx,vec2 uv) {
    return texture(tx,clamp(uv*vec2(1,-1),-.5,.5)-.5);;
}

vec3 col = vec3(.23,.43,.19);
float t=fGlobalTime;
bool hit = false;
#define PI 3.141592f
#define ToRad PI / 180.0f

//float strobe = step(mod(t*8.,1),0.3);
//float strobe = step(mod(t*texture(texFFT,0.0).r,1),0.5);

float strobe = 1.;//step(mod(t*10.,1),0.5);


float swaptime = 4.;

mat2 rot (float a) {return mat2(cos(a),sin(a),-sin(a),cos(a));}

int id;

//------------------------------------

float circ2D(vec2 p2D, float rad)
{
	return length (p2D)-rad;
}

// 2D
float map2D(vec2 p2D)
{
	float r = 0.;
  p2D.x += 0.25 *sin(t);
  p2D.y += 0.25 *cos(t*2);
	r = circ2D(p2D,0.3+fract(t*20.)*0.02);
	if (r>0.) {id = 1; return r;}
	r= max(r,-circ2D(p2D,0.3));
	if (r>0.) id = 2;
	return r;
}

//------------------------------------


float sphere( in vec3 p, in float r )
{
    return length(p)-r;
}

float boxpos (vec3 p, vec3 size, vec3 pos)
{
	vec3 q = abs(p-pos) - size;
	return length(max(q,0.0));
}

//------------------------------------

float map(vec3 p)
{
  float r= 1.0;
  vec3 po= p;
	float univers = 4.;
	p.xyz = mod(p.xyz,univers)-(univers/2.5);
  
  p.xz *= rot(t);
  p.xy *= rot (t);
  r=min(r,boxpos(p,vec3(0.4)+sin(t)*0.1,vec3(0.0)));
  //p=po;
  p.x += 1.0;
  r=min(r,sphere(p,0.4));
  p.x -= 2.0;
  r=min(r,sphere(p,0.4));
  p.y -= 1.0;
  p.x += 1.0;
  r=min(r,sphere(p,0.4));
  p.y += 2.0;
  r=min(r,sphere(p,0.4));

  return r;
}

vec4 textu(sampler2D tx,vec2 uv) {
    return texture(tx,clamp(uv*vec2(1,-1),-.5,.5)-.5);;
}

//------------------------------------

void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 screen = uv;
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    float shade = 0.;
  vec3 ro;
  ro = vec3(0.,2.,5.);
  //ro.xy *= rot(t);
  ro.z -= t*5.;
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
      tex = vec3 (0.5,0.3,1.0);
   else
      tex = vec3 (0.9,0.3,0.0);

    tex += strobe;
        // gamma

	  col = tex*vec3(1.*sqrt(1.-shade*3.));
  }
  else
  {
    vec2 mov = 0.5*vec2 (sin(t*2.),cos(t));
    vec4 tx;
    if (mod(t,swaptime)>swaptime/2.)
    {
      tx =tex(texAmiga,(uv+mov)*3.5* abs(sin(t)));
    }
    else
    {
      tx =tex(texAtari,(uv+mov)*3.5*abs(sin(t)));
    }
    col.r = sin(t)* uv.x;
    col.g = cos(t)* uv.y;

    col= mix(col,tx.rgb,tx.a);; 
  }
  
  //------------------------------------

  	// 2D
	float coll = 0.;
	vec2 uvM = uv;
	//uvM.x += 0.3*sin(time);
	coll = max(coll,map2D(uvM));
	if (id==1)
	{
		uvM *=2.0 * sin (t) + 5.0;
		uvM *=rot(t*1.);
		if (((coll>0.0) && (coll<0.05*fract(t*15.)+0.04)))
		{
			col = vec3(0.1,0.9,0.1) *texture(texNoise,uvM).rgb + texture(texPreviousFrame,screen).rgb*0.4;
		}
	}
	if (id ==2)
	{
		if ((coll>0.0))
    {
      vec4 tx;
      vec2 mov = uv + vec2 (0.25*sin(t),0.25 *cos(t*2));
      mov.xy *= rot(t*3.);
      tx =tex(texEvilbotTunnel,((mov)*1.3));
      col= mix(col,tx.rgb,tx.a);; 
		    //col = vec3(0.);
    }
	}

    out_color = vec4(sqrt(col),1.);
}