#version 410 core

#define TAU 6.2831853071

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

mat2 rot2( float a ){ vec2 v = sin(vec2(1.570796, 0) - a);	return mat2(v, -v.y, v.x); }

#define MAX_STEPS 40
#define MAX_DIST 40.
#define SURF_DIST .01
//I didn't optimize this


float c2f(in float x){
  return x*.5+.5;
}
//https://iquilezles.org/articles/distfunctions
float sdBox( vec3 p, vec3 pos, vec3 b )
{
  //vec3 q = abs(p-pos) - b;
  //return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
  
  float e = b.r*.2;
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float sdHexPrism( vec3 p, vec2 h )
{
  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  vec2 d = vec2(
       length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//SPONGE
float GetDist(vec3 p){
    //the main cube
    float box = sdBox(p, vec3(0.), vec3(0.2));
    float hex = sdHexPrism(p, vec2(.3, .2)*rot2(c2f(sin(fGlobalTime*2.632))));
    
  
    float d = max(box, hex);
  
    return d;
}

float RayMarch(vec3 ro, vec3 rd){
    float dO = 0.;
    
    for(int i=0; i<MAX_STEPS; i++){
        vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO > MAX_DIST || dS < SURF_DIST) break;
    }
    
    return dO;
}

vec3 GetNormal(vec3 p){
    float d = GetDist(p);
    vec2 e = vec2(.01, 0.);
    
    vec3 n = d-vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx)
    );
    
    return normalize(n);
}

float GetLight(vec3 p){
    vec3 lightPos = vec3(2., 10., 6.);
    
    vec3 l = normalize(lightPos-p);
    
    vec3 n = GetNormal(p);
    
    float dif = clamp(dot(n, l), 0., 1.);
    float d = RayMarch(p+n*SURF_DIST*2., l);
    if(d<length(lightPos-p)) dif*=0.1;
    
    return dif;
}

vec2 distort(vec3 seed, float time){
		return vec2(sin(time*seed.x)+seed.y*cos(seed.z), cos(dot(seed.yz, seed.zx)+sin(time+seed.y)));
}

float addUp(vec3 v){
    return v.x+v.y+v.z;
}



vec2 fromAngle( in float n ){
    return vec2(cos(n), sin(n));
}

float circle(vec2 uv, vec2 pos, float radius){
    return step(0., distance(uv, pos)-radius);
}
  
 vec3 sat(in vec3 c, in float a)
  {
    return vec3(
    pow(c.r-(c.b+c.g)*.5, a),
    pow(c.g-(c.r+c.b)*.5, a),
    pow(c.b-(c.r+c.g)*.5, a)
    );
  }

float brightness(in vec4 col)
{
  return (col.r+col.g+col.b)/3.;
 }
float brightness(in vec3 col)
{
  return (col.r+col.g+col.b)/3.;
 }

float rand(in vec2 st)
  {
    return texture(texNoise, st).r;
    }
float noise(vec2 p, float freq ){
	float unit = v2Resolution.x/freq;
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(TAU*.5*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec4 prev = texture(texPreviousFrame, uv);
  vec3 tex_normal = texture(texTex4, uv).rgb;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float t = fGlobalTime*1.9;
  // --------------------------------------------------------------------
    vec3 ro = vec3(1.);
    ro.xz = vec2(cos(t), sin(t))*5.;
    ro.y = sin(20.+t/2.)*5.;
    
    vec3 lookat = vec3(0.);
    
    vec3 f = normalize(lookat-ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = cross(f, r);

    vec3 i = uv.x*r + uv.y*u;
    
    vec3 rd = normalize(i-ro);

    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd*d;
    
    vec3 nor = GetNormal(p);
    if(d>MAX_DIST){
        nor = vec3(0.);
    }
    
    vec3 id = vec3(addUp(nor*vec3(1.,1.,-1.))>0.?1.:0.,
                    addUp(nor*vec3(1.,-1.,1.))>0.?1.:0.,
                    addUp(nor*vec3(-1.,1.,1.))>0.?1.:0.);
    uv = mix(uv+distort(id, t)*.5, uv, smoothstep(MAX_DIST-1., MAX_DIST, d));
  	//vec3 col = mix(texture2D(u_tex, tex_uv+distort(id, u_time)*0.1).rgb, texture2D(u_tex, tex_uv).rgb, smoothstep(MAX_DIST-1., MAX_DIST, d));
  // --------------------------------------------------------------------
  
  vec2 uv_i = floor(uv*32.)/32.;
  uv_i += tex_normal.rb*0.04;
  uv_i += tex_normal.bg*0.02;
  
  float radius = 1.2;
  
  float tmod = mod(t, 8.);
  float amt = min(sin(fract(t)*TAU/4.0)*1.5, 1.0) + floor(tmod) + 1.0;
  
  float sum = 0.0;
  
  float spacing = 0.2;
  
  float turn = TAU/amt;
  for(float i=0.; i<amt; i++){
    sum = mix(sum,1.-sum,
        circle(mix(uv, uv_i, c2f(sin(t)*cos(t*9.5))), 
          vec2(cos(i*turn), sin(i*turn))*spacing, 
          .2+(pow(radius*c2f(sin(t)), 3.)*pow(radius*c2f(sin(t*2.4545)), .2))*.4
      )
    );
  }
  
  vec2 rotating = fromAngle(t)*uv_i;
  vec2 rotating2 = uv_i*rot2(pNoise(vec2(t,3000.),0)*sin(tmod));
  
  vec2 amogus = mix(rotating, rotating2, c2f(sin(tmod*2.)));
  
  float f_t = fract(amogus.x*amogus.y+t);
  
  vec3 color_a = vec3(c2f(sin(uv_i.x+t))*0.6,c2f(sin(uv_i.x+t*2.4))*0.2,c2f(sin(uv_i.x+t*1.8))*0.3);
  vec3 color_b = vec3(c2f(sin(uv_i.y+t*3.4))*0.1,c2f(sin(uv_i.y+t))*0.8,c2f(sin(uv_i.y+t*.4))*0.1);
  vec3 color_c = 1.-color_a;
  vec3 color_d = 1.-color_b;
  
  vec2 moving = vec2(uv.x+pNoise(vec2(t,500.),0)+sin(tmod), uv.y+pNoise(vec2(t,2000.),0)+cos(tmod));
  
  vec3 col = mix(mix(color_a, color_d, step(moving.x,0.)), mix(color_c, color_b, step(moving.y,0.)), sum);
  
  col = mix(col, vec3(0.), brightness(fwidth(col)));
  
  col = mix(col, vec3(0.), texture(texFFT, 0.2).r*90.);
  
  out_color = vec4(col, 1.);
}