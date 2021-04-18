#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float PI = 3.14159265;
const float TAU = 2*PI;
const vec3 up = vec3(0,1,0);
float time = mod(fGlobalTime, 6000.);
float bass = texture(texFFTSmoothed, .003).r * 15.;

mat2 r2d(float t){
  float c = cos(t), s = sin(t);
  return mat2(c,s,-s,c);
}

float mapbg(vec3 q){
  vec3 p=q;
  p *= 2;
  p.xy *= r2d(time*TAU*.01);
  float ns = sin(p.x+sin(p.y+sin(p.z)));
  q += ns;
  return length(q) - 1.;
}
vec3 grad(float t){
  t += time*.01;
  t += bass;
  vec3 a = vec3(.5), b = a, c = vec3(.2, .6, .4), d = vec3(.3,.7,.8);
  return a + b*cos(TAU*(c*t + d));
}

void chmin(inout vec4 d, vec4 o){
  d=d.x<o.x?d:o;
}
float box(vec3 p, vec3 b){
  p = abs(p) - b;
  return length(max(vec3(0), p)) + min(0, max(p.x, max(p.y,p.z)));
}


vec4 map(vec3 q){
  vec3 p = q;
  vec4 d = vec4(1000., 0,0,0);
  
  float t = time*TAU*.03;
  float scale = 1.4;
  float mul = scale-1;
  const int iter = 5;
  mat2 rxy = r2d(t*.13 + PI*.23);
  mat2 ryz = r2d(t*.213 + PI*.39);
  mat2 rxz = r2d(t*.33 + PI*.13);
  
  for(int i=0; i < iter; i++){
    p.xy *= rxy;
    p.yz *= ryz;
    p.xz *= rxz;
    p= abs(p);
    
    if(p.x<p.y) p.xy=p.yx;
    if(p.x<p.z) p.xz=p.zx;
    if(p.y<p.z) p.yz=p.zy;
    
    p.z -= .5*mul;
    p.z = -abs(p.z);
    p.z += .5*mul;
    
    p *= scale;
    p.xy -= mul;
  }
  
  float bx = box(p, vec3(1));
  bx *= pow(scale, -iter);
  float col = p.y;
  p=q;
  bx = mix(length(p)-1., bx, bass);
  
  chmin(d, vec4(bx, 1, .99, col*8.));
  
  p=q;
  vec2 uv = p.xz / 20.;
  float ns = texture(texNoise, uv).r;
  ns = texture(texNoise, uv + ns + t + bass*.1).r;
  p += ns;
  float pl = p.y + 1.3;
  chmin(d, vec4(pl,1,0.5,p.y*50.));
  
  p=q;
  float id = floor(length(p.xz)/5 + 1);
  p.xz *= r2d(t*id);
  
  p.xz = length(p.xz)<25.?mod(p.xz, 5.)-2.5:p.xz;
  p.y = abs(p.y) - 1.;
  
  p.xy *= r2d(bass*id);
  p.yz *= r2d(bass*(1.-id) + PI*.1);
  
  vec2 hw = vec2(.5, .05);
  bx = box(p, hw.xyy);
  bx = min(bx, box(p, hw.yxy));
  bx = min(bx, box(p, hw.yyx));
  chmin(d, vec4(bx, 0, .5, 0));
  
  return d;
}

vec3 normal(vec3 p){
  vec2 e = vec2(.00368,0);
  return normalize(vec3(
  map(p+e.xyy).x - map(p-e.xyy).x,
  map(p+e.yxy).x - map(p-e.yxy).x,
  map(p+e.yyx).x - map(p-e.yyx).x
  ));
}

vec3 lighting(vec3 p, vec3 n, vec3 v, vec4 light, vec4 d, vec3 bg){
  vec3 c;
  vec3 l = light.xyz - p;
  float r = length(l);
  l /= r;
  float lint = light.a / (r*r);
  float atten = max(.1, dot(n,l));
  vec3 albedo = d.y==1?grad(d.a):vec3(.5);
  vec3 h = normalize(l+v);
  float alpha = d.z;
  float bp = pow(max(0,dot(n,h)), 25);
  float schlick = (1-alpha)+alpha*pow(1-dot(n,v), 5);
  c += albedo*mix(1., bp, alpha);
  c *= atten;
  c += schlick*alpha*.005;
  c *= lint;
  return c;
}


vec3 post(vec2 uv, vec3 c){
  
  if(abs(length(uv) - bass*.05 - .25) < .03) c = vec3(1.) - c;
  float mask = uv.x + uv.y*bass*.3;
  if(mask < 0.) c = vec3(1.) - c;
  
  return c;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 c;
  vec3 ro = vec3(0);
  ro += vec3(0,-.5, 0);
  float beat = time*.4;
  float beatprg = mod(beat, 1.);
  float beatid = floor(beat);
  float ct = time*PI*.01 + TAU*.5*smoothstep(0, 1, pow(beatprg, 50.));
  ro += 5 * vec3(cos(ct), 0, sin(ct));
  vec3 focus = vec3(0);
  vec3 rov = normalize(focus - ro);
  vec3 cu = normalize(cross(rov,up));
  vec3 cv = cross(cu, rov);
  vec3 rd = mat3(cu,cv,rov) * normalize(vec3(uv, 1));
  
  float t = 0, bgd = 0, acc = 0;
  vec3 p = ro;
  
  float sound = texture(texFFTSmoothed, .003).r*7.;
  vec2 pt = mix(uv, floor(uv*25)/25., smoothstep(0., 1., sound));
  rd = mat3(cu,cv,rov) * normalize(vec3(pt,1));
  for(int i=0;i<9;i++){
    p = ro + rd*t;
    bgd = mapbg(p);
    t += bgd;
    acc += clamp(bgd - mapbg(p-rd*.05), -.03, 1.);
  }
  vec3 bg = grad(acc);
  c += pow(bg, vec3(2.2));
  
  t=0;
  vec4 d;
  rd = mat3(cu,cv,rov) * normalize(vec3(uv, 1));
  for(int i=0; i<128; i++){
    p = ro+rd*t;
    d = map(p);
    t += d.x*.666;
    if(d.x<.01) break;
  }
  
  vec4 l1 = vec4(3., 0., 0., 12);
  vec4 l2 = vec4(-3., -.5, 2., 12);
  vec4 l3 = vec4(3., 0., 2., 8);
  
  if(d.x<.01){
    c *=0 ;
    vec3 n = normal(p);
    c += lighting(p,n,-rd,l1,d,bg);
    c += lighting(p,n,-rd,l2,d,bg);
    c += lighting(p,n,-rd,l3,d,bg);
    
    float ao=0, st=.05;
    for(int i=1; i<=10;i++){
      ao += clamp(map(p+n*st*i).x/(st*i), 0., .1);
    }
    c *= ao;
  }
  
  c = pow(c, vec3(.45454));
  c = clamp(c, vec3(0), vec3(1));
  c = post(uv,c);
  
  out_color = vec4(c,1);
}