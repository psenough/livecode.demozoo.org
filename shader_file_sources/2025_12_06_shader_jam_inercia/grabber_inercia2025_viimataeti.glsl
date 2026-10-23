#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInercia2025;
uniform sampler2D texInerciaBW;
uniform sampler2D texInerciaID;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 getTexture(sampler2D sampler, vec2 uv){
     vec2 size = textureSize(sampler,0);
     float ratio = size.x/size.y;
     return texture(sampler,uv*vec2(1.,-1.*ratio)-.5)*0.2;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

void rot(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

vec2 opU(vec2 d1, vec2 d2)
{
    return (d1.x < d2.x) ? d1 : d2;
}

float llength = .4;
float lspread = .4;
float wspeedmod = 4.;
float wstridemod = .2;

struct MarchResult
{
    vec3 p;
    float id;
};

vec3 glow = vec3(0.0);

vec2 sdf(vec3 p){

  
  float fft = texture( texFFTSmoothed, 1.0 ).r * 20;
  vec3 ppb = p;
  for (int i = 0; i<4; i++) {
    ppb = abs(ppb) - vec3(4.0,3.0,2.0);
    rot(ppb.xy, fft*0.1 + fGlobalTime *0.02);
    rot(ppb.yz, fGlobalTime*0.01);
  }
  
  float b = sdBox(ppb,vec3(.5 + fft,.4 + fft ,.5 + fft));
  
  vec3 pp = p;
  for (int i = 0; i<4; i++) {
    pp = abs(pp) - vec3(2.0,4.0,6.0);
    rot(pp.xy, fGlobalTime*0.1);
    rot(pp.yz, fGlobalTime*0.01);
  }
  float c = sdBox(pp,vec3(1.0,2.0,1.5));
  
  vec3 ppp = p;
  for (int i = 0; i<6; i++) {
    ppp = abs(pp) - vec3(3.4,6.0,3.2);
    rot(pp.xz, fGlobalTime*0.2);
    rot(pp.xy, fGlobalTime*0.1);
  }
  float d = sdBox(ppp, vec3(2.0,1.0,.5));
  vec3 g = vec3(0.2,0.1,0.6)*0.01 / (0.01+abs(b));
  glow += g;
  vec3 g2 = vec3(0.9,0.1,0.1)*0.1 / (0.09+abs(c));
  glow += g2;
  vec3 g3 = vec3(0.1,0.1,0.1)*0.01 / (0.01+abs(d));
  glow += g3;
  
  return opU(vec2(min(d,max(b,c)),1.0),opU(vec2(d,3.0),opU(vec2(c,2.0),vec2(b,1.0))));
}

MarchResult march(in vec3 ro, in vec3 rd, inout float t){

    MarchResult m;
    m.p = ro+rd;
    for(int i = 0; i < 40; ++i){
        vec2 d = sdf(m.p);
        t += d.x;
        m.p += rd*d.x;
        m.id = d.y;
        
        if(d.x < 0.01 || t > 100.){
            break;
        }
        
    }
    
    return m;
} 

vec3 color(in float id)
{
    if (id == 1.0)
        return vec3(0.1,0.4,0.9);
    else if (id == 2.0)
        return vec3(.6,.2,.5);
    else if (id == 3.0)
        return vec3(.8,.7,.8);
    else
        return vec3(0);
}
vec3 calcNormal( in vec3 pos) 
{
    vec2 e = vec2(0.00001, 0.0);
    return normalize( vec3(sdf(pos+e.xyy).x-sdf(pos-e.xyy).x,
                           sdf(pos+e.yxy).x-sdf(pos-e.yxy).x,
                           sdf(pos+e.yyx).x-sdf(pos-e.yyx).x ) );
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  float f = texture( texFFTIntegrated, 3).r;
	f = clamp( f, 0.0, 0.5 );
  vec3 cp = vec3(sin(fGlobalTime*2)*cos(fGlobalTime)+5.,sin(fGlobalTime*2)+2.0+(f*20),cos(fGlobalTime)+sin(fGlobalTime)+3.);
  vec3 ct = vec3(0,0,0);
  vec3 ld = vec3(-2.,0.5,2.);
  
  vec2 uv2 = gl_FragCoord.xy / v2Resolution.xy;
  vec2 q = -1.0+2.0*uv2;
  q.x *= v2Resolution.x/v2Resolution.y;
  
  vec3 cf = normalize(ct-cp);
  vec3 cr = normalize(cross(vec3(0.0,1.0,0.0),cf));
  vec3 cu = normalize(cross(cf,cr));
  
  vec3 rd = normalize(mat3(cr,cu,cf)*vec3(q,radians(90.0)));
  vec3 p = vec3(0.0);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  float t2;
  MarchResult mr;
  mr.p = vec3(0.0);
  mr.id = 0.0;
  mr = march(cp,rd,t2);
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;
  vec3 col = vec3(0.0);
  if (t2 < 100.) {
    col = color(mr.id) + (clamp(dot(calcNormal(mr.p), ld), 0.0, 1.0)*0.1);
  }
  
  
  
  col += glow *0.1;
  
  vec4 pcol = vec4(0.0);
  vec2 puv = vec2(20.0/v2Resolution.x, 20.0/v2Resolution.y);
  vec4 kertoimet = vec4(0.1531, 0.12245, 0.0918, 0.051);
  pcol = texture(texPreviousFrame, uv2) * 0.1633;
  pcol += texture(texPreviousFrame, uv2) * 0.1633;
  for(int i = 0; i < 4; ++i){
    pcol += texture(texPreviousFrame, vec2(uv2.x - (float(i)+1.0) * puv.y, uv2.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture(texPreviousFrame, vec2(uv2.x - (float(i)+1.0) * puv.y, uv2.y - (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture(texPreviousFrame, vec2(uv2.x + (float(i)+1.0) * puv.y, uv2.y + (float(i)+1.0) * puv.x)) * kertoimet[i] +
    texture(texPreviousFrame, vec2(uv2.x + (float(i)+1.0) * puv.y, uv2.y + (float(i)+1.0) * puv.x)) * kertoimet[i];
  }
  col += pcol.rgb;
  col *= 0.25;
  
  col = mix(col, texture(texPreviousFrame, uv2).rgb, 0.5);
  
  col = max(col, texture(texInercia2025,vec2(uv2.x,uv2.y*-1.0)).rgb);//,0.3);
  
  col = smoothstep(0.0,1.0,col);

	out_color = vec4(col,1.0);
}