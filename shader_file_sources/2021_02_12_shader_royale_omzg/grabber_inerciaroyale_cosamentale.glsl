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
float time = fGlobalTime;
float rd(vec3 p){return fract(sin(dot(floor(p),vec3(45.,65.,269.)))*7845.236);}
mat2 rot(float t){float c = cos(t); float s = sin(t); return mat2 (c,-s,s,c);}
float bl (vec2 p, vec2 b){ vec2 q = abs(p)-b;
  return length(max(vec2(0.),q))+min(0.,max(q.x,q.y));}
  float box (vec3 p, vec3 b){ vec3 q = abs(p)-b;
  return length(max(vec3(0.),q))+min(0.,max(q.x,max(q.z,q.y)));}

  float zl1 ;float zl2;float bl2;float zl3; float bl3;
float map(vec3 p,vec3 tm){
  vec3 pb =p;
  vec3 pc = p;
   pc.xy *= rot(tm.y);
  vec3 pnc =pc;
 
  vec3 pn = p;
  vec3 pl = p;
  p = abs(p);
  p -= 1.;
  if(p.x>p.y)p.xy=p.yx;
  if(p.x>p.z)p.xz=p.zx;
  vec3 p2 = p;
  vec3 rp1 = vec3 (2.);
  p = mod(p,rp1)-0.5*rp1;
  vec3 rp2 = vec3 (4.);
  p2 = mod(p2,rp2)-0.5*rp2;
  float d1 = bl(p.zy,vec2(0.2));
  float d2 = bl(pn.xz,vec2(5.));
  float d4 = bl(p2.xz,vec2(0.1));
  float dl =min(d1,d4);
  float d3 = max(min(d1,d4),-d2);
  zl1 = max(d4,-d2);
  //return d3;
  pc = abs(pc);
  pc += 3.;
  if(pc.x<pc.y)pc.xy=pc.yx;
  if(pc.y<pc.z)pc.yz=pc.zy;
  vec3 pc2 = pc;
  vec3 rc1 = vec3(0.1,0.3,0.55);
  pc = mod(pc,rc1)-0.5*rc1;
  vec3 rc2 = vec3(0.005,0.3,0.2+fract(time*0.1));
  pc2 = mod(pc2,rc2)-0.5*rc2;
  float c1 = box(pc,vec3(0.1));
  float c2 = min(box(pnc,vec3(2.5,0.2,0.5)),box(pnc,vec3(0.5,5.,0.5)));
  float c4 = box(pc2,vec3(0.02));
  float c5 = min(length(pn)-tm.z*2.5,length(pc)-tm.z*0.2);
  float c3 = max(max(min(c1,c4),c2),-c5);
  float cl = min(max(c4,c2),length(pn)-tm.z*2.5);
  
  zl2 = cl;
  float fl2 = 0.01;
  bl2 += fl2 /(fl2+cl);
  float r2 = min(d3,c3);
  pb += vec3(0.,-5.,0.);
  vec3 pb2 = pb;
  vec3 pb3 = pb;
  float ft = 6.38/12.;
  float at = mod(atan(pb.y,pb.x)+0.5*ft,ft)-0.5*ft;
  pb.xy = vec2(cos(at),sin(at))*length(pb.xy);
  float at2 = mod(atan(pb2.y,pb2.z)+0.5*ft,ft)-0.5*ft;
  pb2.zy = vec2(cos(at2),sin(at2))*length(pb2.zy);
  float at3 = mod(atan(pb3.z,pb3.x)+0.5*ft,ft)-0.5*ft;
  pb3.xz = vec2(cos(at3),sin(at3))*length(pb3.xz);
  float b1 = box(pb-vec3(2.5,0.,0.),vec3(tm.x,0.02,0.02));
  float b2 = box(pb2-vec3(0.,0.,2.5),vec3(0.02,0.02,tm.x));
  float b3 = box(pb3-vec3(2.5,0.,0.),vec3(tm.x,0.02,0.02));
  float b5 = length(pn)-tm.z*5.;
  float b4 = max(min(min(b1,b3),b2),-pn.y+5.);
  
  float fl3 = 0.01;
  bl3 += fl3 /(fl3+b4);
  zl3 = b4;
  float r3 = min(r2,b4);
  return r3;
  }
  vec3 nor (vec3 p,vec3 tm){vec2 e = vec2(0.01,0.); return normalize(map(p,tm)-vec3(map(p-e.xyy,tm),map(p-e.yxy,tm),map(p-e.yyx,tm)));}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 uc = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  float t1 = pow(sin(time*0.5)*0.5+0.5,10.);
  vec3 p = vec3(0.,t1*20*sin(time*0.25)+3.,-5.);
  float tmx = mod(time*5.,floor(fract(time*0.1)*10.)/10.+0.1)*1.1;
  vec3 r = normalize(vec3(uv,0.4+fract(time*3.)*0.1));
  
  float tmy = mix(pow(fract(time*0.1),10.),pow(1.-fract(time*0.1),0.1),step(0.5,fract(time*0.05)));
  float tmz = smoothstep(0.5,0.9,fract(time*0.2));
  vec3 tm = vec3(tmx,tmy,tmz);
  p.xz*= rot(time);
  r.xz*= rot(time);
  r.zy *=rot(t1*2.);
  float dd = 0.;
  for(int i = 0 ; i < 48 ; i++){
    float d = map(p,tm);
    if(dd>40.){break;}
    if(d<0.01){break;}
    p += r*d;
    dd +=d;
  }
  vec3 n = nor(p,tm);
  float tex = rd(p*30.);
  float s = smoothstep(40.,0.,dd);
  float dn = smoothstep(0.,2.,length(p.y))*smoothstep(0.,2.,length(p.x))*smoothstep(0.,2.,length(p.z));
  float ml = distance(0.5,fract(p.x*0.1+time*2.));
  float l1 = smoothstep(2.,0.,zl1)*0.2+smoothstep(3.,0.,zl1)*0.1*smoothstep(0.,0.5,ml)*dn;
  l1 += smoothstep(1.,0.,zl1)*1.5*smoothstep(0.25,0.26,ml);
  float l2 = smoothstep(0.05,0.,zl2)*2.+bl2*0.05;
  float l3 = smoothstep(0.05,0.,zl3)*2.+bl3*0.5;
  float ld = clamp(dot(n,-r),0.,1.);
  float fres = pow(1.-ld,3.+tex*6.)*0.1;
  float spec = pow(ld,5.+tex*10.)*0.2;
  float b = sqrt(24.);
  float c = 0.;
  float d = pow(length(uv.y),2.)*0.03+0.0001;
  float r0 = (fres+spec+l1+l2+l3)*s;
  for(float j = -0.5*b;j <=0.5*b;j++)
  for(float k = -0.5*b;k <=0.5*b;k++){
    c += texture(texPreviousFrame,uc+vec2(j,k)*d).a;
  }
  c /= 24.;
  float tr = step(0.7,fract(time*0.3));

  vec3 r1 = mix(vec3(1.),3.*abs(1.-2.*fract(c*0.4+mix(0.45,0.85,tr)+vec3(0.,-1./3.,1./3.)))-1.,mix(0.25,0.8,tr))*c;
  vec3 r2 = pow(r1,mix(vec3(0.55,0.8,0.7),vec3(1.2),length(uv.y)));
  
	out_color =vec4(r2,r0);
}