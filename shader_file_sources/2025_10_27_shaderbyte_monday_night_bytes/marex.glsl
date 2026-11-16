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

float sdEllipsoid( vec3 p, vec3 r )
{
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

mat2 R2D(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

vec2 map_wrong( vec2 p, float n )
{
    float b = 6.283185/n;
    float a = atan(p.y,p.x);
    float i = round(a/b);

    float c = b*i;
    p *= R2D(-c);
    
    return p; 
}

float sdCappedTorus( vec3 p, vec2 sc, float ra, float rb)
{
  p.x = abs(p.x);
  float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
  return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}

vec2 sdf(vec3 p){
  
  float tex = texture(texFFTSmoothed,1.).x*100.;
  
  vec3 lp = p;
  p.y = abs(p.y)-10.;
  vec3 rp = p;
  
  p.xz = mod(p.xz+vec2(0.,fGlobalTime*10.),15.)-7.5;
  rp.xz = mod(rp.xz+vec2(0.,fGlobalTime*10.),15.)-7.5;
  
  rp = erot(rp,normalize(vec3(0,1,0)),fGlobalTime*2.);
  rp += vec3(2.,2.,0.);
  rp = erot(rp,normalize(vec3(1,0,0)),3.);
  rp = erot(rp,normalize(vec3(0,0,1)),.8);

  p.xz = map_wrong(p.xz,10.);
  p.x -= 2.;
  
  float an = .7;
  vec2 se = vec2(sdEllipsoid(p,vec3(2.,2.7,2.)),1.);
  vec2 seh = vec2(sdCappedTorus(rp,vec2(sin(an),cos(an)),2,.75),3.);
  
  vec2 sp = vec2(length(lp-vec3(-80.,-80.,80.))-45.-tex,4.);
  
  se=seh.x<se.x ? seh:se;
  se=sp.x<se.x ? sp:se;
  
  return se;
  
}

mat3 cam(vec3 ro){
  
  vec3 cw = normalize(vec3(0.)-ro),cu=normalize(cross(cw,vec3(0,1,0))),cv=normalize(cross(cw,cu));
  return mat3(cu,cv,cw);
  
}
  
void main(void)
{
  vec2 uv = (gl_FragCoord.xy/v2Resolution.xy-.5)/vec2(v2Resolution.y/v2Resolution.x,1.);
  uv = floor(uv*200.)/200.;
  
  vec2 R2D = -abs(uv)*R2D(fGlobalTime/8.);
  uv = abs(R2D*2.);
  
  vec2 e = vec2(.001,-.001);
  vec3 ro = vec3(cos(fGlobalTime)*4.,sin(fGlobalTime)*4.,-10.);
  float texz = texture(texFFTSmoothed,1.).x*100.;
  vec3 rd = cam(ro+vec3(0.,2.,0.))*normalize(vec3(R2D,.1+texz*.2));
  vec2 dist = vec2(0.);
  vec3 tex = texture(texNoise,uv+vec2(cos(fGlobalTime)/4.,sin(fGlobalTime)/4.)).rgb;
  vec3 col = vec3(tex*.2);
  vec3 fog = vec3(length(uv)*2.-1.);
  float pattern = ceil(sin(uv.y*uv.x*20.)/20.);
  
  for(float i = 0.;i++<128.;){
    vec2 d = sdf(ro+rd*dist.x);
    if(d.x<.001||dist.x>100.)break;
    dist.x += d.x;dist.y = d.y;
    }

    if(dist.x<100.){
        vec3 p = ro+rd*dist.x;
        #define q(s) s*sdf(p+s).x
        vec3 n = normalize(q(e.xyy)+q(e.yyx)+q(e.yxy)+q(e.xxx));
        float dif = dot(rd,n);
      if(dist.y<2.){
        col = vec3(1.,.5,0.)+dif*fog;
      }
      if(dist.y>2.){
        col = vec3(.4,1.,0.1)+dif*fog;
      }
      if(dist.y>3.){
        vec3 ld = normalize(vec3(-.1));
        vec3 tex = texture(texNoise,uv+vec2(cos(fGlobalTime)/4.,sin(fGlobalTime)/4.)).rgb;
        float dif = dot(-rd*.34-ld*.5-.2,n);
        col = vec3(tex)*dif*3.*fog;
      }
      col += pattern*.2;
    }
    
	out_color =vec4(col,0.);
}