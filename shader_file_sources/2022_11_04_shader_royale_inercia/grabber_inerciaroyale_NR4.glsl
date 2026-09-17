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

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float sm(float d) {
    return smoothstep(1.5/v2Resolution.y, -1.5/v2Resolution.y, d);
}

float pi = 3.14159;
vec3 c = vec3(1.,0.,-1.);
// To be honest, I'm really out of ideas :)
// greetings to Team210 <3

vec2 add(vec2 a, vec2 b) {
  if(a.x<b.x)return a;
  return b;
}

vec2 scene(vec3 x) {
    float de = fGlobalTime;
    mat2 m = mat2(cos(de), sin(de), -sin(de), cos(de));
  x.xy *= m;
  
    if(mod(floor(fGlobalTime), 2.) == 0.)x = abs(x)-.1;
    float a = mod(x.z,.3)-.05,
      aj = x.z-a;
    float e = 3.-3.*sin(fGlobalTime);
    float d = (length(vec3(x.xy, a)-.3*vec3(sin(fGlobalTime+pi/3.*e*aj), cos(fGlobalTime+pi/3.*e*aj), 0.))-.1+.03*sin(x.z));
  vec2 sdf = vec2(d, 0.);
  sdf = add(sdf, vec2(length(x.xy-.5*vec2(.1*cos(x.z*2.*pi), .2*sin(x.z*2.*pi))-.1*vec2(cos(x.z*2.*pi*2.), sin(x.z*2.*pi*1.)))-.005, 1.));
  
  return sdf;
}

vec3 normal(vec3 x) {
  float dx = 1.e-4;
  return normalize(vec3(scene(x+dx*c.xyy).x, scene(x+dx*c.yxy).x, scene(x+dx*c.yyx).x) - scene(x).x);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
  
  
  
  vec3 o = vec3(0.,0.,1.),
    tt = vec3(0.,0.,0.),
    r = vec3(1.,0.,0.),
    u = vec3(0.,1.,0.),
    dir = normalize(tt-o)+uv.x*r+uv.y*u,
    col = vec3(0.),
    x;
    
    vec2 s;
    float rd = 0.;
    
   for(float d = 0.; d < 50.; d += 1.e-2) {
     x = o + d * dir;
     float p = atan(x.y,x.x);
     
     float da = abs(length(x.xy-.1*vec2(cos(fGlobalTime), sin(fGlobalTime))-.1*sin(x.z*2.*pi)-.05*(.5+.5*cos(p*2.*pi*1.)))-.5-.25*sin(x.z*2.*pi-3.*fGlobalTime)-.1*sin(x.z*2.*pi*1.3))-.001;
     
     float db = abs(dot(x.xy-.3*c.xy, .3*c.yz-.3*c.yx)/pow(length(.3*c.yz-.3*c.yx),2.))-.001;
//     col = mix(col, vec3(.1,.6,.7), sm(da-.001));
     col = mix(col, mix(
      vec3(.9, .35, .05),
      vec3(.9,.05,.1),
      .5+.5*sin(x.z)
     ), sm(da/mix(5., 1., .5+.5*cos(fGlobalTime))));
     col = mix(col, vec3(.4,.07,.3), sm(db*100.));
     
     s = scene(x);
     rd += s.x;
     if(s.x<1.e-3) {
       vec3 n = normal(x);
       if(s.y == 0.) {
       col = .2*c.yyx + .3*c.xyy*dot(c.yzx, n) + .5*vec3(.4,.2,.15)*dot(reflect(c.yzx-x, n), dir);
       }
       else {
         col = .2*c.xyy + .3*c.xyy*dot(c.yzx, n) + .5*vec3(.4,.2,.15)*dot(reflect(c.yzx-x, n), dir);
       }
       break;
     }
   }
   col = mix(col, length(col)/sqrt(3.)*c.xxx, .2);
   out_color = vec4(clamp(col, 0., 1.), 1.);
   
}