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
    p.y += 0.5;
    q = (1. + p) * 0.5;
    // Draw frequency bars
    if (abs(p.x) < 1.5 - ZZ * 3.) {
        float 
            x = q.x
          , n = round(x / ZZ) * ZZ
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
        float X = abs(c.y);
        c.y = abs(c.y) - f * 0.3;
        
        col = mix(
            col
//        , (1. + sin(-t + abs(p.y) + 2. * p.x + vec3(0, 1, 2))) * (1.25 + sign(p.y))
        , col/8.
        , smoothstep(aa, -aa, segmenty(c) - ZZ * 0.4)
        );

col = mix(
            col
        ,   vec3(X*10.)
        , smoothstep(aa, -aa, abs(segmenty(c) - ZZ * 0.4)-aa*1.)
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

vec3 plane(vec2 p) {
  const float ZZ =.25;
  vec2 
    n = round(p/ZZ)*ZZ
  , c = p -n
  ;
  
  float 
    d
  , h
  , x
  , f
  ;
  h = hash(n+123.4);
  
  x = clamp(h * 0.5 + 0.0, 0., 1.);
  f = texture(texFFTSmoothed, x).x;
  x += 1./16.;
  f *= f * x * x * 3e4;
  f = log2(f) / 10. + 0.33;
  f = tanh(3.*f);
  
  c*=c;
  c*=c;
  d = pow(dot(c,c),.125)-.45*ZZ*f;
  
  vec3 col;
  
  if (d < 0.) {
    col += 1.+sin(iTime+4.*p.x+2.*h+vec3(0,1,2));
  }
  
  
  return col;
}

vec3 effect0(vec2 C) {
  float i,d,z,e;
  vec3 o,p;
  for(vec2 r=iResolution.xy;++i<99.;z+=.7*d) {
    p = z*normalize(vec3(C-.5*r,r.y));
    p.z += 1.5*iTime;
    mat2 R = mat2(cos(0.2*iTime+.5*p.z+vec4(0,11,33,0)));
    p.xy *= R;
    p.x = abs(p.x);
    d = abs(p.x-1+.5*sin(.6*p.z))-.1+.0*sin(10.*p.z+3.*iTime);
    if (i==98.) {
      o += 3.;
      break;
    }
    if (d < 1e-3) {
      o += plane(p.yz);
      o += pow(i/99.,2.)*vec3(1,2,3)*vec3(1,2,3);
      
      break;
    }
  }
  o *= exp(-z/1e1);
  o += (1.-exp(-z*z/1e3))*vec3(3,1,1);
  return o;
}

mat2 R;
float df(vec3 p) {
  p.z -= 4.;
  p.xz *= R;
  p.xy *= R;
  p *= p;
  return pow(dot(p,p),.25)-1.3;
}

vec3 normal(vec3 p) {
  vec2 e = vec2(1e-3,0);
  return normalize(vec3(
    df(p+e.xyy)-df(p-e.xyy)
  , df(p+e.yxy)-df(p-e.yxy)
  , df(p+e.yyx)-df(p-e.yyx)
  ));
}

vec3 effect1(vec2 C) {
  float i,d,z,e;
  vec2 q,r=iResolution.xy;
  vec3 o,p,n,Z,I=normalize(vec3(C-.5*r,r.y));
  R = mat2(cos(0.3*iTime+vec4(0,11,33,0)));
  for(;++i<77.;z+=d) {
    p = z*I;
    d = df(p);
    if (d <1e-3) {
      n = normal(p);
      Z = reflect(I,n);
      o+= pow(.5+.5*n.y,6)*vec3(1,2,3)*vec3(1,2,3)/9.;
      o += pow(max(0,dot(Z,normalize(vec3(1,1,.7)))),30.);
      

      n.xz *= R;
      n.xy *= R;

      q = n.x*p.yz+n.y*p.xz+n.z*p.xy;
      o += plane(q*2+iTime);
      
      
      break;
    }
  }
  return o;
}

void mainImage(out vec4 O, vec2 C) {
  const float BPM=120.;
  float N = mod(floor(iTime*BPM/(60.*32.)),2);
  vec2 
    r=iResolution.xy
  , p=(2.*C-r)/r.y
  ;
  
  if (N == 0.) {
    O = effect0(C).xyzx;
  } else {
    O = effect1(C).xyzx;
  }
  O *= O;
  O.xyz = bars(O.xyz);
}