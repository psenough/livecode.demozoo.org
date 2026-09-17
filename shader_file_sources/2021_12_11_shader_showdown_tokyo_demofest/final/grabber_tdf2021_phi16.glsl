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
vec2 res = v2Resolution;

float rand(vec2 p) {
  return fract(sin(dot(p,vec2(1,1.001)))*10000);
}

float map(vec3 o) {
  if(distance(o, vec3(time*2,20,time*4)) < 10) return 0;
  ivec3 cd = ivec3(o.zxy);
  if(cd.z < 0) return 1;
  if(cd.z > 63) cd.z = 63;
    int cdz = cd.z-1;
    ivec2 tc = cd.xy + ivec2(cdz%8,cdz/8)*64;
 return texture(texPreviousFrame, (tc+0.5)/res).a;
}

bool cast(vec3 o, vec3 d, out vec3 ii, out vec3 ir, out vec3 tw, out float e) {
  vec3 u = floor(o);
  vec3 s = sign(d);
  d = abs(d);
  vec3 r = (o-u-0.5)*s+0.5;
  for(int i=0;i<100;i++) {
    float t = map(u);
    if(t > 0.) {
      e = t;
      ii = u;
      ir = (r-0.5)*s;
      return true;
    }
    vec3 l = (1-r)/d;
    vec3 m = step(l,l.yzx) * step(l,l.zxy);
    tw = -s*m;
    r += d*length(l*m) - m;
    u += s*m;
  }
  return false;
}
bool cast2(vec3 o, vec3 d, out vec3 ii, out vec3 ir, out vec3 tw, out float e) {
  vec3 u = floor(o);
  vec3 s = sign(d);
  d = abs(d);
  vec3 r = (o-u-0.5)*s+0.5;
  for(int i=0;i<40;i++) {
    float t = map(u);
    if(t > 0.) {
      e = t;
      ii = u;
      ir = (r-0.5)*s;
      return true;
    }
    vec3 l = (1-r)/d;
    vec3 m = step(l,l.yzx) * step(l,l.zxy);
    tw = -s*m;
    r += d*length(l*m) - m;
    u += s*m;
  }
  return false;
}


void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 ouv = uv;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 c = vec3(0.);
  vec3 o = vec3(time*2,20,time*4);
  vec3 d = vec3(uv,1);
  float ga = 0.0;
  d.xz *= mat2(cos(ga),-sin(ga),sin(ga),cos(ga));
  ga = 0.2;
  d.yz *= mat2(cos(ga),-sin(ga),sin(ga),cos(ga));
  vec3 ii,ir,tw;
  float e;
  if(cast(o,d,ii,ir,tw,e)) {
    vec3 pos = ii+ir+0.5;
    c = vec3(1.);
    if(e > 0.5) { 
      
      vec3 normal = tw;
        vec3 refl = reflect(normalize(pos-o),normal);
      vec3 s = vec3(0);
      for(int i=0;i<16;i++) {
        float ra = rand(uv*1000+time+1+i*0.5)*6;
        float rr = rand(uv*1000+time+2+i*0.9)*3;
        vec3 rc = vec3(sin(ra)*cos(rr), cos(ra)*cos(rr), sin(rr));
        vec3 sph = dot(rc,normal) < 0 ? -rc:rc;
        refl = mix(refl, sph, 0.5);
        if(cast2(pos-d*0.01, refl, ii,ir,tw,e)) {
          if(e < 0.5) s += (cos(vec3(0,1,-1)*2/3*3.1415926535+ii.x*0.25)*0.5+0.5)*3;
        }
      }
      s /= 16.;
      c = s;
    }
  }
  
  float a = texture(texPreviousFrame, ouv).a;
  ivec3 cd = ivec3(gl_FragCoord.xy, 0);
  cd.z = cd.x/64 + cd.y/64*8;
  
  cd.xy %= 64;
  if(fract(time) < 0.5) {
    if(cd.z == 0) {
      int count = 0;
      for(int i=0;i<9;i++) {
        if(i == 4) continue;
        ivec2 d = ivec2(i/3-1,i%3-1);
        count += texture(texPreviousFrame, ouv+d/res).a > 0.5 ? 1 : 0;
      }
      if(a > 0.5 && 2 <= count && count <= 3)a = 1;
      else if(a < 0.5 && count == 3) a = 1;
      else a -= 0.75;
    } else {
      int cdz = cd.z-1;
      ivec2 tc = cd.xy + ivec2(cdz%8,cdz/8)*64;
      a = texture(texPreviousFrame, (tc+0.5)/res).a;
    }
    
    if(cd.z == 0 && length(cd.xy-31) < 2 && rand(uv*1000+time) < 0.5) a = 1;
  
  }
  
  vec3 bl = vec3(0.);
  for(int i=0;i<16;i++) {
    vec2 d = (vec2(rand(uv*1000+time+i),rand(uv*1001+time+i)) - 0.5) * 5;
    d = sign(d) * pow(abs(d),vec2(2)); 
    bl += texture(texPreviousFrame, ouv + d/res).rgb;
  }
  bl/=16;
  c = mix(c,bl,0.7);
  
  out_color = vec4(c,a);
  
}