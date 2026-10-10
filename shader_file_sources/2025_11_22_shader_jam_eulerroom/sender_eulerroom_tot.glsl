#version 420 core

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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
#define PI 3.141592

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}
float circle(vec2 uv,float s){
    return length(uv)-s;
  }
float box(vec2 p,vec2 b){p=abs(p)-b;return length(max(vec2(0),p))+min(0.,max(p.x,p.y));}

vec3 hash3d(vec3 p){
     uvec3 q= floatBitsToUint(p);
    q += ((q>>16u)^q.yzx)*1111111111u;
    q += ((q>>16u)^q.yzx)*1111111111u;
    q += ((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
  }
float triangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}
float diam(vec2 p,float s){p=abs(p);return (p.x+p.y-s)*inversesqrt(3);}
float bpm = fGlobalTime*142/60;
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  uv*=5.;
  vec3 col = vec3(0.);

  uv *=rot(bpm*.125);
  uv.xy += bpm*.5+ (hash3d(vec3(floor(bpm),-1U,123456)).xy-.5)*2*exp(-3*fract(bpm));
  vec2 id = floor(uv);
  vec3 rnd = hash3d(vec3(id,-1U));
  
  if(rnd.z <.5){
       uv*=2.;
        id = floor(uv);
    rnd = hash3d(vec3(id,-1U));
    }
  uv = uv-id-.5;
  uv *= 1-exp(-3*fract(bpm*.5+rnd.x));
  float d = rnd.x<rnd.y ? circle(uv,.25): (rnd.y<rnd.z? triangle(uv,.25):box(uv,vec2(.25)));
  
  float f=(texture(texFFTIntegrated,mix(.01,.5,fract(length(rnd)))).r);
  f= .01+exp(-6*fract(f*4))*.5;
  d = f/(f+abs(d));
  col = vec3(1.)*d;
    if(rnd.x<.5){
        col = mix(vec3(0),vec3(1,0,0),col);
      } else if(rnd.y<.5) {
            col = mix(vec3(0,.5,0),vec3(0,.0,0),col);
        }
        
        ivec2 gl = ivec2(gl_FragCoord.xy);
   vec3 pcol = vec3(
          texelFetch(texPreviousFrame,gl,0).r,
        
          texelFetch(texPreviousFrame,gl,0).g,
        
          texelFetch(texPreviousFrame,gl,0).b
        );     
        
        col = mix(col,pcol,.5);

    
  
	out_color = vec4(col,1.);
}