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

float time;
float bar;
float bpm = 130;

#define FK(k) floatBitsToInt(k*k/7)^floatBitsToInt(k)
float hash(float a, float b) {
  int x = FK(a), y = FK(b);
  return float((x*x-y)*(y*y+x)+x)/2.14e9;
}

vec3 rndcol(float hs) {
  float h = hash(hs, 420);
  if (h > .5) {
    return vec3(.9,.8,.4);
  }
  if (h > 0) {
    return vec3(.4,.8,.4);
  }
  if (h > -.5) {
    return vec3(.4,.8,.9);
  }
  return vec3(.9,.3,.8);
}

float super(vec2 p, float k) {
  return mix(length(p), sqrt(length(p*p)), k);
}

vec3 pattern(vec2 p, float hs) {
  vec2 op = p;
  if (hash(hs,399)<0) {
    p.y += asin(sin(p.x*40))/40;
  }
  if (hash(hs,342)<0) {
    p.y = abs(p.y)-.2;
  }
  if (hash(hs,934)<0) {
    p.y = -p.y;
  }
  if (p.y < 0) {
    return rndcol(hash(hs,453));
  }
  if (p.y > 0) {
    op = asin(sin(op*30))/30;
    if (hash(hs,666)<0 && super(op,hash(hs,777)*4-2) < .015) {
      return  rndcol(hash(hs,339));
    }
  }
  return vec3(1);
}

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(p,ax)*ax,p,cos(ro))+sin(ro)*cross(ax,p);
}
vec3 rndrot(vec3 p, float sd) {
  float h1 = hash(sd, 43432);
  float h2 = hash(sd, 34332);
  float h3 = hash(sd, 12356);
  return erot(p, normalize(tan(vec3(h1,h2,h3))), h1*100+fGlobalTime*2);
}

float linedist(vec2 p, vec2 a, vec2 b) {
  float k = dot(p-a,b-a)/dot(b-a,b-a);
  return distance(p,mix(a,b,clamp(k,0,1)));
}

float smiley;
float egg(vec3 p, bool chopp) {
  float eg = mix( linedist(vec2( sqrt(dot(p.xy,p.xy)+.2) -.1, p.z), vec2(-.3,.5), vec2(0,-.5)  )-.9,length(p)-1,.3 );
  eg = abs(eg+.01)-.02;
  if (chopp) {
    eg = max(eg, p.z);
  }
    smiley  = length(p+vec3(cos(time*9)*.2,sin(time*9)*.2,sin(time*4)*.5))-.4;
  return min(eg,smiley);
}

vec3 glob;
float idx;
float scene(vec3 p) {
  idx = round(p.y/3)*3;
  bool willchop = false;
  if (hash(bar,2313) < 0) {
    idx = 0;
    willchop = true;
  }
  p.y -= idx;
  if (hash(bar,1312) < 0) {
    p.x += sin(time*2+idx);
  } else {
    p.z += -abs(sin(time*3.1415+idx*.1))+.5;
  }
  p = rndrot(p, bar+idx*100);
  glob = p;
  return egg(p, willchop);
}

vec3 norm(vec3 p) {
  mat3 k = mat3(p,p,p) - mat3(0.001);
  return normalize(scene(p) - vec3( scene(k[0]),scene(k[1]),scene(k[2]) ));
}
//candy!
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  time = fract(fGlobalTime*bpm/120);
  bar = floor(fGlobalTime*bpm/120);
  vec2 uv2 = uv;
  
  if (hash(bar,7434) < 0) {
    uv2.y += sin(uv.x*8+time)*.05;
  }
  out_color.xyz = pattern(uv2,bar);
  
  
  vec3 cam = normalize(vec3(1,uv));
  vec3 init = vec3(-5,0,0);
  
  if (hash(bar,2341) < 0) {
    cam = erot(cam, vec3(0,1,0), radians(45));
    init = erot(init, vec3(0,1,0), radians(45));
  }
  
  vec3 p = init;
  bool hit = false;
  float dist;
  for (int i = 0; i < 100 && !hit; i++) {
    dist = scene(p);
    hit = dist*dist < 1e-6;
    p += dist*cam;
  }
  
  
  if (hit) {
    bool issmiley = smiley == dist;
    float rix = idx;
    vec3 loc = glob;
    vec3 n = norm(p);
    vec3 r = reflect(cam,n);
    float spec = length(sin(r*3)*.5+.5)/sqrt(3);
    float fres = 1 - abs(dot(cam,n))*.98;
    float diff = length(sin(n*2)*.3+.7)/sqrt(3);
    vec2 crds = vec2(atan(loc.x,loc.y)*.8,loc.z);
    vec3 dcol = pattern(crds/3, bar+2392+rix*100);
    if (issmiley) {
      dcol = rndcol(3485+bar);
    }
    vec3 col = dcol*diff + pow(spec,7)*fres;
    out_color.xyz = col;
  }
  
  out_color.xyz = sqrt(out_color.xyz);
}