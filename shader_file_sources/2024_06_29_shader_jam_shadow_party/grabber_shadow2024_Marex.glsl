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

float fractal(vec2 c){
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.7;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;

  
  const float B = 256.0;
  
  float n = 0.0;
  vec2 z = c;
  float maxIter = 200.;
  
  for(float i = 0.; i<maxIter; i++){
    
    z= vec2(z.x * z.x - z.y * z.y , sin(fGlobalTime)/50+2.1 * z.x * z.y)+ vec2(-.8,.156);
    
    if(dot(z,z)>(B*B) ) break;
    n += 1.0;
    
    if( z.x * z.x + z.y *z.y >10000.){
      
      return i/maxIter;
      
      }
    
    }
  
    float sn = n -log(log(length(z))/log(B))/log(.0);
    
    return sn;
    
    return 1.;
    
  }

mat2 R2d(float r){return mat2(cos(r),-sin(r),sin(r),cos(r));}

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

  vec2 R2d = uv*R2d(ceil(fGlobalTime*1.1));
  
  
  vec2 p = f*0.0001*(gl_FragCoord.xy -.5 * vec2(v2Resolution.x,v2Resolution.y))/1000.;
  
  float sn =fractal(p-R2d);
  
  vec3 col = 0.5 + 0.5 * cos(fGlobalTime+ uv.xyx+vec3(0,3,3));
  vec3 col2 = vec3(f)*2.;
  
  float color = fractal(p-R2d*sn);
  
  vec3 color2 = vec3(color);
  
  vec3 color3 = vec3(f)*4.;
  
  vec3 color4 = min(color2,color2);
  
  vec3 final =min(col,color4);
  
	out_color =vec4(final,0.);
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////THANKS YOU EVVVVIL//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////