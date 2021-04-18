#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax,p)*ax,p,cos(ro))+sin(ro)*cross(ax,p);
}

float box(vec2 p, vec2 d) {
  p = abs(p)-d;
  return length(max(p,0.)) + min(0,max(p.x,p.y));
}

vec3 tree(vec3 p) {
  for (int i = 0; i < 8; i++) {
  //p.y -= 1.;
  p.x = abs(p.x);
  vec2 roter = normalize(vec2(.4,1.));
  p.xz -= roter*max(dot(p.xz,roter),0.)*2.;
  p.z += .25;
    p = erot(p,vec3(0,0,1),fGlobalTime);
  }
  return p;
}

float pillar;
float scene(vec3 p) {
  vec3 p2 = vec3(asin(sin(p.xy)*.5),p.z);
  vec3 p3 = vec3(p.xy,p.z-1.25);
  vec2 id = floor(p.xy/4.)*4.+2;
  p3.xy -= id;
  p3 = erot(p3, vec3(0,0,1),id.x);
  p3=tree(p3);
  vec2 crds = vec2(length(p3.xy),p3.z);
  pillar = box(crds, vec2(.02,.25))-.01;
  float ball = length(p2)-1;
  return min(pillar,ball);
}

vec3 norm(vec3 p) {
  mat3 k = mat3(p,p,p)-mat3(.001);
  return normalize(scene(p) - vec3( scene(k[0]),scene(k[1]),scene(k[2]) ));
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  //uv *= 20.;
  
  //out_color.xyz = sin(vec3(box(tree(uv), vec2(0.,1.)))*20)*.5+.5;

  float t = cos(fGlobalTime)*.3;
  float yrt = sin(t)*.2+.5;
  vec3 cam = normalize(vec3(1,uv));
  vec3 init = vec3(-8,0,0);
  
  init = erot(init,vec3(0,1,0), yrt);
  cam = erot(cam ,vec3(0,1,0), yrt);
  init = erot(init,vec3(0,0,1), t);
  cam = erot(cam, vec3(0,0,1), t);
  init.x += asin(sin(fGlobalTime*.1))/.05;
  vec3 p = init;
  bool hit = false;
  float dist;
  for (int i = 0; i < 200 && !hit; i++) {
    dist = scene(p);
    hit = dist*dist < 1e-6;
    p += dist*cam*.7;
  }
  bool pl = pillar == dist;
  float fog = smoothstep(40.,10.,distance(p,init));
  vec3 n =  norm(p);
  vec3 r = reflect(cam,n);
#define AO(p, d, s) smoothstep(-s,s,scene(p+d*s))
  float ao = AO(p,n,.1)*AO(p,n,.3)*AO(p,n,.5);
  float ro = AO(p,r,.1)*AO(p,r,.3);
  
  vec3 ldir = normalize(vec3(1));
  
  vec3 p2 = p+ldir*.1;
  float mdd = 100.;
  for (int i = 0; i < 50; i++) {
    float dd = scene(p2);
    mdd = min(abs(dd),mdd);
    p2 += dd*ldir;
  }
  float diff = length(sin(n*2.)*.4+.6)/sqrt(3.);
  float spec = length(sin(r*5.)*.4+.6)/sqrt(3.);
  float fres = 1.-abs(dot(cam,n))*.98;
  float specpow = .2;
  vec3 diffcol = vec3(.05,.05,.05);
  if (pl) {
    diffcol = vec3(.7,.05,.05);
    specpow = 1.5;
    ao *= smoothstep(-1.,1.,dot(ldir,n));
    ro *= smoothstep(-1.,0.,dot(ldir,n));
  } else {
    ao *= smoothstep(0.,0.1,mdd);
  }
  
  vec3 col = diffcol*diff*ao + pow(spec,10.)*fres*specpow*ro;
  vec3 fogcol = vec3(.3,.4,.6);
  out_color.xyz = sqrt(hit ? mix(fogcol,col,fog) : fogcol);
}