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

mat2 rot(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec2 n2(vec2 uv) {
  vec3 p = vec3(uv.x*324.23,uv.y*342.32,(uv.x+uv.y)*421.32);
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vor(vec2 uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  
  float res = 1e7;
  for (int x=-1;x<=1;++x) for (int y=-1;y<=1; ++y) {
    vec2 c = vec2(x,y);
    vec2 r = c - f + n2(p+c);
    float d = dot(r,r);
    res = min(res,d);
  }
  return sqrt(res);
}

float vn(vec2  uv) {
  vec2 p = floor(uv);
  vec2 f = fract(uv);
  vec2 u = f * f * (3 - 2 * f);
  
  float a = n2(p + vec2(0,0)).x;
  float b = n2(p + vec2(1,0)).x;
  float c = n2(p + vec2(0,1)).x;
  float d = n2(p + vec2(1,1)).x;
  
  return a + (b - a) * u.x + (c - a) * u.y + (a - b - c + d) * u.x * u.y;
}

float fbm(vec2 uv) {
  float res = 0;
  float a = 0.4;
  
  for (int i=0;i<3;++i) {
    res += vn(uv)*a;
    a *= 0.4;
    uv *= 2;
  }
  return res;
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float map(vec3 p, out vec3 uvw, out int mat) {
  vec3 q = p;
  //q *= 1.1;
  q.xz *= rot(pow(sin(texture(texFFTIntegrated,0.1).x),3)*0.4);
  q.yz*=rot(3.1415/2);
  float res = length(q)-4;
  uvw.x = atan(q.x,q.z);
  uvw.y = q.y;
  mat = 1;
  
  float flr = p.y+6 - (texture(texFFT,0.1).x*10+3)*fbm(p.xz/2-vec2(20,texture(texFFTIntegrated,0.1).x*10));
  if (flr < res) {
    res = flr;
    uvw.xy = p.xz;
    mat =2;
  }
  return res;
}

float shad(vec3 ro, vec3 ld) {
  float t= 0.2;
  float res = 1.;
  vec3 rd = normalize(ld);
  for (int i=0;i<10;++i) {
    vec3 ig1;
    int ig2;
    float h = map(ro + rd * t,ig1,ig2);
    if (h<0.01) return 0;
    res = min(res, 12 * h/t);
  }
  return res;
}

vec3 gn(vec3 p) {
  vec3 ig1;
  int ig2;
  vec2 e = vec2 (0.1,0);
  return normalize(map(p,ig1,ig2) - vec3(map(p-e.xyy,ig1,ig2),map(p-e.yxy,ig1,ig2), map(p-e.yyx,ig1,ig2)));
}

void main(void)
{
  float btm = texture(texFFTIntegrated,0.1).x;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ruv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro=vec3(sin(btm)*10,3,-35-texture(texFFTSmoothed,0.045).x*150+texture(texFFT,0.045).x*50);
  
  vec3 la=vec3(0);
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  
  vec3 rd = normalize(f*3+r*uv.x-u*uv.y);
  
  float d, t=0;
  
  vec3 uvw;
  int mat;
  for(int i=0;i<100;++i) {
    d = map(ro+rd*t,uvw,mat);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 bgcol = vec3(0);
  vec3 col = bgcol;
  
  vec3 ld = normalize(vec3(1,1.2,-1));
  
  if (d<0.01) {
    vec3 p = ro+rd*t;
    vec3 n = gn(p);
    float spem = 1.;
    if (mat == 1) {
      col = vor(uvw.xy*vec2(50,3))*vec3(0.9,0.,0.);
      col = mix(vec3(0),col,smoothstep(3.91,3.811,uvw.y));
      col = mix(col,vec3(1),smoothstep(3.31,3.211,uvw.y));
      
    } else if (mat == 2) {
      col = vec3(0.8,0.1,0.01)*0.2;
      col += vec3(0,0.3,0.5)*fbm(uvw.xy);
      spem = 0.3;
    }
    col *= dot(ld,n);
      col += vec3(0.5,1.,1.) * pow(max(dot(reflect(-ld,n),-rd),0),4)*0.4*spem;
    col *= shad(p,ld);
  }
 
  col = mix(bgcol,col,exp(-0.000007*t*t*t));
  col *= (0.8+0.2*n2(uv+fGlobalTime).x);
  col *= smoothstep(1.,.8,length(uv));
  col = pow(col,vec3(0.4545));
  
  out_color.rgb = col;
}