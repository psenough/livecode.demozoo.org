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
vec2 rCW(vec2 p, float a)
{
	mat2 m = mat2(cos(a), -sin(a), sin(a), cos(a));
	return p * m;
}

float sTI( in vec2 p, in vec2 q )
{
    p.x = abs(p.x);
	vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float k = sign( q.y );
    float d = min(dot( a, a ),dot(b, b));
    float s = max( k*(p.x*q.y-p.y*q.x),k*(p.y-q.y)  );
	return sqrt(d)*sign(s);
}

float cro(in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

float sUC( in vec2 p, in float ra, in float rb, in float h )
{
	p.x = abs(p.x);
    
    float b = (ra-rb)/h;
    vec2  c = vec2(sqrt(1.0-b*b),b);
    float k = cro(c,p);
    float m = dot(c,p);
    float n = dot(p,p);
    
         if( k < 0.0   ) return sqrt(n)               - ra;
    else if( k > c.x*h ) return sqrt(n+h*h-2.0*h*p.y) - rb;
                         return m                     - ra;
}

#define PI acos(-1.)
float sdCircle2 (vec2 p, float radius)
{
    return length(p) - radius;
}
mat2 rot2D(float r)
{
    float c = cos(r), s = sin(r);
    return mat2(c, s, -s, c);
}

float pumpkin2D(vec2 p, float radius, float vertices, float curvature)
{
  float angle = atan(p.x, -p.y) / (PI*2.) * vertices;
  return length(p) -radius +smoothstep(0., 1., abs(fract(angle)-0.5)) *radius *curvature;
}

vec2 translate(vec2 p, vec2 t) { return p - t; }

void diff(inout vec2 d1, in vec2 d2) {
    if (-d2.x > d1.x) {
        d1.x = -d2.x;
        d1.y = d2.y;
    }
}

void add(inout vec2 d1, in vec2 d2) {
    if (d2.x < d1.x) d1 = d2;
}

void intersection(inout vec2 d1, in vec2 d2) {
    if (d1.x < d2.x) d1 = d2;
}


float smoothMerge(float d1, float d2, float k)
{
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0-h);
}

float merge(float d1, float d2)
{
    return min(d1, d2);
}

float mergeExclude(float d1, float d2)
{
    return min(max(-d1, d2), max(-d2, d1));
}

float substract(float d1, float d2)
{
    return max(-d1, d2);
}

float intersect(float d1, float d2)
{
    return max(d1, d2);
}

float repeat(float coord, float spacing) {
    return mod(coord, spacing) - spacing*0.5;
}


float fillMask(float distanceChange, float dist) {
    return smoothstep(distanceChange, -distanceChange, dist);
}

float innerMask(float distanceChange, float dist, float width) {
    return smoothstep(distanceChange,-distanceChange,dist+width);
}

float outerMask(float distanceChange, float dist, float width) {
    return smoothstep(distanceChange,-distanceChange,dist-width);
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float sRLS(vec2 uv, vec2 a, vec2 b, float lineWidth)
{
    vec2 pa = uv-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - lineWidth*0.5;
}
float sel( vec2 p, in vec2 ab )
{
    p = abs( p ); if( p.x > p.y ){ p=p.yx; ab=ab.yx; }
    
    float l = ab.y*ab.y - ab.x*ab.x;
    
    float m = ab.x*p.x/l;
    float n = ab.y*p.y/l;
    float m2 = m*m;
    float n2 = n*n;
    
    float c = (m2 + n2 - 1.0)/3.0;
    float c3 = c*c*c;
    
    float q = c3 + m2*n2*2.0;
    float d = c3 + m2*n2;
    float g = m + m*n2;
    
    float co;
    
    if( d<0.0 )
    {
        float h = acos(q/c3)/3.0;
        float s = cos(h);
        float t = sin(h)*sqrt(3.0);
        float rx = sqrt( -c*(s + t + 2.0) + m2 );
        float ry = sqrt( -c*(s - t + 2.0) + m2 );
        co = ( ry + sign(l)*rx + abs(g)/(rx*ry) - m)/2.0;
    }
    else
    {
        float h = 2.0*m*n*sqrt( d );
        float s = sign(q+h)*pow( abs(q+h), 1.0/3.0 );
        float u = sign(q-h)*pow( abs(q-h), 1.0/3.0 );
        float rx = -s - u - c*4.0 + 2.0*m2;
        float ry = (s - u)*sqrt(3.0);
        float rm = sqrt( rx*rx + ry*ry );
        co = (ry/sqrt(rm-rx) + 2.0*g/rm - m)/2.0;
    }
    
    float si = sqrt( 1.0 - co*co );
    
    vec2 r = ab * vec2(co,si);
    
    return length(r-p) * sign(p.y-r.y);
}

float blurMask(float distanceChange, float dist, float blurAmount) {
    float blurTotal = blurAmount*.01;
    return smoothstep(blurTotal+distanceChange, -distanceChange, dist);
}

float dot2( in vec2 v ) { return dot(v,v); }

float sdHeart( in vec2 p )
{
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}


void draw(vec2 uv, float dist, vec4 mixColor, inout vec4 out_color)
{
    float distanceChange = fwidth(dist) * 0.5;
    out_color = mix(out_color,vec4(0,0,0,1),outerMask(distanceChange, dist,0.01));
    out_color = mix(out_color, mixColor, fillMask(distanceChange, dist));  
}



void drawGlow(vec2 uv, float dist, vec4 mixColor, inout vec4 out_color)
{
    float distanceChange = fwidth(dist) * 0.5;
    out_color = mix(out_color, mixColor,blurMask(distanceChange, dist,5.));
    out_color = mix(out_color, mixColor + .5, fillMask(distanceChange, dist));  
}

void sceneDistance(vec2 p, inout vec4 out_color) 
{
  vec2 pp = p;
  p = rCW(p, sin(fGlobalTime*6.)/8.);
  p *= clamp(sin(fGlobalTime)*2., 0.8, 1.0);
  
  float angleStep1 = 360.0/10.;
    for (int i=0; i<15; i++) {
        float theta = float(i) * -angleStep1 + (fGlobalTime*50.);
        float Px = -0.065 + (0.55 * cos(radians(theta)) + (0.25 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        float Py = -0.015 + (0.15 * sin(radians(theta)) + (0.25 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        float c1 = sdCircle2(translate(p, vec2(Px, Py)), 0.05 - (0.05 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        drawGlow(p, c1,vec4(18./255.,112./255.,254./255.,1.), out_color);
    }


  
  vec2 starP = abs(p.xy);
    starP.x = repeat(starP.x, 0.85);
    float stars = pumpkin2D(starP * rot2D(abs(sin(fGlobalTime)) * PI), 0.15 - (0.025 * abs(sin(fGlobalTime))) , 5., -2.5);
    draw(starP, stars,vec4(1., 1.,0.,1), out_color);
    
 
    vec2 bodyP = translate(pp, vec2(0,.3));
    bodyP *= 1.5;
  bodyP = rCW(bodyP, .5 *cos(fGlobalTime*6.)/10.);

  bodyP.x += .25 * sin(fGlobalTime);

    
    vec2 wb = bodyP;
    wb = rCW(wb, .2 * cos(fGlobalTime *2.));
    float wingb = sUC(rCW(translate(wb, vec2(0.3, -.4)), (PI/2.)*2.9 + (.2*cos(fGlobalTime * 5.))), .05, .1, .2);
    draw(p, wingb, vec4(115./255.), out_color);

    vec2 wgb = bodyP;
    wgb = rCW(wgb, .2 * cos(fGlobalTime *2.));
    float wingbG = sUC(rCW(translate(wgb, vec2(0.4, -.4)), (PI/2.)*2.9 + (.2*cos(fGlobalTime * 5.))), .01, .01, .1);
    drawGlow(p, wingbG, vec4(0,115./255.,0,1), out_color);

  
    float neck = sUC(translate(bodyP, vec2(0,-.3)), .075, .04, .2);
    draw(p, neck, vec4(105./255.), out_color);
  
    vec2 lp1 = translate(bodyP, vec2(0.1, 0.));
    lp1.x += .05 * cos(fGlobalTime*5.);
    float leg1 = sUC(rCW(translate(lp1, vec2(0,-.85)), -(PI/2.)*.1), .04, .02, .2);
    draw(p, leg1, vec4(15./255.), out_color);
    
    
    float leg4 = sUC(rCW(translate(lp1, vec2(0,-.85)), -(PI/2.)*-1.2 -(.2*sin(fGlobalTime*5.))), .04, .02, .1);
    draw(p, leg4, vec4(15./255.), out_color);
 
    vec2 lp2 = bodyP;
    lp2.x -= .05 * sin(fGlobalTime*5.);
    float leg2 = sUC(rCW(translate(lp2, vec2(-0.05,-.85)), (PI/2.)*.1), .04, .02, .2);
    draw(p, leg2, vec4(15./255.), out_color);
   
   float leg3 = sUC(rCW(translate(lp2, vec2(-0.05,-.85)), (PI/2.)*1.2 +(.2*sin(fGlobalTime*5.))), .04, .02, .1);
    draw(p, leg3, vec4(15./255.), out_color);
   
    float body = sel(translate(bodyP, vec2(0,-.5)), vec2(.25, .2));
    draw(p, body, vec4(105./255.), out_color);
  
    vec2 wggp = bodyP;
    wggp = rCW(wggp, .2 * sin(fGlobalTime));
    float winggg = sUC(rCW(translate(wggp, vec2(0.4, -.4)), (PI/2.)*2.9 + (.2*cos(fGlobalTime * 5.))), .01, .01, .2);
    drawGlow(p, winggg, vec4(0,115./255.,0.,1.), out_color);
  
    vec2 wp = bodyP;
    wp = rCW(wp, .2 * sin(fGlobalTime));
    float wing = sUC(rCW(translate(wp, vec2(0.3, -.4)), (PI/2.)*2.9 + (.2*cos(fGlobalTime * 5.))), .05, .1, .2);
    draw(p, wing, vec4(115./255.), out_color);
    
    
    vec2 headP = bodyP;
    headP = rCW(headP, .2 * cos(fGlobalTime *5.));
    float beak = sUC(rCW(translate(headP, vec2(0.3, -.03)), (PI/2.)*3.), .05, .1, .2);
    draw(p, beak, vec4(25./255.), out_color);
    
    float head = sdCircle2(headP, .2);
    draw(p, head, vec4(105./255.), out_color);

    vec2 eyeP = translate(headP, vec2(0.1, 0.));
    float eye = sdCircle2(eyeP, .07);
    draw(p, eye, vec4(245./255.), out_color);
  
    vec2 pupilP = translate(eyeP, vec2(0.03, 0.));
    float pupil = sdCircle2(pupilP, .02);
    draw(p, pupil, vec4(25./255.), out_color);
  
    vec2 pupilPP = translate(eyeP, vec2(0.04, 0.));
    float pupill = sdCircle2(pupilPP, .01);
    draw(p, pupill, vec4(255./255.), out_color);
  
  vec2 ebp4 = translate(headP, vec2(0.03, 0.11 - (0.03 * sin(fGlobalTime *3.)) ));
        ebp4 *= rot2D(.25 * PI);
        ebp4.x =ebp4.x*-sin(ebp4.x)*5.;
        float i = sRLS(ebp4, vec2(0.005,0.005), vec2(-0.003,-0.003), 0.004);
        draw(p, i, vec4(25./255.), out_color);
  
  
  float heart = sdHeart(translate(headP, vec2(0.,-0.15))*13.);
   drawGlow(p, heart,vec4(255./255., 0,0,1), out_color);
    
  
  float angleStep = 360.0/10.;
    for (int i=0; i<10; i++) {
        float theta = float(i) * angleStep + (fGlobalTime*50.);
        float Px = -0.065 + (0.35 * cos(radians(theta)) + (0.15 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        float Py = -0.05 + (0.35 * sin(radians(theta)) + (0.15 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        float c1 = sdCircle2(translate(p, vec2(Px, Py)), 0.05 - (0.05 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        drawGlow(p, c1,vec4(218./255.,112./255.,214./255.,1.), out_color);
    }
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
  out_color = vec4(1.,0.94, 0.67, 1.0); 
  sceneDistance(uv, out_color);

	//out_color = f + t;
}
































