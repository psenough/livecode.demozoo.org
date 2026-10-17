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

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec3 erot(vec3 p, vec3 ax, float a) {
  return mix(ax*dot(p,ax), p, cos(a)) + sin(a) * cross(p,ax);
}

vec2 n2(vec2 uv) {
  vec3 p=vec3(uv.x*342.23,uv.y*234.23, (uv.x+uv.y)*124.43);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z, p.y+p.z));
}

float vn(vec2 uv) {
  vec2 f=fract(uv);
  vec2 p=floor(uv);
  vec2 u=f*f*(3-2*f);
  
  float a = n2(p+vec2(0,0)).x;
  float b = n2(p+vec2(1,0)).x;
  float c = n2(p+vec2(0,1)).x;
  float d = n2(p+vec2(1,1)).x;
  
  return a + u.x*(b-a) + u.y*(c-a) +(a-b-c+d)*u.x*u.y;
}

float fbm(vec2 uv) {
  float res =0;
  float a = 0.5;
  for (int i=0;i<3;++i) {
    res += vn(uv);
    uv *= 2;
    a *= .4;
  }
  return res;
}

float tun(vec3 p) {
  vec3 q = abs(p-vec3(4,0,0)) - 13;
  float hol = max(q.x,max(q.y,q.z));
  for (int i=0;i<6;++i) {
    p.x = abs(p.x);
    p = erot(p,normalize(vec3(1,0.5,3)),0.3);
    p.x += .2;
    p *= 1.;
    p.z = abs(p.z);
    p.y -= .2;
  }
  vec2 cid = floor(p.xz+1);
  //p.xz = mod(p.xz+1,vec2(2))-1;
  //p.y -= texture(texFFT,n2(cid).x).x*10;
  
  float d=1e7;
  for (float x=-1;x<=1;++x) for (float y=-1;y<=1;++y) {
    vec2 co = cid + vec2(x,y);
    float boing = texture(texFFTSmoothed,n2(co).x).x*40;
    vec3 q = abs(p-vec3(co.x,boing,co.y))-0.2;
    d=min(d, max(q.x,max(q.y,q.z)));  
  }
  
  float res = d-.4;
  
  return min(res,hol);
}

float map(vec3 p) {
  return tun(p);
}

vec3 gn(vec3 p) {
  vec2 e=vec2(0.01,0);
  return normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv.y += floor(uv.x*10)*sin(n2(uv).x*1.4*texture(texFFTSmoothed,0.4).x);
  
  float ttr = sin(fGlobalTime)*15;
  vec3 ro = vec3(atan(sin(ttr*.4))*3,-3,-30+ttr), la=vec3(7*sin(texture(texFFTIntegrated,0.2).x+10*sin(floor(fGlobalTime))),6*sin(texture(texFFTIntegrated,0.6).x),-4+sin(ttr));
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  vec3 rd = normalize(f*2+r*uv.x-u*uv.y);
  
  float t=0,d;
  
  for (int i=0;i<100;++i) {
    d = map(ro+rd*t);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 col=mix(vec3(0.05),vec3(0.7,0.21,0.14)*0.5,length(uv))*10;
  vec3 ld=normalize(vec3(1,-2,3));
  
  if (d<0.01) {
    vec3 p= ro+rd*t;
    vec3 n = gn(p);
    col=vec3(1)*clamp(0.7+dot(ld,n),0.3,1.);
    if (n.y >0) {
      col += 0.7*fbm(1.4*p.xz+vec2(fGlobalTime*.5));
    }
  }
  col *= mix(vec3(1,0.5,0),vec3(0,0,1),fbm(rd.xy+0.3*sin(fGlobalTime)));
  col += texture(texFFT,0.3).x*40;
  
  out_color.rgb=col;
}