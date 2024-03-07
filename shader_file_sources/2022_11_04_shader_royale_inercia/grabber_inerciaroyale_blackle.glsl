#version 410 core

// hewwo :)

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax,p)*ax,p,cos(ro))+sin(ro)*cross(ax,p);
}

float sh1,sh2,sh3;
float time ;

float fac(vec3 p) {
  p = asin(sin(p));
  return dot(normalize(vec3(1)),p);
}

float noise(vec3 p, float dir) {
  float f1 = fac(erot(p, normalize(vec3(1,2,3)),1.4+sh1*dir));
  float f2 = fac(erot(p, normalize(vec3(-1,3,2)),2.4+sh2*dir));
  float f3 = fac(erot(p, normalize(vec3(1,-2,1)),.4+sh3*dir));
  
  return (f1 + f2)/sqrt(2);
  return (f1 + f2 + f3)/2.;
}

float ball(vec3 p, float w, float t, float dir) {
  vec3 p2 = normalize(p);
  float f = noise(p2*7*w, dir)/7/w;
  return length(vec2(f,length(p)-w))-t;
}

float scene(vec3 p) {
  float b1 = ball(p,1.,.1,-1);
  float b2 = ball(p,1.5,.03,1);
  float b3 = ball(p,2.,.02,-1);
  float b4 = ball(p/2.,2.,.01,1)*2.;
  return mix(min(min(b1,b2),min(b4,b3)), mix(noise(p*50., 1)/50., noise(p*10.,-1)/10., .5), .2);
}

vec3 norm(vec3 p) {
  mat3 k = mat3(p,p,p)-mat3(0.001);
  return normalize(scene(p) - vec3(scene(k[0]),scene(k[1]),scene(k[2])));
}

#define FK(x) floatBitsToInt(x*x/7.)^floatBitsToInt(x)
float hash(float a, float b) {
  int x = FK(a), y = FK(b);
  return float((x*x-y)*(y*y+x)-x)/2.14e9;
}

void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 uv2 = floor(uv*4)/4.;
  float hs = hash(uv2.x,uv2.y);
  time = fGlobalTime + (hash(hs,54.)+hash(hs,456.)+hash(hs,234.)+hs)*(.2*(sin(fGlobalTime*.5)*.5+.5));
  
  float bar = floor(gl_FragCoord.x / v2Resolution.x*20.)/20.;
  bar = abs(bar-.5);
  bool inbar = false;
  if (texture(texFFT, bar).x*(20.+bar*bar*600.)/3. > 1.-abs(gl_FragCoord.y / v2Resolution.y-.5)*2.) {
    inbar = true;
  }
  
  float it = fGlobalTime*.3;
  sh1 = sin(it);
  sh2 = cos(it*1.34235);
  sh3 = sin(it*2.15335);
  
  float off1,off2,off3,off4,off5;
  
  float tt = floor(time);
  float t2 = asin(sin(fGlobalTime)) * .2;
  off1 = sin(tt*45) + t2;
  off2 = cos(tt*33) + t2;
  off3 = sin(tt*76) + t2;
  off4 = sin(tt*17) + t2;
  off5 = sin(tt*99);

  vec3 cam = normalize(vec3(.7+off3*.5,uv));
  vec3 init = vec3(-3,off1,off2);
  
  float zrot = fGlobalTime*.3 + off4;
  cam = erot(cam,vec3(0,0,1),zrot);
  init = erot(init,vec3(0,0,1),zrot);
  
  float glow = 0.;
  
  vec3 p = init;
  bool hit = false;
  bool trig1 = false;
  bool refl=false;
  bool trig2 = false;
  float atten = 1.;
  for (int i = 0; i< 100 && !hit; i++) {
    float dist = scene(p);
    if(dist*dist<1e-6) {
      if (sin(erot(p,normalize(vec3(1,1,1)),.96).z*10.) < -0.85) {
      vec3 n = norm(p);
      atten*=1.-abs(dot(cam,n))*.9;
      p += n*.01;
      cam = reflect(cam,n);
        refl=true;
      }else{
      hit = true;
      }
    }
    float dd = distance(p,init);
    if (dist < 0.002*dd)trig1=true;
    if (dist > 0.002*dd && trig1)trig2=true;
    p += cam*dist;
    glow += .08/(length(p)+.01) * sqrt(abs(dist));
    if(distance(p,init)>100)break;
  }
  vec3 n = norm(p);
  vec3 r = reflect(cam,n);
  float diff = length(sin(n*2.)*.5+.5)/sqrt(3.);
  float ref = length(sin(r*2.)*.5+.5)/sqrt(3.);
  diff = mix(max(diff*2.-1.,0.), diff, .03);
  vec3 col = vec3(.9,.2,.2)*diff + pow(ref,20.)*(1-abs(dot(cam,n))*.9)*5.;
  out_color.xyz = sqrt(hit ? col : vec3(0));
  out_color.xyz += glow*vec3(0.1,.5,.8);
  out_color.xyz += glow*glow;
  out_color *= atten;
  
  if (trig2 && !refl) out_color *= 0.;
  out_color = smoothstep(.05,1.,out_color);
  
  if (inbar) off4 += 2.5;
  if (inbar) out_color += .5;
  out_color.xyz = erot(out_color.xyz*2.-1.,normalize(vec3(off1,off2,off3)), off4)*.5+.5;
  if (off5 < 0.0) out_color = 1. - out_color;
  out_color *= 1.-dot(uv,uv)*.5;
  out_color += noise(uv.xyy*500.,1)*.02;
  out_color = floor(out_color*8.)/8.;
}