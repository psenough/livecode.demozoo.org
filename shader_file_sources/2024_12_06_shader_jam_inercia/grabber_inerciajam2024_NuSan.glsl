#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time=fGlobalTime;

vec4 alphercia(vec2 uv)
{
  vec4 al=texture(texInerciaLogo2024, uv);
  al.w = smoothstep(0.3,0.,dot(al.xyz,vec3(1)));
  return al;
}

// 26 letters + some numbers
const int Letters[31] = int[31](23535,31471,25166,31595,29391,4815,31310,23533,29847,13463,23277,29257,23423,23403,15214,5103,26474,23279,14798,9367,27501,12141,32621,23213,31213,29351,31727,448,5393,29671,31599);
// Pico 8 palette
const vec3 Pal[16] = vec3[16](vec3(0),vec3(0.125,0.2,0.48),vec3(0.494,0.145,0.325),vec3(0,0.513,0.192),
                              vec3(0.74,0.321,0.211),vec3(0.27),vec3(0.76,0.764,0.78),vec3(1,0.945,0.91),
                              vec3(1,0,0.3),vec3(1,0.639,0),vec3(1,0.925,0.153),vec3(0,0.886,0.196),
                              vec3(0.16,0.678,1),vec3(0.513,0.463,0.611),vec3(1,0.467,0.659),vec3(1,0.8,0.667));

int textcolor=7;
int backcolor=0;
// print up to 6 characters encoded as an int (5 bits per character)
void String6(inout vec3 col, inout vec2 uv, int val) {
    float a = 0.;
    uv = floor(uv);
    for(int i=0; i<6; ++i) {
        int cdig = int(val)%32;
        if(cdig!=0) {
			vec2 mask = step(abs(uv-vec2(1.3,2.5)),vec2(1.5,2.5));
			a += float((Letters[cdig-1]>>int(uv.x+uv.y*3.))&1)*mask.x*mask.y;
        }
        uv.x -= 4.;
        val/=32;
    }
    
    if(a>.1) col=Pal[textcolor];
}

// draw a block of text of size textlen, charid is changing for each letter
void DrawText(inout vec3 mcol, inout vec2 muv, int textlen, int charid) {
    if(charid>0) {
        vec2 louv=floor(muv);
        louv.x-=clamp(floor(muv.x/4.)*4.,0.,float(textlen-1)*4.);
        vec2 mask = step(abs(louv-vec2(1.3,2.5)),vec2(1.5,2.5));
        if(float((Letters[charid-1]>>int(louv.x+louv.y*3.))&1)*mask.x*mask.y>.1)
        { mcol=Pal[textcolor]; }
    }

    muv.x -= 4.*float(textlen);
}

void BDrawText(inout vec3 mcol, inout vec2 muv, int textlen, int charid) {
    if(charid>0) {
        vec2 louv=floor(muv);
        louv.x-=clamp(floor(muv.x/4.)*4.,0.,float(textlen-1)*4.);
        vec2 mask = step(abs(louv-vec2(1.3,2.5)),vec2(1.5,2.5));
        vec2 mask2 = step(abs(louv-vec2(1.3,2)),vec2(2.5,3.5));
        if (mask2.x*mask2.y>.1) mcol=Pal[backcolor];
        if(float((Letters[charid-1]>>int(louv.x+louv.y*3.))&1)*mask.x*mask.y>.1)
        { mcol=Pal[textcolor]; }
    }

    muv.x -= 4.*float(textlen);
}

float rnd(float t) {
  return fract(sin(t*234.123)*743.253);
}
vec3 rnd(vec3 t) {
  return fract(sin(t*234.123+t.yzx*435.234+t.zxy*743.644)*743.253);
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

int pal(vec3 col) {
  float dist=999.;
		int best=0;
		// finding closest color from the palette
		for(int i=0;i<16; ++i) {
			float cur=length(max(col,0.)-Pal[i]);
			if(cur<dist) {
				dist=cur;
				best=i;
			}
		}
	return best;
}

vec3 palcol(vec3 col) {
  return Pal[pal(col)];
}

#define ilist int[]
#define color(cc) textcolor=cc;
#define back(cc) backcolor=cc;
#define starttext(base) {vec2 baseuv=base; vec2 muv=base; int _=0; int a=1; int b=2; int c=3; int d=4; int e=5; int f=6; int g=7; int h=8; int i=9; int j=10; int k=11; int l=12; int m=13; int n=14; int o=15; int p=16; int q=17; int r=18; int s=19; int t=20; int u=21; int v=22; int w=23; int x=24; int y=25; int z=26;
#define newline() baseuv-=vec2(0.,6.); muv=baseuv;
#define text(tab) { int textlen=tab.length(); int ni=clamp(int(muv/4.),0,textlen-1); DrawText(mcol, muv, textlen, tab[ni]); }
#define btext(tab) { int textlen=tab.length(); int ni=clamp(int(muv/4.),0,textlen-1); BDrawText(mcol, muv, textlen, tab[ni]); }
#define endtext() }

float box(vec3 p, vec3 s) {
    p=abs(p)-s;
  return max(max(p.x,p.z),p.y);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)),rnd(floor(t)+1),pow(smoothstep(0,1,fract(t)), 10.0));
}

vec3 amb=vec3(0);
float map(vec3 p) {
  
  for(int i=0; i<3; ++i) {
    p.xz *= rot(curve(time,0.2+i*0.123));
    p.xy *= rot(time*0.3);
    p=abs(p)-0.4;
  }
  
  float d = box(p, vec3(0.3));
  
  
  amb += vec3(1.6,0.4,0.2) * 0.04/(0.3+abs(d));
  
  p=abs(p)-3;
  float d2=length(p.xz);
  d2=min(d2, length(p.xy));
  d2=min(d2, length(p.zy));
  d=min(d,d2);
  amb += vec3(0.3,0.4,2.0) * 0.02/(0.3+abs(d));
  
  return d;
}

void cam(inout vec3 p) {
    p.yz *= rot(time*0.2);
    p.xy *= rot(time*0.3);
}

vec4 pico( vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord)/v2Resolution.y;
    uv.y=1.-uv.y;
    vec2 muv = floor(uv*128.0) - vec2(64.0,10.0);
    vec2 mask2 = fract(uv*128.0);
    float mask3 = max(mask2.x,mask2.y);
    float mask = 0.5+0.5*smoothstep(0.,0.3,min(mask3,1-mask3));
    
    vec2 buv = muv/128.0-0.5;
    vec3 mcol=vec3(0);

    // Time varying pixel color
    //vec3 mcol = 0.5 + 0.5*cos(time+muv.xyx*0.03+vec3(0,2,4))*vec3(1,0.3,0.2);
    float fac=1+sin(time*0.14)*0.3;
    vec4 al=alphercia(muv*rot(sin(time*0.2)*0.4)*0.007*fac+fGlobalTime*0.07);
    mcol*=al.w;
    mcol+=al.xyz;
  
    vec3 s=vec3(0,0,-10);
    s.y += curve(time,0.1)*0.1;
    s.x += (curve(time,0.7)-0.5)*5;
    float fov = 1+0.5*curve(time,1.2);
    vec3 r=normalize(vec3(buv,fov));
    
    cam(s);
    cam(r);
    
    amb=vec3(0);
    
    vec3 p=s;
    float d=0;
    for(int i=0; i<100; ++i) {
      d=map(p);
      if(abs(d)<0.001) break;
      p+=r*d;
    }
    
    mcol += amb;
    


    if (abs(d)<0.001)
      mcol = vec3(1)*map(p-r);
  
    
    mcol = palcol(mcol+rnd(vec3(muv,0.1))*0.2);
  
  
    starttext(muv-vec2(24,10))
    color(7)
    text(ilist(h,e,l,l,o,_,w,o,r,l,d))
    newline()
    color(int(time*20)%16)
    text(ilist(j,a,m,i,n,g,_,i,s,_,c,o,o,l))
    newline()
    newline()
    color(int(time*5.+floor(muv/4.0))%16)
    muv.y+=sin(time+uv.x*5.0)*4.0;
    btext(ilist(i,n,e,r,t,i,a))
    baseuv.x+=4*14;
    baseuv.y-=4*12;
    newline()
    newline()
    btext(ilist(t,h,e,_,s,h,a,d,e,r,_,r,o,y,a,l,e,_,j,a,m,_,w,i,l,l,_,b,e,_,u,s,i,n,g,_,b,o,n,z,o,m,a,t,i,c))
    newline()
    newline()
    muv.x+=fract(time/10)*80;
    back(13)
    color(int(floor(muv/4.0))%3+8)
    btext(ilist(i,n,e,r,c,i,a,_,w,i,l,l,_,t,a,k,e,_,p,l,a,c,e,_,i,n,_,d,e,c,e,m,b,e,r,_,a,t,_,s,a,l,a,o,_,f,e,s,t,a,s,_,i,n,c,r,i,v,e,l,_,a,l,m,a,d,e,n,s,e))
    endtext()
    
    mcol *= mask;

    // Output to screen
    return vec4(mcol,1.0);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec4 glow=vec4(0);
  for (int i=-3; i<=3; ++i) {
    for (int j=-3; j<=3; ++j) {
      vec2 buv=gl_FragCoord.xy + vec2(i,j);
      vec4 cur = texture(texPreviousFrame, buv / v2Resolution.xy);
      glow += cur * 0.1;
    }
  }
  
  out_color = pico(gl_FragCoord.xy);
  
  vec4 prev = texture(texPreviousFrame, gl_FragCoord.xy / v2Resolution.xy);
  
  //out_color = mix(out_color, prev, 0.2);
  out_color *= 0.8;
  out_color += glow*0.03;
}