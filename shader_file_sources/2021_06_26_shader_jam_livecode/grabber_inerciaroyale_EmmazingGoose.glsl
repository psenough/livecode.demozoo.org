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


const float PI = acos(-1.);

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

void add(inout vec2 d1, in vec2 d2) {
   if(d2.x < d1.x) d1 = d2;
}

void diff(inout vec2 d1, in vec2 d2) {
    if (-d2.x > d1.x) {
        d1.x = -d2.x;
        d1.y = d2.y;
    }
}
float sdPlane( vec3 p, vec4 n )
{
    // n must be normalized
    return dot(p,n.xyz) + n.w;
}

float sphere(vec3 p, float sz) {
  return length(p) - sz;
}

vec2 rX(const in vec2 p, const in float ang) {
   float nA = ang * PI;
   float c = cos(nA), s = sin(nA);
   return vec2(p.x*c - p.y*s, p.x*s + p.y*c);
}

float sdRC( in vec3 p, in float r1, float r2, float h )
{
    vec2 q = vec2( length(p.xz), p.y );
    
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(q,vec2(-b,a));
    
    if( k < 0.0 ) return length(q) - r1;
    if( k > a*h ) return length(q-vec2(0.0,h)) - r2;
    
    return dot(q, vec2(a,b) ) - r1;
}

vec2 map(vec3 p) {
  vec3 bP = p;
  
  //bP.xy = rX(bP.xy, fGlobalTime*.1);
  vec3 eyeP = bP;
  //eyeP.yz = rX(eyeP.yz, 0.1*sin(fGlobalTime));
  
  vec3 newP = eyeP+vec3(1.25,0,1.3);
  float sp = sphere(newP,.5);
  vec2 base = vec2(sp, 1.0);
  
  add(base, vec2(sphere(bP, 2),2.0));
  add(base, vec2(sphere(eyeP+vec3(-1.25,0,1.3),.5), 1.));
  add(base, vec2(sphere(eyeP+vec3(-1.58,0,1.7),.15), 3.));
  add(base, vec2(sphere(eyeP+vec3(1.58,0,1.7),.15), 3.));
  
  vec3 beakP = bP; 
  beakP += vec3(0,0.75,1.75);
  beakP.yz = rX(beakP.yz, 0.55);
  
  
  add(base, vec2(sdRC(beakP, 1., 0.2, 1.75) , 4.));
  
  return base;
}

vec3 gNorm(vec3 hit){
   vec3 e=vec3(1e-2,0,0);
   float d = map(hit).x;
   return normalize(vec3( map(hit + e.xyy).x - d, 
                          map(hit + e.yxy).x - d, 
                          map(hit + e.yyx).x - d));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  //
  vec3 ro = vec3(0,0,-10);
  vec3 rd = normalize(vec3(uv,1));
  float trav = 0.0;
  float additive = 0.0;
  vec2 hitObj = vec2(0.0);
  for (int i=0; i<100; i++){
     hitObj = map(ro+rd*trav);
     additive += 0.05;
     float hit = hitObj.x;
     trav += hit;
    if (hit < 0.01) {
        break;
    }
     
    if (hit > 20.) {
       break;
    }
  }
  
  if (trav < 20.) {
    vec3 hitPoint = ro+rd*trav;  
    vec3 baseColor = vec3(1,1,1);
    if (hitObj.y == 2.0) { 
      baseColor = vec3(0.7,0.9,0.7);
     } else if (hitObj.y == 3.0) {
       baseColor = vec3(0,0,0);
     } else if (hitObj.y == 4.0) {
       baseColor = vec3(0.2,0.2,0.2);
     }
     
     
    vec3 lightPos = vec3(0,10,-5);
    vec3 normLight = normalize(lightPos-hitPoint);    
    vec3 norm = gNorm(ro+rd*trav);
    float diffval = clamp(dot(norm,normLight)*.5,0,1);
    out_color = vec4(baseColor * vec3(diffval),1);
   return;
  }
  out_color = vec4(210./255., 180./255., 140./255., 1)+additive/2.;
  return;
  //
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
}