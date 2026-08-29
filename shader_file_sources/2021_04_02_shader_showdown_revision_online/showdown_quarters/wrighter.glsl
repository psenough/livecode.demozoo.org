#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

#define iTime fGlobalTime

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
uniform sampler2D texTex5;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define kicka fGlobalTime/60.*178
#define kick kicka*(1. - 2*float(fract(kicka/4)<0.25))
vec3 pal(float m){
  vec3 c = vec3(
    0.5 + 0.5*sin(m + 0.5),
    0.5 + 0.5*sin(m),
    0.5 + 0.5*sin(m - 0.5)
  );
  c = pow(c,vec3(4));
  return smoothstep(0.,1.,c);
}
#define pmod(p,a) mod(p,a) - 0.5*a

#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 col = vec3(1);
  
  float pxSz = fwidth(uv.x);

  float k = pow(fract(kick),6) + floor(kick);
  {
    float md = 0.06;
    vec2 p = uv;
    p.y += iTime*0.1;
    vec2 id = floor(p/md);
    p = pmod(p,md);
    
    float d = 0.;
    
    float s = 0.01 * sin(id.x*20. + cos(id.y*15.) + id.y + iTime + k);
  
    p *= rot(s*112.);
    d = abs(p.x) - s*0.2;
    d = min(d,abs(p.y) - s*0.2);
    
    d = max(d,length(p) - 2.*s);
    
    col = mix(col,vec3(0),smoothstep(pxSz,0.,d));
  }
  
  {
    float md = 0.3;
    vec2 p = uv;
    p.y += iTime*0.1;
    float id = floor(p.y/md);
    p.y = pmod(p.y,md);
    
    float d = 0.;
    
    p.y += sin(id);
    p *= rot(sin(id*20.));
    d = p.x;
    
    col = mix(col,1-col,smoothstep(pxSz,0.,d));
  
  }
  {
    for(float i = 0; i < 50; i++){
      vec2 p = uv + vec2(sin(i*10.),
        .5 - 2.5*mod(0.1*iTime*(1. + sin(i)*0.8),1.)
      );;
      float s = 0.01 * sin(i*20. + cos(i*15.) + i + iTime + k);
  
      float d = length(p) - s*25.;
      
      col = mix(col,1-col,smoothstep(pxSz,0.,d));  
    }
    
  }
  
  {
    for(float i = 50; i < 100; i++){
      vec2 p = uv + vec2(sin(i*10.),
        .5 - 2.5*mod(0.1*iTime*(1. + sin(i)*0.8),1.)
      );;
      float s = 0;
      
      p.x += sin(p.y*(10. + sin(i*5)*9.) + i + iTime*5.)*0.04;
      float d = length(p.x) - 0.006;
      
      d = max(d,abs(p.y) - 0.1);

      
      d /= fwidth(d);
      col = mix(col,pal(i*20. + p.y*45. + iTime*4.),smoothstep(1.,0.,d));  
    }
    
  }
  #define tsin(a) asin(sin(a))
  
  {
    for(float i = 100; i < 120; i++){
      vec2 p = uv + vec2(sin(i*10.),
        .5 - 2.5*mod(0.1*iTime*(1. + sin(i)*0.8),1.)
      );;
      vec2 op = p;
      float s = 0;
      
      p.x += tsin(p.y*(10. + tsin(i*5)*4.) + i + iTime*5.)*0.04;
      float d = length(p.x) - 0.106;
      
      d = max(d,abs(p.y) - .3);

      
      d /= fwidth(d);
      
      float od;
      {
        op *= rot(0.4);
        op.y = pmod(op.y,0.005);
        od = abs(op.y) - 0.001;
        
      }
      col = mix(col,vec3(0),smoothstep(pxSz,0.,od)*smoothstep(1.,0.,d));  
    }
    
  }
  
  vec2 ouv = gl_FragCoord.xy / v2Resolution.xy;
	
  vec3 pf = vec3(
    texture(texPreviousFrame,ouv + 0.003).x,
    texture(texPreviousFrame,ouv).y,
    texture(texPreviousFrame,ouv - 0.001).z
  );
  
  col = mix(col,pf,0.01 +texture( texFFT,0.1).x + pow(fract(kick),4) );
	out_color = vec4(col,1);
}