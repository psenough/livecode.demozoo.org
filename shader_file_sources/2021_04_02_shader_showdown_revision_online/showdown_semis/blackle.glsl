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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float corner(vec2 p) {
  return length(max(p,0)) + min(0,max(p.x,p.y));
}

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(p,ax)*ax,p,cos(ro))+sin(ro)*cross(ax,p);
}

float scene(vec3 p) {
  p.yz += tan(asin(sin(vec2(fGlobalTime*3, fGlobalTime*2.5)))*.7)*.8;
  vec2 dir = sign(cos(vec2(fGlobalTime*3, fGlobalTime*2.5)));
  p.yz *= dir;
  p.yz *= -1;
  p = erot(p, vec3(1,0,0), radians(-45.));
  p.z = abs(p.z);
  p = erot(p, vec3(1,0,0), -abs(sin(fGlobalTime*5)));
  float wd = length(p.yz) - .3;
  wd = max(wd, .05- corner(p.yz*vec2(-1,1)));
  return corner(vec2(wd,abs(p.x)))-.05;
}

vec3 norm(vec3 p) {
  mat3 k = mat3(p,p,p) - mat3(0.001);
  return normalize(scene(p) - vec3(scene(k[0]),scene(k[1]),scene(k[2])));
}

float redo(float x) {
  return 1-x;
}
float undo(float x) {
  return 1-x;
}

float linedist(vec2 p, vec2 a, vec2 b) {
  float k = dot(p-a,b-a)/dot(b-a,b-a);
  return distance(p,mix(a,b,clamp(k,0,1)));
}

float zombiegost(vec2 p) {
  float bod = linedist(p, vec2(0,-.5), vec2(0,.5));
  
  float eyes = length(vec2(abs(p.x-.2)-.2, p.y))-.1;
  p.x = asin(sin(p.x*40+floor(fGlobalTime)*2))/40;
  float dt = dot(p, vec2(1));
  return max(-eyes,max(bod,dt));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 olduv = uv;
  vec2 pixelsize = 1/v2Resolution;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float kr = .055 + length(uv*2)*.02 - sin(fGlobalTime)*.02;
  float fr = .055;
  float da = 1.;
  float db = .1;
  vec4 past = texture(texPreviousFrame, olduv);
  past.z = undo(past.z );
  float scale = 3.5+sin(fGlobalTime*3);
  vec4 conv = vec4(0);
  for (int i = -1; i <= 1; i++) {
  for (int j = -1; j <= 1; j++) {
    vec4 smpl = texture(texPreviousFrame, olduv + vec2(i,j)*pixelsize*scale);
    smpl.z = undo(smpl.z);
    float coeff = (j == 0 && i == 0) ? -1 : ((i == 0 || j == 0 ) ? .2 : .05 );
    conv += coeff*smpl;
  }
  }
  float olda = past.z;
  float a = olda + (da*conv.z - olda*past.w*past.w + fr*(1-olda));
  float b = past.w + (db*conv.w + olda*past.w*past.w - (fr+kr)*past.w)*1.5;
  a = redo(a);
  out_color = vec4(0,a*.5,a,b);

  vec3 cam = normalize(vec3(1,uv));
  vec3 init = vec3(-4,0,0);
  vec3 p = init;
  bool hit = false;
  for (int i = 0; i < 100 && !hit; i++ ){
    float dist = scene(p);
    hit = dist*dist < 1e-6;
    p+= dist*cam;
  }
  vec3 n = norm(p);
  vec3 r = reflect(cam,n);
  float spec = length(sin(r*3)*.3+.7)/sqrt(3.);
  vec3 col = vec3(0.9,.7,.2)*spec + pow(spec,8);
  if (hit) {
    out_color = vec4(col, 1);
  }
  if (zombiegost(uv*-3 + vec2(asin(sin(fGlobalTime*2)), sin(fGlobalTime*2)*.5)) < .5) {
    out_color.r = 1;
  }
}