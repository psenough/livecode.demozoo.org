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
 
 mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}
float smin(inout float d1, inout float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}
float sdcc( vec3 p, vec3 a, vec3 b, float r )
{
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}
float map(vec3 p) {
      vec3 op = p;

    p = op;
    
    float base = length(p) - 2.5;
    //base = min(base, nopp);
    vec3 np = p;
    np.x = abs(np.x);
    float offset = length(np-vec3(1.8,-0.6,0)) - 1.75;
    base = smin(base, offset, 1.);
    np = p;
    np.x = abs(np.x);
    np.xy *= Rot(0.55);
    float no = sdcc(np-vec3(.2,3,0), vec3(0,2,0), vec3(0,-1,0), 0.9);
    base = smin(base, no, 0.25);
    
    return base;
}
vec3 norm(vec3 hp) {
    vec3 e=vec3(1e-2,0,0);
    float d = map(hp);
    return normalize(vec3(map(hp + e.xyy) - d,
                          map(hp + e.yxy) - d,
                          map(hp + e.yyx) - d));
}

float sd5(in vec2 p, in float r, in float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}
float dot2( in vec2 v ) { return dot(v,v); }

float sdH( in vec2 p )
{
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}
vec2 uvs(vec3 p)
{
	p = normalize(p);
	float x = atan(p.z, p.x) / 6.283;
	float y = asin(p.y) / 3.141;
	return vec2(0.5) + vec2(x,y);
}
void draw(vec2 uv, float dist, vec3 mx, inout vec3 color)
{
    float dc = fwidth(dist) * 0.5;
    color = mix(color,vec3(0,0,0),smoothstep(dc,-dc,dist-0.01) );
    color = mix(color, mx, smoothstep(dc, -dc, dist));
}
float cir(vec2 p, float radius)
{
    return length(p) - radius;
}
float tD(vec2 p, float width, float height)
{
	vec2 n = normalize(vec2(height, width / 2.0));
	return max(	abs(p).x*n.x + p.y*n.y - (height*n.y), -p.y);
}
float sduc( vec2 p, float r1, float r2, float h )
{
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,vec2(-b,a));
    if( k < 0.0 ) return length(p) - r1;
    if( k > a*h ) return length(p-vec2(0.0,h)) - r2;
    return dot(p, vec2(a,b) ) - r1;
}
float sdlr(vec2 uv, vec2 a, vec2 b, float lw)
{
    vec2 pa = uv-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - lw*0.5;
}
void sceneDistance2(vec2 p, inout vec3 color) {
    vec2 np = p;
    np *= Rot(fGlobalTime);
    //draw(p, sduc(p, .1, .05, .1 ), vec3(0.8,0.95,.43), color);

	float f = texture( texFFTSmoothed, .5 ).r * 1000;
   draw(np, sd5(np, .4+(.1*f), .4), vec3(1.,0.97,.0), color);

    float angleStep = 360.0/10.;
    for (int i=0; i<10; i++) {
        float theta = float(i) * angleStep + (fGlobalTime*50.);
        float Px = -0.065 + ((0.35 +(.1*sin(f)))  * cos(radians(theta)) + (0.15 * abs(sin(fGlobalTime+(float(i)*100.)))) );
        float Py = -0.05 + ((0.35 +(.1*sin(f))) * sin(radians(theta)) + (0.15 * abs(sin(fGlobalTime+(float(i)*100.)))) );
      
      float egg = sduc(p-vec2(Px, Py), .1, .05, .1 );
      float size = 12.;
      float heart = sdH((p*size)-vec2(Px*size, Py*size)-vec2(0.,-0.5)); 
      draw(p, egg, vec3(1.,0.97,.7), color);
      draw(p, heart, vec3(1.,0.,.0), color);
      
    }
}




void sceneDistance(vec2 p, inout vec3 color)
{
    p = p-vec2(.23, 0.5);
    p *= Rot(1.55);
    p.y *= 1.55;
    draw(p, cir(p-vec2(.0, -0.11), 0.005), vec3(0.), color);
  
  vec2 np = p; 
    np.x = abs(np.x);
    float c1 = cir(np-vec2(.15, 0.05), 0.075);
    draw(p, cir(np-vec2(.15, 0.05), 0.075), vec3(1.), color);
    vec2 npx = np;
    npx.x *= 1.75;
    draw(p, cir(npx-vec2(.25, 0.05), 0.04), vec3(0.), color);
    draw(p, cir(np-vec2(.133, 0.06), 0.01), vec3(1.), color);
  
 np = p;
    np *= Rot(2.1);
    draw(p, tD(np-vec2(.04,0.0), 0.055, 0.055), vec3(0.), color);
    np = p;
    np.x = abs(np.x);
    np *= Rot(0.4);
    draw(p, sdlr(np-vec2(.15,-0.1), vec2(0.05,0.05), vec2(-0.05,0.05), 0.001), vec3(0.), color);
    np *= Rot(0.5);
    draw(p, sdlr(np-vec2(.175,-0.05), vec2(0.05,0.05), vec2(-0.05,0.035), 0.001), vec3(0.), color);
     
 
np = p;
    np.x = abs(np.x);
    np *= Rot(0.84);
    draw(p, sduc(np-vec2(-0.025,0.13), .005, .005, .1 ), vec3(0.), color);
    

}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = log(m.y+1);

	float f = texture( texFFTSmoothed, d ).r * 100;

  float r = length(uv);
  vec3 color = mix( vec3(1), vec3( 	173./255., 216./255., 230./255.), r+f);
  
  float scale= v2Resolution.y /2.;
    vec2 center= gl_FragCoord.xy -v2Resolution.xy /2.; 
    vec2 pos;
    float radius= scale /10.;
    float width= 40.;
    float c;

    float p= 1.; 
    float a= .05; 
    float b= .0;
    d= 40.;

    float rate= .9;
    float amp= scale/1.75;
    

    radius *= .8;
    pos= center - vec2( amp, 0.) *sin(fGlobalTime *rate); 
    c= width -abs(( sin( pos.x /radius)+ sin( pos.y /radius) -sin( fGlobalTime *rate) *2.5) *d);
    color += vec3( vec2(0.), pow(c,p)*a +b);
    
    radius *= .8;
    pos= center - vec2( amp, 0.) *sin( fGlobalTime *rate *.8);
    c= width -abs(( sin( pos.x /radius)+ sin( pos.y /radius) -sin( fGlobalTime *rate) *2.5) *d);
    color += vec3( pow(c,p)*a +b);
    
    radius *= .8;
    pos= center - vec2( amp, 0.) *sin(fGlobalTime *rate *1.25);
    c= width -abs(( sin( pos.x /radius)+ sin( pos.y /radius) -sin( fGlobalTime *rate) *2.5) *d);
    color += vec3( 0., pow(c,p)*a +b, 0.);
  
  
  
  
    vec3 cam = vec3( 0, 0, -12 );
    vec3 dir = normalize( vec3( uv, 1 ) );
    float t = 0.;
    for( int i = 0; i < 100; ++i ) {
        vec3 hp = cam + dir * t;
        float d = map(hp);
        t += d;
        if( d < 0.0001 || t > 100.0 ) {
            break;
        }
    }
    sceneDistance2(uv, color);
      if( t < 100.0 ) { 
        
      f = texture( texFFTSmoothed, 0 ).r * 100;

        vec3 p = cam + dir * t;
        p.yz *= Rot(0.1*sin(fGlobalTime*6.));
        p.xy *= Rot(-1.6);
        vec2 uv2 = uvs(p);
        color = vec3(1.,0.8,0.8);//newCol.rgb;
        
        vec3 n = norm(p);
        vec3 lp = vec3(0, 1, -4);
        vec3 l = normalize(lp - p);
        vec3 normalizedLightDirection = normalize(lp-p);
        float diffuseLightingValue = clamp( dot(n, l)*.35+.65 , 0.0, 0.65);
        vec3 newColor = vec3(0.0);
        newColor = vec3(255./255., 150./255.,150./255.);
        
        
        color = newColor * vec3(diffuseLightingValue);
        color /= .5;
       sceneDistance(uv2, color);
 
        }
  
  
	out_color = vec4(color,1);//f + t;
}