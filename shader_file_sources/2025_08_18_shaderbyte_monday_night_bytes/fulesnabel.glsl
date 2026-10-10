// -----------------------------------------------------------------------------
#version 430 core
// -----------------------------------------------------------------------------

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

#define iTime fGlobalTime
#define iResolution vec3(v2Resolution,1)

// -----------------------------------------------------------------------------

float hash(float co) {
  return fract(sin(co*12.9898) * 13758.5453);
}

float hash(vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,58.233))) * 13758.5453);
}

float hash(vec3 r)  {
  return fract(sin(dot(r.xy,vec2(1.38984*sin(r.z),1.13233*cos(r.z))))*653758.5453);
}

float segmenty(vec2 p) {
  float 
      d0 = length(p)
    , d1 = abs(p.x)
  ;
  return p.y > 0. ? d0 : d1;
}

vec3 bars(vec3 col) {
    col = mix(col,vec3(0), isnan(col));
    const float ZZ = 0.025;
    vec2 
        r = v2Resolution
      , C = gl_FragCoord.xy
      , p = (C + C - r) / r.y
      , q
      ;
    float 
        t   = fGlobalTime
      , aa  = sqrt(2.) / r.y
     
      ;
    p.y += 0.6;
    q = (1. + p) * 0.5;
    // Draw frequency bars
    if (abs(p.x) < 1.5 - ZZ * 3.) {
        float 
            x = q.x
          , n = round(x / ZZ) * ZZ
          , X
          ;
        vec2 c = q;
        c.x -= n;
        x = n;
        
        x = clamp(x * 0.5 + 0.125, 0., 1.);
        float f = texture(texFFTSmoothed, x).x;
        x += 1./16.;
        f *= f * x * x * 3e4;
        f = log2(f) / 10. + 0.6;
        
        c.y -= 0.5;
        X = abs(c.y);
        c.y = abs(c.y) - f * 0.2;
        
        
        col = mix(
            col
        ,   vec3(0)
        , smoothstep(aa, -aa, segmenty(c) - ZZ * 0.4-aa*2.)
        );
        col = mix(
            col
        , vec3(10.*X)
        , smoothstep(aa, -aa, segmenty(c) - ZZ * 0.4)
        );
    }
    
    // Horizontal line at y=0
    if (abs(p.y) < 2. * aa) {
        col = vec3(2);
    }
    
    // Bottom half tint
    if (p.y < 0.) {
        col += -0.01 * vec3(1, 3, 21) * p.y;
    }
    
    // Final color processing
    col = sqrt(tanh(col));
    
    return col;
}

void mainImage(out vec4 O, vec2 C);


void main(void) {
  vec4 O=vec4(1);
  mainImage(O, gl_FragCoord.xy);
  O.w = 1.;
  out_color = O;
  
}

// -----------------------------------------------------------------------------
const float PI=acos(-1.),TAU=2.*PI;
const vec2 PathA=vec2(1,sqrt(.5))/9.,PathB=vec2(4);

// I did cheat a bit and copied some code :). I can't code a smooth kaleidoscope at the drop of my hat (is that the expression?)

vec4 alphaBlend(vec4 back, vec4 front) {
  float w = front.w + back.w*(1.0-front.w);
  vec3 xyz = (front.xyz*front.w + back.xyz*back.w*(1.0-front.w))/w;
  return w > 0.0 ? vec4(xyz, w) : vec4(0.0);
}

float pmin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

float pmax(float a, float b, float k) {
  return -pmin(-a, -b, k);
}


float pabs(float a, float k) {
  return pmax(a, -a, k);
}
vec2 toPolar(vec2 p) {
  return vec2(length(p), atan(p.y, p.x));
}

vec2 toRect(vec2 p) {
  return vec2(p.x*cos(p.y), p.x*sin(p.y));
}
float modMirror1(inout float p, float size) {
  float halfsize = size*0.5;
  float c = floor((p + halfsize)/size);
  p = mod(p + halfsize,size) - halfsize;
  p *= mod(c, 2.0)*2.0 - 1.0;
  return c;
}

float smoothKaleidoscope(inout vec2 p, float sm, float rep) {
  vec2 hp = p;

  vec2 hpp = toPolar(hp);
  float rn = modMirror1(hpp.y, TAU/rep);

  float sa = PI/rep - pabs(PI/rep - abs(hpp.y), sm);
  hpp.y = sign(hpp.y)*(sa);

  hp = toRect(hpp);

  p = hp;

  return rn;
}

// From here it's honest coding!

vec3 path(float z) {
  return vec3(PathB*sin(PathA*z),z);
}

vec3 dpath(float z) {
  return vec3(PathB*PathA*cos(PathA*z),1);
}

vec3 ddpath(float z) {
  return vec3(-PathB*PathA*PathA*sin(PathA*z),0);
}

float length4(vec2 p) {
  return sqrt(length(p*p));
}

float T,F,B;

vec4 plane(vec3 p) {
  vec4 R;
  
  float
    d
  , d0
  , d1
  , d2
  , D
  , a
  , W
  , Z
  , n
  , H0
  , H1
  , r
  , Q
  ;
  
  vec3
    N
  , C
  ;
  
  Q=dot(p.xy,p.xy);
  n=round(p.z);
  H0=hash(n);
  Z=mix(.25,2.,H0);
  r=2.*round(mix(5.,20.,fract(3667.*H0)));
  W=.05;
  p.xy *= mat2(cos(6.*ddpath(n).x+vec4(0,11,33,0)));
  a = length(fwidth(p.xy));
  d0=length4(p.xy)-.5;
  d=d0;
  D=d0+W;

  smoothKaleidoscope(p.xy, 1./r, r);
  p.xy *= mat2(cos(.2*B*(-1.+2.*fract(8667.*H0))+vec4(0,11,33,0)));
  p.xy += B*.5*fract(7667.*H0);
  
  N=round(p/Z)*Z;
  H1=hash(N);
  C=p-N;
  if(H1<.5) {
    C.xy=C.yx*vec2(1,-1);
  }
  
  d1=abs(min(length4(C.xy-.5*Z),length(C.xy+.5*Z))-.5*Z)-W*Z;
  d2=length4(abs(C.xy)-.5*Z)-6.*W*Z;
  d=min(d,d1);
  d=min(d,d2);
  D=min(D,d2+W*Z);
  R.xyz = 
    mix(
      (1.+sin(.4*n+vec3(0,5,2)))
      /Q/Q/10.
      *smoothstep(-2.,.5,sin(200.*sqrt(Q)))
    , vec3(0)
    , smoothstep(a,-a, d)
  );
  R.w = smoothstep(a,-a, -D);
  
  return R;
}

void mainImage(out vec4 o, vec2 C) {
  const float BPM=135.;
  T=iTime*BPM/60.;
  F=sqrt(fract(T));
  B=floor(T)+F;
  float 
    z=B
  , i
  ;
  vec2 
    r=iResolution.xy
  , p=(2.*C-r)/r.y
  , s=sin(29.*p)
  ;
  
  
  vec3
    O=path(z)
  , S=normalize(path(z+10.)-O)
  , Z=normalize(dpath(z))
  , X=normalize(cross(vec3(0,1,0)-3.*ddpath(z),Z))
  , Y=cross(X,Z)
  , I=normalize(p.x*X+p.y*Y+(2.+(.5+.5*s.x*s.y)*smoothstep(.5, 1.5, length(p)))*Z)
  , P
  ;
  
  
  vec4 R;
  
  z=fract(-z)/I.z;
  for(
    o-=o
  ; ++i<12
  ; z+=1./I.z
  ) {
    P=O+z*I;
    P.xy -= path(P.z).xy;
    R=plane(P);
    R.w*=smoothstep(11.,7.,z);
    o=alphaBlend(R,o);
  }
//  o-=o;
  o.w *= .7;
  R.w=1.;
  R.xyz = (1.-F)*1e-3*vec3(40,1,6)/(1.0001-dot(S,I));
  
  o=alphaBlend(R,o);
  o.xyz *= o.w;
  
  o.xyz = bars(o.xyz);
}