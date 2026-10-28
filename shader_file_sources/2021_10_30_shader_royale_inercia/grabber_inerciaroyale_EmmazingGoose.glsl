#version 410 core
#define PI (acos(-1.))

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
uniform float fMidiKnob;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float pModPolar(inout vec2 p, float repetitions) {
    float angle = 2.*PI/repetitions;
    float a = atan(p.y, p.x) + angle/2.;
    float r = length(p);
    float c = floor(a/angle);
    a = mod(a,angle) - angle/2.;
    p = vec2(cos(a), sin(a))*r;
    // For an odd number of repetitions, fix cell index of the cell in -x direction
    // (cell index would be e.g. -5 and 5 in the two halves of the cell):
    if (abs(c) >= (repetitions/2.)) c = abs(c);
    return c;
}

vec2 rX(const in vec2 p, const in float ang) {
   float nA = ang * PI;
   float c = cos(nA), s = sin(nA);
   return vec2(p.x*c - p.y*s, p.x*s + p.y*c);
}

float sdRoundCone( in vec3 p, in float r1, float r2, float h )
{
    vec2 q = vec2( length(p.xz), p.y );
    
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(q,vec2(-b,a));
    
    if( k < 0.0 ) return length(q) - r1;
    if( k > a*h ) return length(q-vec2(0.0,h)) - r2;
        
    return dot(q, vec2(a,b) ) - r1;
}
float opUnion( float d1, float d2 ) { return min(d1,d2); }
float opSubtraction( float d1, float d2 ) { return max(-d1,d2); }
float opIntersection( float d1, float d2 ) { return max(d1,d2); }
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}



float map(vec3 p, float f) {
	vec3 cp = p;
		
	cp.yz = rX(cp.yz, 1.1);
	cp.xz = rX(cp.xz, fGlobalTime * .2);
	
	pModPolar(cp.xz, 12.);
	
	float bc = length(cp-vec3(1,0,0)) - 1;// + f *100;
	float bk = length(p-vec3(0,.2,0)) - 1.2;
	bc = max(-bk, bc);

	
	vec3 cp1 = p;
	cp1.yz = rX(cp1.yz, 1.1);
	cp1.xz = rX(cp1.xz, fGlobalTime * .2);
	
	float bk1 = length(cp1-vec3(0.5,-.3,2.)) - 0.25;
	bc = max(-bk1, bc);

	float bk2 = length(cp1-vec3(-0.5,-.3,2.)) - 0.25;
	bc = max(-bk2, bc);

	
	float bd = p.y + 2;
	
	
//	float bt = sdRoundCone(p, 1., .3, 1.6);
//	bc = min(bc, bt);
//	float bt1 = sdRoundCone(p-vec3(0,1.5,0), 0.2, 0.2, 1.);
//	bc = min(bc, bt1);
//	vec3 p1 = p;
//	p1.yz = rX(p1.yz, -1.75);

//	p1 -= vec3(0, -2, 0);
//	float bt2 = sdRoundCone(p1, 0.2, 0.5, 1.);
//	bc = min(bc, bt2);
	return min(bc,bd);
}

vec3 gNorm(vec3 hit, float f) {
	vec3 e = vec3(1e-2,0,0);
	float d = map(hit, f);
	return normalize(vec3(map(hit+e.xyy, f)-d,
			      map(hit+e.yxy, f)-d,
			      map(hit+e.yyx, f)-d));
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 ro = vec3(0,0,-10);
	vec3 rd = normalize(vec3(uv,1));
	
	float trav = 0.0;
	float hit = 0.0;

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	
	for (int i=0; i<100; i++) {
		hit = map(ro+rd*trav, f);
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
		vec3 lightPos = vec3(0,10,-5);
		vec3 normLight = normalize(lightPos-hitPoint);   
		vec3 norm = gNorm(ro+rd*trav, f);
		float diffval = clamp(dot(norm,normLight)*.5,0,1);
		vec3 baseColor = vec3(1,0.4,0.0);
		if (hitPoint.y < -1) {
			baseColor = vec3(0,.7,0);
		}
		out_color = vec4(baseColor * vec3(diffval),1);
		//out_color = vec4(1,1,1,1);
		return;
	}
	
	out_color = vec4(0.6,0.4,0.4, 1.0);
	return;
	

	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	//out_color = f + t;
}