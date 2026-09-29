#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(ax,p)*ax,p,cos(ro))+cross(ax,p)*sin(ro);
}

float comp(vec3 p) {
  p = asin(sin(p*8)*.99)/8;
  return dot(p,normalize(vec3(3,2,1)));
}

float d1,d2,d3;
float stuff(vec3 p) {
  d1 = comp(erot(p, normalize(vec3(1,2,3)), .7)+.3);
  d2 = comp(erot(p, normalize(vec3(1,3,2)), 1.6)+.6);
  d3 = comp(erot(p, normalize(vec3(3,-2,1)), .4)+.8);
  return (d1+d2+d3)/2.5;
}

float ball;
float scene(vec3 p) {
  vec3 p3 = p;
  p3.xy = asin(sin(p3.xy*3))/3;
  ball = length(p3)-.5+sin(fGlobalTime*9+length(sin(p)))*.02;
  p3.xy = asin(sin(p3.xy*8))/8;
  ball = min(ball, length(p3)-.2+sin(fGlobalTime*13)*.01);
  //ball += length(sin(p*100)/800);
  ball += length(sin(p*20)/50);
  ball += length(cos(p*10)/80);
  ball += length(sin(erot(p,normalize(vec3(2,3,4)),2.4)*150)/700);
  //ball += length(sin(erot(p,normalize(vec3(3,1,-4)),1.4)*200)/800);
  return min(stuff(p) + p.z*.1, ball);
}

vec3 norm(vec3 p) {
  mat3 k = mat3(p,p,p)-mat3(0.001);
  return normalize(scene(p) - vec3(scene(k[0]),scene(k[1]),scene(k[2])));
}

float bps = 32/10;

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  float rr = .9;
  vec4 past = texture(texPreviousFrame,uv + sin(mat2(cos(rr),-sin(rr),sin(rr),cos(rr))*uv*30+cos(uv))*.001);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float bar = floor(fGlobalTime*bps);
  float lastbigbar = floor((fGlobalTime-fFrameTime)*bps/4);
  float bigbar = floor(fGlobalTime*bps/4);
  float res = fGlobalTime - bigbar;
  if (lastbigbar != bigbar) past.w = .15;

	vec3 cam = normalize(vec3(3+sin(bigbar) + cos(res)*.3,uv));
  vec3 init = vec3(-3,0,0);
  
  bool camtype1 = sin(bigbar*3) < 0;
  bool camtype2 = cos(bigbar*7) < 0;
  bool camtype3 = sin(bigbar*9) < 0;
  bool camtype4 = sin(bigbar*2) < 0;
  
  float zrot = camtype1 ? 0. : fGlobalTime*.1;
  float yrot = .5;
  cam = erot(cam,vec3(0,1,0),yrot);
  init = erot(init,vec3(0,1,0),yrot);
  cam = erot(cam,vec3(0,0,1),zrot);
  init = erot(init,vec3(0,0,1),zrot);
  init.z += 1;
  float sgn = camtype3 ? -1 : 1;
  if (camtype1) init.x += sgn*mod(fGlobalTime,100)*.2;
  if (camtype2) init.y += sgn*mod(fGlobalTime,100)*.2;
  
  vec3 p = init;
  bool hit = false;
  float atten = 1.;
  float dist;
  for (int i = 0; i < 150; i++) {
    dist = scene(p);
    hit = dist*dist < 1e-7;
    p += cam*dist;
    
    if (hit) {
      if (abs(sin(d1*40))<.2 && dist != ball) {
        vec3 n = norm(p);
        
        float fres = 1.-abs(dot(cam,n))*.98;
        cam = reflect(cam,n);
        atten *= fres;
        p += n*.01;
        hit = false;
      } else {
        break;
      }
    }
    if (distance(p,init)>100)break;
  }
  
  bool isball = ball == dist;
  float fog = smoothstep(1,10,distance(p,init));
  float sd1 = d1;
  vec3 n = norm(p);
  vec3 r = reflect(cam,n);
  float ao = smoothstep(-.1,.1,scene(p+n*.3));
  float fact = length(sin(r*3)*.5+.5)/sqrt(3)*ao;
  float diff = length(sin(n*3)*.5+.5)/sqrt(3)*ao;
  float fres = 1.-abs(dot(cam,n))*.98;
  float spec = (pow(fact,8)*4+fact*.2)*fres;
  vec3 diffcol = isball ? (camtype4? vec3 (.5,.01,.1) :vec3 (.2,.01,.2) ): vec3(0.01,.04,.1)*0;//pow(sin(p*2)*.5+.5,vec3(2.))*.8+.2;
  vec3 col = diff*diffcol + spec;
  col = mix(col, vec3(0.01), fog);
  out_color.xyz = (hit ? col : vec3(0.01))*atten + vec3(0.02,0.01,.04);
  float pre = length(out_color.xyz);
  pre = mix(pre, past.w,.98);
  float vig = 1.-dot(uv,uv)*.5;
  out_color += pre;
  out_color = sqrt(smoothstep(0.,1.4,out_color))*vig;
  mat3 desat = mat3(vec3(.1),vec3(.1),vec3(.1))+mat3(.7);
  mat3 sat = inverse(desat);
  out_color.xyz *= sat;
  out_color.xyz *= sat;
  out_color.a = pre;
}