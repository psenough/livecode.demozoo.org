#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent restrict uimage2D[3] computeTex;
layout(r32ui) uniform coherent restrict uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 n2(vec2 uv) {
  vec3 p = vec3(234.23*uv.x, 342.23*uv.y,423.32*(uv.x+uv.y));
  p = mod(p,vec3(3,5,7));
  p += dot(p,p+34);
  return fract(vec2(p.x+p.z,p.y+p.z));
}

float vn(vec2 uv) {
  vec2 f = fract(uv);
  vec2 p = floor(uv);
  vec2 u = f * f * (3 - 2*f);
  
  float a = n2(p + vec2(0,0)).x;
  float b = n2(p + vec2(1,0)).x;
  float c = n2(p + vec2(0,1)).x;
  float d = n2(p + vec2(1,1)).x;
  
  return a + (b - a) * u.x + (c - a) *u.y + (a - b - c + d) *u.x*u.y;
}
 

float fbm(vec2 uv) {
  float a = 0.5;
  float res = 0;
  for (int i=0;i<3;++i) {
    res += a*vn(uv);
    a *= 0.4;
    uv *= 2;
  }
  return res;
}

float cyl(vec3 p, float h, float r) {
  float abrad = abs(length(p.xz))-r;
  float ablen = abs(p.y)-h;
  return min(max(abrad, ablen),0) // inside 
       + length(max(vec2(abrad,ablen),0)); // outside;
}

float piston(vec3 p) {
  p -= vec3(0,7.5,0);
  return cyl(p,1.5  ,0.25);
}

float pistonOuter(vec3 p) {
  p += vec3(0,1.5,0);
  return cyl(p,2,.4);
}

float wheel(vec3 p) {
  return cyl(p.xzy,0.125,1.5);
}

float tcb;

float gnd(vec3 p) {
  return p.y-fbm(p.zx/3)*0.7*(1-cos(p.z/20))*4+4;
}
float gl=1e7;

float map(vec3 p, out vec3 uvw, out int mat) {
  mat = 1;
  vec3 op = p;
  p.x = mod(p.x+5,10)-5;
  p.z = abs(p.z+10)-10;
  p.y +=3;
  float t=tcb*10;
  uvw = p;
  vec3 movepoint = vec3(sin(t),cos(t)+5.5,0);
  vec3 f = normalize(-movepoint);
  vec3 r = cross(f,vec3(0,0,1));
  vec3 i = cross(f,r);
  vec3 qq = p- movepoint;
  vec3 q = -qq.x*r+qq.y*f+qq.z*i;
  vec3 qqq = -p.x*r +p.y*f+p.z*i;
  float spinpoint = cyl(qq.xzy,0.4,0.3);
  //q.y += cos(t)*1;
  float res = piston(q + vec3 (0,6,0));
  float whl = wheel(p-vec3(0,5.5,0.4));
  if (whl< res) {
    res = whl;
    mat=3;
  }
  if (spinpoint < res) {
    res = spinpoint;
    mat = 4;
  }
  float pot = pistonOuter(qqq);
  if (pot < res) {
    res = pot;
    mat = 5;
  }
  
  vec3 qa = abs(qq-vec3(0,0,3));
  float pts=max(qa.y,qa.z)-0.1;
  gl = min(gl,pts);
  
  if (pts < res) {
    res = pts;
    mat = 2;
  }
  
  float gnd0 = gnd(op);
  if (gnd0 < res) {
    res = gnd0;
    p=op;
    mat = 2;
  }
  return res;
}

vec3 gn(vec3 p) {
  vec2 e= vec2(0.01,0);
  vec3 ig1;
  int ig2;
  return normalize(map(p, ig1, ig2)-vec3(map(p-e.xyy, ig1, ig2),map(p-e.yxy, ig1, ig2),map(p-e.yyx, ig1, ig2)));
}


void main(void)
{
  tcb=texture(texFFTIntegrated,0.1).x;
  float t1=cos(tcb)*2;
  float t2=sin(tcb)*2;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 ro = vec3(t1-50+tcb*20,1+t1*0.4,t2-10);
  vec3 la = vec3(tcb*20,0,atan(sin(tcb))*50);
  //vec3 rd=normalize(vec3(uv,1));
  
  vec3 f = normalize(la-ro);
  vec3 r = cross(f,vec3(0,1,0));
  vec3 u = cross(f,r);
  
  vec3 rd = normalize(f + r * uv.x - u * uv.y);
  gl=1e7;
  
  int mat = 0;
  vec3 uvw;
  
  float t=0,d;
  
  for (int i=0; i<100; ++i) {
    d = map(ro+rd*t,uvw, mat);
    if (d<0.01) break;
    t += d;
    if (t>100) break;
  }
  
  vec3 ld = normalize(vec3(3,2,-1));
  
  vec3 bgcol = mix(vec3(250,73,53), vec3(87,45,55), fbm(rd.xy*10))/255;
  
  //bgcol = mix(bgcol,vec3(0),smoothstep(0.5,0.49,length(rd.zy)));
  float lbv = (1-texture(texFFT,0.045).x*0.7);
  bgcol += (1-texture(texLynn,lbv*rd.zy*vec2(1,-1)+.5).rgb)*smoothstep(0.55,0.49,length(rd.zy));
  
  bgcol = mix(bgcol,vec3(21,8,28)/255,smoothstep(-0.1,0.1,-rd.y));
  vec3 col = bgcol;
  
  if (d<0.01) {
    vec3 n = gn(ro+rd*t);
    if (mat == 1) {
      col = vec3(1);
    } else if (mat == 2) {
      col = vec3(0.8,0.4,0.4);
    } else if (mat == 3) {
      col = vec3(251,164,88)/255;
    }
     col*= (0.1+clamp(dot(n,ld),0.,1.));
    
  }
  
  //col = mix(col,vec3(1,1,0.5),clamp(exp(-0.00005*gl*gl),0,1));
  
  col = mix(bgcol,col,exp(-0.000006*t*t*t));
  
  out_color.rgb=col;
}