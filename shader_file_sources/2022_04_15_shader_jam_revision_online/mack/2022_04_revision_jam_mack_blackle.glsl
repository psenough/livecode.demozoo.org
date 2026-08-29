#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texDfox;
uniform sampler2D texNoise;
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 plane(vec3 cam, vec3 ini, vec3 o, vec3 n, vec3 tn) {
  float t = dot(o-ini, n)/dot(n,cam);
  vec3 p = (cam*t+ini)-o;
  vec3 l1 = normalize(cross(n,tn));
  vec3 l2 = normalize(cross(n,l1));
  return vec3(dot(p,l1),dot(p,l2),t);
}

#define ro(r) mat2(cos(r),sin(r),-sin(r),cos(r))
float bpm = 145;
float mul = 6*60/bpm;
float linedist(vec2 p, vec2 a, vec2 b) {
  float k = dot(p-a,b-a)/dot(b-a,b-a);
  return distance(p,mix(a,b,clamp(k,0,1)));
}


float love(vec2 p) {
  //p.x=abs(p.x);
  p.x = sqrt(p.x*p.x+.001);
  p.y+=.1;
  return linedist(p,vec2(.2,.2),vec2(-0.2,-.2))-.2;
}

vec4 tex(vec2 crds, int i) {
  float pulse = fGlobalTime - floor(fGlobalTime*mul)/mul;
  if(i%3==0)crds *= ro(fGlobalTime);
  crds.x+=.5;
  crds*=.6+pulse*.5;
  if(abs(crds.y)>.5||abs(crds.x)>.5)return vec4(0);
  if(i%6==0) return texture(texTex1,crds+.5);
  if(i%6==2) return texture(texTex3,crds+.5);
  if(i%6==3) return texture(texTex4,crds+.5);
  if(i%6==4) return texture(texChecker,crds+.5);
  if (length(crds)>.5)return vec4(0);
  if(i%6==1) return texture(texRevision,crds+.5).xyzy;
  //float d = linedist()
  if (length(crds-vec2(.7,-.2))<.5)return vec4(0);
  if (length(crds-vec2(-.7,-.2))<.5)return vec4(0);
  if (length(crds-vec2(-.4,-.7))<.5)return vec4(0);
  if (length(crds-vec2(.2,-.85))<.5)return vec4(0);
  return texture(texDfox,crds+.5)*2.;
}

vec3 curve(float k) {
  float t = fGlobalTime/9 + k;
  float w = 1 + sin(floor(fGlobalTime)*45)*.3;
  return vec3(sin(t*w),cos(t*9),sin(t*2.5))*4;
}

vec2 delt(vec2 p) {
  mat2 k = mat2(p,p)-mat2(0.001);
  return normalize(love(p) - vec2(love(k[0]),love(k[1])));
}

void main(void)
{
  vec4 last = texture(texPreviousFrame,gl_FragCoord.xy/v2Resolution.xy);
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec3 cam = normalize(vec3(1,uv));
  vec3 init = vec3(-3,0,0);
  
  vec4 col = vec4(0);
  float mt = 1e4;
  for (int i = 0; i < 200; i++) {
    vec3 org = curve(float(i)*3.14159/100);
    vec3 hit = plane(cam, init, org, normalize(-org), normalize(vec3(cos(vec2(-org.z,org.x)),0)));
    if (hit.z > .8 && hit.z < mt) {
      vec4 tx = tex(hit.xy,i);
      if (tx.w > 0.5) { 
        col = tx;
        
      mt = hit.z;
      }
    }
  }
  
	out_color = (mt>0.)?col:vec4(0);
  //out_color = mix(out_color ,last,sin(fGlobalTime)*.4+.5);
  out_color = mix(out_color, last*.9, 1-clamp(out_color.w,0,1));
  //out_color = mix(out_color ,last,sin(fGlobalTime)*.4+.5);
  
  float sx = floor(gl_FragCoord.x/v2Resolution.x*30)/30;
  sx = abs(sx-.5)*2;
  if (gl_FragCoord.y/v2Resolution.y < texture(texFFT,sx).x*50) out_color=vec4(1);
  
  float pulse = fGlobalTime - floor(fGlobalTime*mul)/mul;
  uv *= ro(cos(fGlobalTime*mul*3.1415)*.3);
  uv.y += cos(fGlobalTime/2*mul)*.1;
  uv.x += sin(fGlobalTime/2*mul)*.1;
  uv *= (1+pulse);
  float lv = love(uv);
  float edge = smoothstep(0.,-.1,lv);
  vec3 n = normalize(vec3(1*edge,delt(uv)*(1-edge)));
  vec3 r = reflect(cam,n);
  float spec=  length(sin(n*4)*.5+.5)/sqrt(3.);
  if (lv<0.)out_color.xyz=vec3(.9,.1,.1)+pow(spec,10)*3;
  
}


// gotta go have easter dinner with the family here in EDT land
// see you all at the compos tomorrow morning!
// make sure to tune in for 4k exegfx!























