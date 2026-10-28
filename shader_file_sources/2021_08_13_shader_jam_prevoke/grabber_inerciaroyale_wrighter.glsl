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
///  3 out, 3 in...
vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

vec3 n;

vec2 box( in vec3 ro, in vec3 rd, vec3 boxSize, out vec3 outNormal ) 
{
    vec3 m = 1.0/rd; // can precompute if traversing a set of aligned boxes
    vec3 n = m*ro;   // can precompute if traversing a set of aligned boxes
    vec3 k = abs(m)*boxSize;
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;
    float tN = max( max( t1.x, t1.y ), t1.z );
    float tF = min( min( t2.x, t2.y ), t2.z );
    if( tN>tF || tF<0.0) return vec2(-1.0); // no intersection
    outNormal = -sign(rd)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz);
    return vec2( tN, tF );
}







vec2 trace(vec3 ro, vec3 rd){
  return box(ro,rd,vec3(1),n);
}

#define beat iTime/60*127*1.


vec3 gp;

vec3 get(vec3 p){
p *= 1.1;
p.xz *= rot(0.5 + iTime*0.3);
p.xy *= rot(0.3 + iTime + sin(iTime));
vec3 op = p;
  
p.x += (iTime + sin(iTime))*0.1;
  float c = floor(p.x*2.);
  c = mod(c,2)/2;
  gp = p;
  vec3 cc = vec3(mix(0.2 + sin(p.xzy)*0.0,vec3(0) + 1.5 + 4 *mod(floor(p.y)*40.,2),c));
p = op;
  cc = mix(cc,4.5 * mod(beat,1.)-cc,smoothstep(0.001,0.,length(p.y) - 0.5));
    return cc;
}








void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  //pxSz = fwidth(uv.y);
  
  vec2 U = gl_FragCoord.xy;
  vec3 col = vec3(0);
  
  vec3 ro = vec3(0);
  vec3 p = ro;
  vec3 rd = normalize(vec3(uv,0.1));
  rd.xz *= rot((sin(iTime*0.5) + sin(iTime))*0.3);
  rd.yz *= rot(iTime*0.2);
  
  vec2 t = trace(p,rd);  
  p += rd*t.y;
  vec3 c = get(p);
  vec3 att = vec3(1)*c;
  
  
  float bounces = 40;
  float ratio = 0. + 1*mod(floor(gp.z*2),2.)*0.9;
  p += n*0.01 ;
  for(float bnc = 0.; bnc < bounces; bnc++){
    vec3 diff = hash33(vec3(uv*111.,bnc + iTime*0.1));
    if(dot(diff,n)<0.)
      diff = -diff;
    vec3 refl = -reflect(rd,n);
    vec3 rdd = mix(diff,refl,ratio);
    rdd = normalize(rdd);
    vec2 t = trace(p,rdd);
    vec3 pp = p + rdd*t.y;
    vec3 scene = get(pp);
    col += scene*att/bounces;
    
  }
  
  {
    float d = length(uv) - 0.3;
    
    
    float db = length(uv) - 0.2;
    if(mod(beat,1) < 0.25)
      col = mix(col,1.-col*1.,smoothstep(0.001,0.,d));
    else if(mod(beat,4) > 3)
      col = mix(col,col*0.1*vec3(1,0,0),smoothstep(0.001,0.,db));
    
    if(abs(uv.x) > 0.55 && mod(beat,16) > 14)
      col = col*0.1*vec3(1,0.8,0);
    
    
  }
  if(abs(uv.y) > 0.4)
      col = col*0.1*vec3(0,0,0);
    
  
  
  
  col = pow(max(col,0),vec3(0.4545));
  out_color = vec4(col,1);
}