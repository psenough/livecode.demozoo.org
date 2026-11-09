#version 410 core

const float MAXDIST = 20.;
const float EPSILON = 0.001;
const float PI = acos(-1.);

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

float dot2( in vec2 v ) { return dot(v,v); }

float remap_simple(float a, float b, float v)
{
    return clamp((v-a)/(b-a), 0., 1.);
}
 
float remap(float a, float b, float c, float d, float v)
{
    return (d-c)*remap_simple(a,b,v) + c;
}

mat2 rotation(float angle)
{
float c = cos(angle), s = sin(angle);
return mat2(c, s, -s, c);
}

float sdHeart( in vec2 p )
{
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}

float opExtrusion( in vec3 p, in float h )
{
    float d = sdHeart(p.xy);
    vec2 w = vec2( d, abs(p.z) - h );
    return min(max(w.x,w.y),0.0) + length(max(w,0.0));
}

float sdSphere(vec3 p, float radius)
{
  return length(p) - radius;
}
float sdScene(vec3 p)
{
  
   vec3 q = p;
  q.xz *= rotation(fGlobalTime);
 // q.x += 1.;
  //q.y += -1.;
  float size = remap(-1., 1., 0., 0.5, fGlobalTime);
  p.y +=0.5;
  p.xz *= rotation(fGlobalTime*5.);
  
  q = fract(q)-0.5;
 
  float sphere = sdSphere(q, sin(fGlobalTime)*0.1 +0.2);
  
  
  float heart = opExtrusion(p, sin(fGlobalTime*5.)*0.2+0.5) * size;
  

  return min(sphere, heart); 
}
  

vec3 normal(vec3 p) 
{
    vec2 e = EPSILON * vec2(1., -1.);
#define q(s) s * sdScene(s + p)
    return normalize(q(e.xyy) + q(e.yxy) 
                    + q(e.yyx) + q(e.xxx));
}

vec3 render(vec2 uv)
{
vec3 c = vec3(1.); //background 

vec3 ro = vec3(0., 0., -3.); // point de l'oeil
vec3 rd = normalize(vec3(uv,1.));
vec3 p = ro;
float td = 0.;
bool hit = false;

for(int i = 0; i < 128; i++)
{
float d = sdScene(p);
if (d < EPSILON)
    {
        hit = true;
        break;
    }
    if (td > MAXDIST) {
        break;
    }
    p += rd * d;
    td += d;
}

if(hit) 
{

vec3 lo = vec3(0., 0., -3.);
vec3 ld = normalize(lo - p);
vec3 n = normal(p);
float shade = max(dot(ld, n), 0.);
c = shade * vec3(0.9, sin(fGlobalTime), fGlobalTime); //scene color
}

return c;
}







void main(void)
{
  
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
  
  
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 c = render(uv);
  
	out_color = vec4(c, 1.);
}