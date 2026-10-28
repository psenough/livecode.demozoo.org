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

vec2 ep = vec2(.00035, -.00035);

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

mat2 rot(float a) {
  float s=sin(a),c=cos(a);
  return mat2(c,-s,s,c);
}

float box(vec3 p, vec3 s) {
  p = abs(p) - s;
  return length(max(p,0.)) + min(0., max(max(p.x,p.y),p.z)); // right???
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

vec2 minX(vec2 a, vec2 b) {
  return a.x<b.x?a:b;
}

vec2 ferret(vec3 p, vec2 id) {
  // bounce
  float idHash = hash22(id).x;
  float fft = texture(texFFTSmoothed, 0.0).x;
  p.y -= smoothstep(.99, 1., sin(fGlobalTime + idHash * 30.14));
  p.y -= fft * idHash * 3.;
  
  if (idHash<.6)p.y+=3.;
  
  // body
  vec2 b = vec2(box(p, vec3(0,0,1)) - 1., 0);
  
  // tail
  b = minX(vec2(box(p - vec3(sin((p.z + fGlobalTime) * 2.) / 10.,0,2), vec3(0,0,1)) - .1,0), b);
  
  // eyez
  p.x = abs(p.x);
  b = minX(vec2(length(p - vec3(.3,.5,-1.5)) - .3, 1), b);
  
  // earz
  p -= vec3(.5,.6,-1.2);
  p.xy *= rot(1.7);
  b = minX(vec2(box(p, vec3(.3,.3,.1)), 2), b);

  
  return b;
}

vec2 sdf(vec3 p) {
  p.z += mod(fGlobalTime, 100.) * 4.;
  float s = 6.;
  vec2 id = round(p.xz/s);
  vec2  o = sign(p.xz-s*id); // neighbor offset direction

  vec2 d = vec2(1e20);
  for( int j=0; j<2; j++ )
  for( int i=0; i<2; i++ )
  {
    vec2 rid = id + vec2(i,j)*o;
    vec2 r = p.xz - s*rid;
    vec2 re = ferret(vec3(r.x,p.y,r.y), rid);
    if(d.x>re.x)d=re;
  }
  
  vec2 flo = vec2(p.y + (sin((p.x) * 4.)+sin(p.z*4.)) / 40., 2);
  d = minX(d, flo);


  return d;
}

vec2 march(vec3 ro, vec3 rd) {
  vec2 r = vec2(0);
  for (int i = 0; i < 256; i++) {
    vec3 p = ro+rd*r.x;
    vec2 z = sdf(p);
    r.x += z.x;
    r.y = z.y;
    
    if (r.x > 1000. || z.x < 0.0001)break;
  }
  
  return r;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(0,10,0);
  vec3 rd = normalize(vec3(uv.x,-.5,uv.y));
  rd.yz *= rot(-.3);
  
  vec2 rm = march(ro,rd);
  vec3 po = ro+rd*rm.x;
  vec3 no = normalize(ep.xyy * sdf(po + ep.xyy).x + ep.yyx * sdf(po + ep.yyx).x +
            ep.yxy * sdf(po + ep.yxy).x + ep.xxx * sdf(po + ep.xxx).x);
  
  vec3 col = vec3(0);
  
  if (rm.x<1000. && rm.y >= 0.) {
    vec3 alb = vec3(0x9b,0x7e,0x6e)/255.;
    if (rm.y == 1.) alb *= 0.;
    if (rm.y == 2.) alb = vec3(1);
    
    float dif = dot(no,normalize(vec3(1)));
   

    col = dif * alb;
  }

	vec4 t = vec4(col, 1);
	t = clamp( t, 0.0, 1.0 );
	out_color = t;
}