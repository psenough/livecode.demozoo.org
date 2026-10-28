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

// hiya! ~yx|Luna

// trans rights are human rights!

mat2 rot(float a)
{
  float c=cos(a),s=sin(a);
  return mat2(c,-s,s,c);
}

float sdBox(vec3 p, vec3 r)
{
  p=abs(p)-r;
  return max(max(p.x,p.y),p.z);
}

float sdf(vec3 p)
{
  //p.y += cos(p.x*.1)*30.*(cos(fGlobalTime)*.5+.5);
  //p.y = -abs(p.y);
  
  float d = p.y;
  d+=texture(texNoise,p.xz*.001).r*80.;
  d+=texture(texNoise,p.xz*.003).r*60.-5;
  
  // chunk error
  p.xz = mod(p.xz-128, 256)-vec2(128);
  d = max(d,-sdBox(p,vec3(8,100,8)));
  
  return d;
}

vec3 trace(vec3 cam, vec3 dir)
{
  #if 0
  float k=0;
  vec3 h=cam;
  for(int i=0;i<100;++i){
    k=sdf(h)*.4;
    if(abs(k)<.001)
      break;
    h+=k*dir;
  }
  float t=distance(cam,h);
  
  vec2 o=vec2(.01,0);
  vec3 n=normalize(vec3(
    sdf(h+o.xyy),
    sdf(h+o.yxy),
    sdf(h+o.yyx))-k);
  
  bool hit = abs(k)<.001;
  bvec3 m=bvec3(n);
  #else
  cam-=.5;
  ivec3 mp=ivec3(floor(cam));
  vec3 dd=abs(1/dir);
  ivec3 rs=ivec3(sign(dir));
  vec3 sd=(sign(dir)*(vec3(mp)-cam)+(sign(dir)*.5)+.5)*dd;
  bvec3 m;
  bool hit=false;
  for (int i=0;i<250;++i) {
    if(sdf(mp)<0.){hit=true;break;}
    m=lessThanEqual(sd.xyz,min(sd.yzx,sd.zxy));
    sd+=vec3(m)*dd;
    mp+=ivec3(vec3(m))*rs;
  }
  vec3 n=vec3(m)*-rs;
  float t=distance(mp,(cam));
  vec3 h = cam+dir*t;
  #endif
  
  float daynight = cos(fGlobalTime*.5)*.5+.5;
  daynight = smoothstep(0,1,daynight);
  daynight = smoothstep(0,1,daynight);
  daynight = smoothstep(0,1,daynight);
  
  vec3 sky = vec3(196,225,255)/255.;
  sky *= mix(vec3(.05,.1,.15),vec3(1),daynight);
  float cloudDist = (20.-cam.y)/dir.y;
  vec2 cloudPos = cam.xz + cloudDist*dir.xz;
  cloudPos *= .003;
  cloudPos=floor(cloudPos*64.)/64.;
  
  vec3 albedo = vec3(.5,1,.5);
  albedo.r+=texture(texNoise,h.xz*.005).r;
  vec2 uv;
  if(m.x) { uv = h.yz; }
  if(m.y) { uv = h.xz; }
  if(m.z) { uv = h.xy; }
  uv=fract(uv);
  if((m.x || m.z) && uv.y < .8) {
    albedo = vec3(.7,.6,.5);
  }
  
  // dirt texture
  float noise = texture(texNoise,floor(8.*fract(uv))/8.).r;
  albedo *= clamp(noise+.6,0,1);
  
  float waterHeight = -30.2;
  waterHeight += sin(fGlobalTime*.1)*5;
  
  // snow
  if (h.y > waterHeight && m.y)
    albedo = clamp(.7+vec3(noise),0,1);
  
  // sand
  /*albedo = mix(
    albedo,
    mix(vec3(1,.9,.8),vec3(.7,.6,.5),noise),
    step(.99,cos(fGlobalTime*.1)*.5+.5+h.y/-100)
  );*/
  
  float fog = pow(.99,max(t-50.,.0));
  float fog2 = pow(.999,cloudDist);
  
  float waterAlpha = 0;
  if (h.y < waterHeight)
    waterAlpha = .7;
  
  // lava
  if (texture(texNoise,floor(h.xz+100)*.003).r < .1)
    albedo = mix(vec3(1,.3,0),vec3(1,1,0),noise*1.5);
  
  if (!hit) {
    if(cloudDist>0.) {
      vec3 cloudcolor = step(.3,texture(texNoise,cloudPos).rrr);
      cloudcolor *= mix(.4,1.,daynight);
      sky = mix(sky,vec3(1),fog2*cloudcolor);
    }
    return sky;
  }

  vec3 color = (n.y*.25+.75)*albedo;
  color = mix(color,vec3(.1,.2,.6),waterAlpha);
  color *= mix(vec3(.2,.3,.4),vec3(1),daynight);
  return mix(sky,color,fog);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 cam = vec3(0,-5,0);
  vec3 dir = normalize(vec3(uv,1));
  
  cam.z += fGlobalTime*40.;
  dir.yz *= rot(.2);
  dir.xy *= rot(sin(fGlobalTime)*.04);
  dir.xz *= rot(cos(fGlobalTime)*-.04);
  
  dir.xz *= rot(137.*cos(floor(fGlobalTime*.6)));
  
  out_color.rgb = trace(cam,dir);
  //out_color.rgb = step(.5+texture(texNoise,gl_FragCoord.xy*.125).r-.25,vec3(dot(out_color.rgb,vec3(.2126,.7212,.0722))));
  
  // gray screen
  //out_color.rgb = vec3(sqrt(.5));
}