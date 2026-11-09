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
uniform sampler2D texKolmio;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

const float E = 0.001;
const float FAR = 100.0;
const int STEPS = 128;

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.2).r;
float fft2 = texture(texFFTSmoothed, 0.2).r;
vec3 glow = vec3(0);


float sphere(vec3 p, float r){
  return length(p)-r;
}

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0))+min(max(d.x, max(d.y, d.z)), 0.0);
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)*vec2(-p.y, p.x);
}

float scene(vec3 p, vec3 ro, vec3 rd){
  vec3 pp = p;
  float fpp= texture(texFFT,pow(abs(p.z*.09),1.5)).r;
  float keski = sphere(pp,.8*(.5+fpp*3));
  float pallo = box((pp-ro)*rd,vec3(1));
  rot(pp.xy, time*0.1);
  rot(pp.yz, time*0.05);
  for(int i = 0; i < 7; ++i){
    pp = abs(pp)-vec3(0.8, 0.3, 0.8);
    rot(pp.xy, time*0.05+fft*0.1);
    rot(pp.yz, time*0.01+fft*0.1);
    pp = abs(pp)-vec3(0.1*i, 0.3, 0.1*i);
  }
  
  
  float d = distance(p, pp);
  float sp = box(pp, vec3(d*0.05, d*0.04, d*0.02)*(vec3(1+fft2*40)));
  
  vec3 g = vec3(.1)*0.01 / (abs(sp)+0.05);
  glow += g;
  
  sp = abs(sp*0.5);
  
  return max(min(sp,keski),-pallo);
}

float march(vec3 ro, vec3 rd){
  float t = E;
  vec3 p = ro;
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p,ro,rd);
    t += d;
    p = ro + rd * t;
    if(d <= E || t >= FAR){
      break;
    }
  }
  return t;
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

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 zom = uv;
  vec2 kzom = uv;
  //uv=floor(uv/(sin(time*.2)*.02))*(sin(time*.2)*.02);

	vec2 q = uv -0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3(2+sin(time*.05)*4, 0, cos(time*.05)*4); 
  vec3 rt = vec3(0, 0, 0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0, 1, 0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(q, 1/radians(90.0)));
  
  float t = march(ro, rd);
  vec3 p = ro+rd*t;
  float dis = distance(ro,p);
  
  float fy = texture(texFFTSmoothed, pow(abs(p.y*.4),3)*.2).r*20;
  float fx = texture(texFFTSmoothed, pow(abs(p.x*.4),3)*.2).r*20;
  float fz = texture(texFFTSmoothed, 0.08).r*10;
  
  
  zom-=vec2(.5);
  zom*=vec2(1-fz*2);
  zom+=vec2(.5);
  
  kzom-=vec2(.75);
  kzom*=vec2(1-fz*8);
  kzom+=vec2(.75);
  
  
  vec3 col = vec3(0.,0.,0.02);
  if(t < FAR){
    col = vec3(0.1);
  }
  
  glow*=vec3(abs(rd.x*2+.5*sign(rd.y*4+5)),0.2, (rd.y*4+2)+0.6);
  
  col += dis*0.02;
  col += glow*(.4+(fy*fx)*4);
  
  vec3 hs = rgb2hsl(col);
  
  hs.x+=time*.02+dis*.04;
  hs.y=0.5;
  hs.z-=dis*.1;
  hs.z=clamp(hs.z,0,1);
  
  col = hsl2rgb(hs);
  
  col = smoothstep(-0.1, 1.2, col);
  
  vec3 prev = texture(texPreviousFrame, zom).rgb;
  
  col = mix(col, prev, 0.2)+prev*.2;
  //col *= vec3(kolmio);
  
	out_color =vec4(col, 1);
  
}