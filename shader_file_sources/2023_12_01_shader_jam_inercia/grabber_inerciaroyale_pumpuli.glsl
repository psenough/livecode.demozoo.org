#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia;
uniform sampler2D texInerciaBW;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float dot2( in vec2 a ){ return dot(a,a); }
vec2 random2f(in vec2 a, in float t){ return texture(texNoise,a*.1+vec2(t*.2)*.01).xy*4; }
float log10( in float n ) {
	const float kLogBase10 = 1.0 / log2( 10.0 );
	return log2( n ) * kLogBase10;
}

float voronoiDistance( in vec2 x, in float t )
{
    vec2 p = vec2(floor( x ));
    vec2  f = fract( x );
    vec2 mb;
    vec2 mr;
    float res = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 b = vec2(i, j);
        vec2  r = vec2(b) + random2f(p+b, t)-f;
        float d = dot(r,r);
        if( d < res )
        {
            res = d;
            mr = r;
            mb = b;
        }
    }
    res = 8.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 b = mb + vec2(i, j);
        vec2  r = vec2(b) + random2f(p+b, t) - f;
        float d = dot(0.5*(mr+r), normalize(r-mr));
        res = min( res, d );
    }
    return res;
}
float getBorder( in vec2 p, in float t )
{
    float d = voronoiDistance( p , t);
    return 1.0 - smoothstep(0.0,0.05,d);
}
vec3 hsl2rgb( in vec3 c )
{
  vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
  return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}
vec3 HueShift (in vec3 Color, in float Shift)
{
  vec3 P = vec3(0.55735)*dot(vec3(0.55735),Color);
  vec3 U = Color-P;
  vec3 V = cross(vec3(0.55735),U);    
  Color = U*cos(Shift*6.2832) + V*sin(Shift*6.2832) + P;
  return vec3(Color);
}
vec3 rgb2hsl( in vec3 c ){
  float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = c.r;
	float g = c.g;
	float b = c.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );
	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;     
        //s = l < .05 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) ); Original
		s = l < .0 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
		if ( r == cMax ) {
			h = ( g - b ) / cDelta;
		} else if ( g == cMax ) {
			h = 2.0 + ( b - r ) / cDelta;
		} else {
			h = 4.0 + ( r - g ) / cDelta;
		}
		if ( h < 0.0) {
			h += 6.0;
		}
		h = h / 6.0;
	}
	return vec3( h, s, l );
}
float sdHeart( in vec2 p )
{
    p.x = abs(p.x);
    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}
float sdHex( in vec2 p, in float r )
{
	const vec3 k = vec3(-0.866025404,0.5,0.577350269);
	p = abs(p);
	p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
	p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
	return length(p)*sign(p.y);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv=floor(uv/.003)*.003;
  vec2 uv_=uv;
  vec2 pruv=uv;
  uv_*=vec2(1,-1);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
	float bd = texture( texFFTSmoothed, .01 ).r * 8;
	float intg = texture( texFFTIntegrated, .005 ).r*40;
  float gt = fGlobalTime;
  vec4 ine = texture( texInercia, uv*vec2(1,-1)*4+vec2(gt*.2,-.5))*pow(bd,4)*1;
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFTSmoothed, pow(abs(m.x)*.3,1.8)  ).r*10;
  pruv-=vec2(.5);
  pruv*=.98;
  pruv+=vec2(.5);
  vec4 prev = texture( texPreviousFrame, pruv);
  
	//m.x += sin( fGlobalTime ) * 0.1;
	//m.y += fGlobalTime * 0.25;

	vec4 t = vec4(pow(bd,2)*1*f,pow(bd,2)*f+.05,pow(bd,1.5)*1*f,1)*(-step(sdHeart(uv*2+vec2(0,.5)),0)+step(sdHeart(uv*(2-bd*.3)+vec2(0,.5)),0));
  t+=.4*getBorder(uv_*10,pow(intg*.0002,4))*(1-step(sdHeart(uv*2+vec2(0,.5)),f*.2));
  t+=-step(sdHeart(uv*2.2+vec2(0,.5)),f*.2)+step(sdHeart(uv*2+vec2(0,.5)),f*.2);
  
  t+=ine*vec4(1.8,1.8,1.2,1)*(step(sdHeart(uv*2+vec2(0,.5)),0));
	t*=1;
  t*=vec4(.8,.2,.8,1);
	t = clamp( t, 0.0, 1.0 );
  out_color = ( t )+prev*.8;
}