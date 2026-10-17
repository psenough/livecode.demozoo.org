#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void rand(in vec2 uv, out float d){
  //d = fract(sin(
}

float iScale;
const vec3 c = vec3(1.,0.,-1.);

void dbox3(in vec3 x, in vec3 b, out float d) {
  vec3 da = abs(x)-b;
  d = length(max(da, c.yyy))+min(max(max(da.x,da.y),da.z), 0.);
}

void add(in vec2 sda, in vec2 sdb, out vec2 sdf) {
  sdf = sda.x<sdb.x?sda:sdb;
}

void rot(in vec3 dx, out mat3 R) {
  R = mat3(1.,0.,0., 0., cos(dx.x), sin(dx.x),0., -sin(dx.x), cos(dx.x))*
    mat3(cos(dx.y),0.,sin(dx.y),0.,1.,0.,-sin(dx.y),0.,cos(dx.y)) *
    mat3(cos(dx.z),sin(dx.z),0., -sin(dx.z),cos(dx.z),0., 0.,0.,1.);
 
}

void scene(in vec3 x, out vec2 sdf) {
  mat3 R;
  rot(5.*fGlobalTime*vec3(.1,.2,.3), R);
  x = R*x;
  
  float size = .9;
  float p = atan(x.y,x.x);
  x.z = mod(x.z, size)-.5*size;
  
  sdf = vec2(length(x-.4*20.*iScale*c.yyx)-.2-10.*iScale,0.);
//  add(sdf, vec2(x.z,1.), sdf);
  float d;
  
  dbox3(R*(x-.2*vec3(.3,.2,.1)), vec3(.3,.2,.1), d);
  add(sdf, vec2(d,0.), sdf);
}

void normal(in vec3 x, in float dx, out vec3 n) {
  vec2 s, s2;
  scene(x,s);
  scene(x+dx*c.xyy, s2);
  n.x = s2.x-s.x;
  scene(x+dx*c.yxy, s2);
  n.y = s2.x-s.x;
  scene(x+dx*c.yyx, s2);
  n.z = s2.x-s.x;
  n = normalize(n);
}

void illuminate(in vec3 x, in vec2 s, in vec3 n, in vec3 l, in vec3 dir, out vec3 col) {
  if(s.y == 0.) {
    col = vec3(.7,.4,.1);
  }
  else if(s.y == 1.) {
    col = vec3(.1,.7, .4);
    }
    col = .1*col
          + .5* col * dot(l,n)
          + .5* col * pow(dot(reflect(normalize(x-l),dir),n),2.);
  
}

void main(void)
{
  iScale = texture(texFFTSmoothed, .003).r;
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 s;
  float d;
  vec3 o = c.yzx,
    ta = c.yyy,
    dir = normalize(ta-o),
      r = c.xyy,
      u = cross(dir, r),
      l = c.yzx,
      col = c.yyy,
  n,
  x;
  ta += r * uv.x + u * uv.y;
  dir = normalize(ta-o);
  
  int N = 250,i;
  
  d = 0.;
  
  for(i=0; i<N; ++i) {
    x = o + d * dir;
    scene(x,s);
    if(s.x<1.e-4)break;
    d += min(s.x,1.e-1);
  }
  
  if(i<N){
    normal(x,1.e-3,n);
    illuminate(x,s,n,l,dir,col);
  }
  
  

  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1 / length(uv) * .2;
   d = m.y;

  float f = texture( texFFT, d ).r * 100;
  m.x += sin( fGlobalTime ) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );
  out_color = t;
  out_color.rgb = length(out_color.rgb)/sqrt(3.)*vec3(1.)*texture(texFFTSmoothed, .003).r*10;
  out_color = vec4(col, 1.);
}
