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


vec3 pal( in float t)
{
    vec3 a = vec3(0.500, 0.500, 0.500); 
    vec3 b = vec3(-0.692, 0.500, 0.500);
    vec3 c = vec3(1.058, 1.000, 1.000);
    vec3 d = vec3(0.078, 0.333, 0.667); 
    return a + b*cos( 6.28318*(c*t+d) );
  
}



float circle(in vec2 _st, in float _radius){
    vec2 dist = _st-vec2(0.5);
    return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

vec2 pMod2(inout vec2 p, vec2 size) {
    vec2 c = floor((p + size*0.5)/size);
    p = mod(p + size*0.5,size) - size*0.5;
    return c;
}

vec4 plas( vec2 v, float time )
{
    float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
    return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

//iq triangle 
float sdEquilateralTriangle(  in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p=vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

#define PI 3.14159265359
#define TWO_PI 6.28318530718

float getTriangle(vec2 p, vec2 rp){
   // p *= vec2(v2Resolution.x, v2Resolution.y);
   // p /= max(v2Resolution.x, v2Resolution.y);
    
    p -= rp;

    vec3 color = vec3(0.0);
    float d = 0.0;

    // Remap the space to -1. to 1.
    p = p *2.-1.;

    // Number of sides of your shape
    int N = 3;

    // Angle and radius from the current pixel
    float a = atan(p.x,p.y)+PI;
    float r = TWO_PI/float(N);

    // Shaping function that modulate the distance
    d = cos(floor(.5+a/r)*r-a)*length(p);

    return 1.0-step(.12,d);
}

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

void main(void)
{
  float time = fGlobalTime;
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
    //uv -= 0.5;
    //uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv = uv * (15.5*sin(time/3.));//+sin(time)*.5;
  uv += time;
  
  vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float q = m.y;

	float f = texture( texFFT, q ).r * 100;
  
  
  pMod2(uv,vec2(5.,3.));
  vec2 triuv = uv*.5+2.;
  triuv.x = triuv.x-.319;
  triuv.y = triuv.y-.4;
  triuv*0.5+triuv.x;
  pR(triuv,sin(time/2.));
  vec3 tri = vec3(getTriangle(triuv,vec2(1.,1.))); 
  vec2 cuv = uv; 
  cuv.y = cuv.y-sin(f/(20.-cuv.y)); 
  cuv.x = cuv.x + sin(cuv.x+(time+cuv.y)/5.); 
  vec3 circ = vec3(circle(cuv,0.8+(sin(f)/20.)));
  vec3 circ2 = vec3(circle(uv+0.5,0.5+(sin(f)/10.))); 
  vec2 c3uv = uv; 
  c3uv= uv-0.5;
  c3uv.x = c3uv.x+sin(time/10.); 
  c3uv.y = c3uv.y+sin(f/20.);  
  vec3 circ3 = vec3(circle(c3uv,0.9+(sin(f)/10.)));
  vec2 c4uv = uv; 
  c4uv= uv+0.5;
  c4uv.y = c3uv.y-sin(c4uv.x+f/30.);  
  vec3 circ4 = vec3(circle(c4uv,.3+(sin(f)/20.)));
  float d = length(uv)*sin(uv.y*2.)*.5; 
  vec3 tint2 = pal(d); 
  
  vec2 c5uv = uv; 
  pR(c5uv,sin(time+c5uv.y/2.+(f/50.))); 
  vec3 circ5 = vec3(circle(c5uv,2.+(sin(f)/20.)));
  
  vec2 c6uv = uv; 
  pR(c5uv,sin(time/2.+(f/50.))); 
  c6uv.y = c6uv.y+sin(time); 
  vec3 circ6 = vec3(circle(c6uv,.5+(sin(f)/10.)));
  
  d = sin(d*8. + time)/8.; 
  d = abs(d);
  d = 0.02/d;  
  vec3 tint = vec3(1.,0.,0.); 
  tint *= d; 
  tint2 *=d;
  
  
  
    vec3 shape = max(circ6,max(circ5,max(circ4,max(circ3,max(circ2,max(circ,tri))))));
  
    vec3 color = tint2*shape;
  
    out_color = vec4(color,1.); 
}