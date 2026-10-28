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
uniform float midi01;
uniform float midi02;
uniform float midi03;
uniform float midi04;
uniform float midi05;
uniform float midi06;
uniform float midi07;
uniform float midi08;
uniform float midi09;
uniform float midi10;
uniform float midi11;
uniform float midi12;
uniform float midi13;
uniform float midi14;
uniform float midi15;
uniform float midi16;
uniform float midi17;
uniform float midi18;
uniform float midi19;
uniform float midi20;
uniform float midi21;
uniform float midi22;
uniform float midi23;
uniform float midi24;
uniform float midi25;
uniform float midi26;
uniform float midi27;
uniform float midi28;
uniform float midi29;
uniform float midi30;
uniform float midi31;
uniform float midi32;
uniform float midi33;
uniform float midi34;
uniform float midi35;
uniform float midi36;
uniform float midi37;
uniform float midi38;
uniform float midi39;
uniform float midi40;
uniform float midi41;
uniform float midi42;
uniform float midi43;
uniform float midi44;
uniform float midi45;
uniform float midi46;
uniform float midi47;
uniform float midi48;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fft;

struct Matter
{
    float m;
    int type;
    bool reflected;
    float glow;
    bool hit;
    vec3 posHit;
    float voroval;
};

struct Ray
{
    vec3 o;
    vec3 t;
    vec3 p;
    vec3 dir;
    float dist;
    vec3 hitloc;
};

struct Light
{
    vec3 liPos;
    vec3 liDir;
    float shad;
    float liGlow;
};

struct Res
{
    vec3 skyColor;
    vec3 fogGlow;
    vec3 glowCol;
    vec3 color;
};

Matter mat;
Ray ray;
Light li;
Res res;

#define BPM fGlobalTime/60.0 * 120.0

#define mod01 mod(floor(BPM*2.0), 4.0)
#define mod02 mod(floor(BPM*0.5), 4.0)
#define mod03 mod(floor(BPM*0.25), 4.0)

#define hash22(p)  fract( 18.5453 * sin( p * mat2(127.1,311.7,269.5,183.3)) )
//https://www.shadertoy.com/view/lsVyRy
float CRACK_zebra_scale = 10.0 * 0.15, // fractal shape of the fault zebra
      CRACK_zebra_amp = 5.0 * 0.6,
      CRACK_profile = .2,      // fault vertical shape  1.  .2 
      CRACK_slope = 1.4,       //                      10.  1.4
      CRACK_width = .0;

float animation()
{
    return 1.0 - pow(abs(sin(fGlobalTime*0.1)), 16.2) * 2.0;
}

vec3 opRepLim( in vec3 p, in float c, in vec3 l)
{
    return p-c*clamp(round(p/c),-l,l);
}

vec2 opRepLim( in vec2 p, in float c, in vec2 l)
{
    return p-c*clamp(round(p/c),-l,l);
}

float smin( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); }

mat2 rot(float a)
{
  float ca = cos(a);
  float sa = sin(a);

  return mat2(ca, sa, -sa, ca);
}

float sphere(vec3 p, float s)
{
    return length(p) - s;
}

float box(vec3 p, vec3 s)
{
    p = abs(p) - s;
    return max(p.x, max(p.y, p.z));
}

vec3 hash3( uvec3 x ) 
{
#   define scramble  x = ( (x>>8U) ^ x.yzx ) * 1103515245U // GLIB-C const
    scramble; scramble; scramble; 
    return vec3(x) / float(0xffffffffU) +1e-30; // <- eps to fix a windows/angle bug
}
int MOD = 1;  // type of Perlin noise
#define noise22(p) vec2(noise2(p),noise2(p+17.7))
#define hash21(p) fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123)
float noise2(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p); f = f*f*(3.-2.*f); // smoothstep

    float v= mix( mix(hash21(i+vec2(0,0)),hash21(i+vec2(1,0)),f.x),
                  mix(hash21(i+vec2(0,1)),hash21(i+vec2(1,1)),f.x), f.y);
	return   MOD==0 ? v
	       : MOD==1 ? 2.*v-1.
           : MOD==2 ? abs(2.*v-1.)
                    : 1.-abs(2.*v-1.);
}

vec3 random3f( vec3 p )
{

    return fract(sin(vec3( dot(p,vec3(1.0,57.0,113.0)), 
                           dot(p,vec3(57.0,113.0,1.0)),
                           dot(p,vec3(113.0,1.0,57.0))))*43758.5453);
}

vec2 fbm22(vec2 p) {
    vec2 v = vec2(0);
    float a = .5;
    mat2 R = rot(.37);

    for (int i = 0; i < 9; i++, p*=2.,a/=2.) 
        p *= R,
        v += a * noise22(p);

    return v;
}

vec3 voronoi( in vec3 x )
{
    vec3 p = floor( x );
    vec3 f = fract( x );

	float id = 0.0;
    vec2 res = vec2( 100.0 );
    for( int k=-1; k<=1; k++ )
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec3 b = vec3( float(i), float(j), float(k) );
        vec3 r = vec3( b ) - f + random3f( p + b );
        float d = dot( r, r );

        if( d < res.x )
        {
			id = dot( p+b, vec3(1.0,57.0,113.0 ) );
            res = vec2( d, res.x );			
        }
        else if( d < res.y )
        {
            res.y = d;
        }
    }

    return vec3( sqrt( res ), abs(id) );
}

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}


void map(inout Matter ma, vec3 p)
{
    float mat01 = 10.0, mat02 = 10.0;
    p.xz *= rot(length(p) * 0.75 - sin(mod03) + fGlobalTime * 0.15);
    vec3 p01 = p, p02 = p;
  //p.xz *= rot(length(p) * 0.05);
   // p.xy*= rot(p.y*0.25);
    p01.xy = opRepLim(p01.xy, 3.05 - sin(fGlobalTime), vec2(5.0));
  
    //https://www.shadertoy.com/view/lsVyRy
    p02.xy = fbm22(p02.xy * CRACK_zebra_scale) / CRACK_zebra_scale / CRACK_zebra_amp;
    
  
  /*float mult = 1.5;
  float rng = 2.5 - abs(sin(fGlobalTime * 0.2)) * 2.0;
  for(int i = 0; i < 25 - abs(sin(fGlobalTime * 0.1)) * 20; ++i)
  {
    p01.x = abs(p01.x) - rng * mult;
    p01.xy *= rot(0.01 * mod03 + fGlobalTime * 0.05 + mod02);
    p01.xz *= rot(0.05 * mod03 + fGlobalTime * 0.05 + mod03);
    
    mult *= 0.99;
  }*/
  
    p.x += sin(p.z*5.9)*0.05 + mod02;
    //mat01 = box(p + vec3(0.0), vec3(6.0, 6.0, 6.0));
    mat01 = sphere(p + vec3(0.0), 5.0);
    
     //mat01 = box(p01 - vec3(0.0), vec3(0.050,0.05, 0.05) + fft);
  //mat01 = smin(mat01, box(p01 - vec3(0.0), vec3(0.01,0.05, 0.01)), 0.5);
  
    p.y += 0.01 + fGlobalTime * 0.1;
   vec3 v = voronoi((0.75)*p + p02 + fGlobalTime * 0.25 + mod02);
    vec3 v02 = voronoi((0.25)*p + p02 + fGlobalTime * 0.1);

  //vec3 v = voronoi((0.5)* p + p02 + fGlobalTime);
    //vec3 v02 = voronoi((0.05)*p);
  
    float f = clamp( 5.5*(v.y-v.x), 0.0, 1.0 );
    float f02 = clamp( 5.5*(v02.y-v02.x), 0.0, 1.0 );
   mat01 += f * (0.05  + abs(cos(fGlobalTime * 0.2)) * 1.0)+ (f02 * 3.55 - abs(sin(fGlobalTime * 0.1))*3.0);
       //mat01+= f * 0.25;
    
    ma.voroval = v.y * 1.0 + v02.y * 5.0;
  
    
    ma.glow += pow(0.1/(0.05+abs(clamp(mat01, 0.00001, 100.0))), 20.0 * 0.3);
    //ma.voroval = mat01;
    ma.m = mat01;
    
}



void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  fft = texture(texFFTSmoothed, 0.1).x;

res.glowCol = vec3(0.0);
    mat.hit = false;
    
    ray.o = vec3(1.0 * cos(fGlobalTime * 0.1), 10.0 * 0.9, 2.0 * 0.75 * sin(fGlobalTime * 0.2)), ray.t = vec3(0.0);
    vec3 fr = normalize(ray.t-ray.o);
    vec3 ri = normalize(cross( fr, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(ri ,fr));
    ray.dir = normalize(fr + uv.x * ri + uv.y * up);
    ray.p = ray.o + ray.dir * 0.25;
    
    for(int i = 0; i < 50; i++)
    {
        map(mat, ray.p);
        
       
        
        res.glowCol += 0.005 * mat.glow * palette(mat.voroval, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0 * 1.0,1.0 * 0.05,1.0 * 0.35),vec3(1.0 * 0.75,1.0 * 0.15,1.0 * 0.0)) * 0.025;
        
        if(mat.m < 0.001)
        {
            
            if(!mat.hit)
            {
                mat.hit = true;
                mat.posHit = ray.p;
                //break;
            }
            mat.m =10.0 * 0.1;
            //
        }
       
       ray.p += ray.dir * mat.m * 1.0 * 0.05;
    }
    
	out_color = vec4(res.glowCol,1.0);
}