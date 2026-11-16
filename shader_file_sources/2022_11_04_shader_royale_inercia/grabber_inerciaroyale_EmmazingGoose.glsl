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

float cir(vec2 p, float radius) {
  return length(p) - radius;
  
}

float cro(in vec2 a, in vec2 b) { return a.x*b.y - a.y*b.x;}

float sUC(in vec2 p, in float ra, in float rb, in float h) {
  p.x = abs(p.x);
  float b = (ra-rb)/h;
  vec2 c = vec2(sqrt(1.-b*b),b);
  float k = cro(c,p), m=dot(c,p),n=dot(p,p);
  if (k < 0.){
    return sqrt(n)-ra;
    
  } else if (k>c.x*h) {
    return sqrt(n+h*h-2.*h*p.y) - rb;
  }
  
  return m-ra;
}


void inter(inout float d1, in float d2) {
   if (d1 < d2) d1 = d2;
}

void draw(float dist, vec4 mc, inout vec4 fc){
    float dtc = fwidth(dist) *.5;
    fc = mix(fc, vec4(0,0,0,1), smoothstep(dtc, -dtc, dist-0.01));
    fc = mix(fc, mc, smoothstep(dtc, -dtc, dist));
}

mat2 Rot(float r) {
  float c = cos(r), s = sin(r);
  return mat2(c,s,-s,c);
}

void sd (vec2 p, inout vec4 fc) {
  vec2 po = p;
  
  float d = 4.;
    
    po.y += sin(fGlobalTime*.2 * .6)/6.;
    
    po.x += d * -sin(fGlobalTime*.2)/6.;
    
    //c3 fpos = Rot(pos, -fGlobalTime);   
    
  
  po *= Rot(.1*sin(fGlobalTime*5.));
  
  float cirl = cir(po, 0.15);
  
  vec2 po1 = po;
  po1.x *= 2.5;
  po1.y *= 1.4;
  draw(cir(po1-vec2(-0.,-.2), 0.4), vec4(.5), fc);
  
  po1.y *= .6;
  draw(cir(po1-vec2(0.4,-.1), 0.14), vec4(.5), fc);
  draw(cir(po1-vec2(-0.4,-.1), 0.14), vec4(.5), fc);
  
  
  draw(cir(po, 0.15), vec4(.5), fc);
  draw(sUC(po-vec2(0.0,0.15), .08, .025, .15), vec4(.2), fc);
  float kk = cir(po-vec2(0.1,.1), 0.05);
  inter(kk, cirl);
  draw(kk, vec4(1), fc);

  kk = cir(po+vec2(0.1,-0.1), 0.05);
  inter(kk, cirl);
  draw(kk, vec4(1), fc);
  
  
  
  kk = cir(po-vec2(0.1,.1), 0.015);
  inter(kk, cirl);
  draw(kk, vec4(0), fc);
  
  
  kk = cir(po+vec2(0.1,-0.1), 0.015);
  inter(kk, cirl);
  
  draw(kk, vec4(0), fc);
  
  //float cirl = cir(po, 0.15);
  
  
}

#define F length(.5-fract(k.xyw*=mat3(-2,-1,2,3,-2,1,1,2,2)*
void main(void)
{
  float time = fGlobalTime;
  vec2 fragCoord = gl_FragCoord.xy;
  float iTime = fGlobalTime;
  
  
  
  ///

	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	////?
  
    vec4 k = vec4(.5 + .2*sin(time)) *.2;
    k.xy = (fragCoord*(k.w+2.)/2e2).xy;
    //k = pow(min(min(F.5)),F.4))),F.3))),7.) * 25.+vec4(0.35,.5,1.);
  //vec4 p = fragCoord;
    k *= 2.;
    //out_color = k;
  
  
  float r = length(uv);
  vec3 bg = mix(vec3(0.5,.5,.7),vec3(.9,.4,.4), .25);
  out_color = vec4(bg,1);
  
  
  vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
  float speed = .2;
  float scale = 0.003;
  vec2 p = fragCoord * scale;   
    for(int i=1; i<10; i++){
        p.x+=0.3/float(i)*sin(float(i)*3.*p.y+iTime*speed)+600./1000.;
        p.y+=0.3/float(i)*cos(float(i)*3.*p.x+iTime*speed)+600./1000.;
    }
    // scale = 0.03;
    // p = fragCoord * scale;
    r=cos(sin(p.x)-sin(p.y)+iTime*speed*2.)*.3+.5;
    float g=sin(cos(p.x)+cos(p.y)-iTime*speed*2.)*.3+.5;
    float b=(sin(cos(p.x)*cos(p.y)+iTime*speed*2.)-cos(sin(p.x)*sin(p.y)+iTime*speed*2.))*.3+.5;
    // r = 0.;
	// g = 0.;
    // b = 0.;
    vec3 color = vec3(r,g,b);

    ///
    
    vec2 p2 = vec2(fragCoord.x / v2Resolution.x, fragCoord.y / v2Resolution.y);
    p2 -= 0.5;
    p2 /= vec2(v2Resolution.y / v2Resolution.x, 1);
    p2 *= Rot(-3.14159*.5);
    
    k=vec4(.5 + .2*sin(iTime))*.2;
    p = fragCoord/5.;// * pow(p2.x, -.3);
    
    k.xy = p*(k.w+2.)/2e2;
    k = pow(min(min(F.5)),F.4))),F.3))), 7.)*25.+vec4(0,.35,.5,1);
    k *= 2.;
    k = mix(k, vec4(color,1), .5);
        
    
    

    
    float waveStrength = 0.02;
    float frequency = 30.0;
    float waveSpeed = 5.0;
    vec4 sunlightColor = vec4(1.0,0.91,0.75, 1.0);
    float sunlightStrength = 15.0;
    
    vec2 po = uv;
  
    d = 4.;
    
    po.y += sin(fGlobalTime*.2 * .6)/6.;
    
    po.x += d * -sin(fGlobalTime*.2)/6.;
    vec2 tapPoint = uv;//vec2(600./v2Resolution.x,600/v2Resolution.y);
    uv = fragCoord.xy / v2Resolution.xy;
    float modifiedTime = iTime * waveSpeed;
    float aspectRatio = v2Resolution.x/v2Resolution.y;
    vec2 distVec = po;
    distVec.x *= aspectRatio;
    float distance = length(distVec);
    vec2 newTexCoord = uv;// * pow(p2.x, -.3);;
    
    float multiplier = (distance < 1.0) ? ((distance-1.0)*(distance-1.0)) : 0.0;
    float addend = (sin(frequency*distance-modifiedTime)+1.0) * waveStrength * multiplier;
    newTexCoord += addend;    
    
    vec4 colorToAdd = sunlightColor * sunlightStrength * addend;
    out_color = k + colorToAdd;
  
  
  
   uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  sd(uv, out_color);
//	out_color = f + t;
}