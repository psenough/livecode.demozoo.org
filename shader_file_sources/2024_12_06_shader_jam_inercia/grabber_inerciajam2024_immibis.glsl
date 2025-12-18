#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

uniform sampler2D texInerciaLogo2024;
uniform sampler2D texNoise;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x*b.x - a.y*b.y, a.x*b.y + b.x*a.y);
}
vec2 cpow(vec2 z, float power) {
  float theta = atan(z.y,z.x);
  float r = length(z);
  r = pow(r, power);
  theta *= power;
  return vec2(cos(theta),sin(theta))*r;
}
mat2 rot(float angle) {
  return mat2(vec2(cos(angle),sin(angle)),vec2(-sin(angle),cos(angle)));
}
vec2 noise2d(vec2 xy) {
  return (vec2(texture(texNoise,xy).x, texture(texNoise, xy+vec2(0,0.15)))-0.25);
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  if(uv.y < texture(texFFT, uv.x).x) {out_color = vec4(1,0,0,0); return;}
  uv -= 0.5;
  //if(uv.y > 0) uv.x = -uv.x;
  //if(uv.x > 0) uv.y = -uv.y;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //uv.x += texture(texFFTIntegrated, (uv.y+0.5)*5).x;
  //uv.x += texture(texFFT, mod((uv.y+0.5)*5,0.7)+0.3).x*100;
  //uv.x = mod(uv.x, 1);
  
  bool outside = false;
  {
    vec2 c = uv;
    //c.x *= 1.5; c.y *= 2; c.x -= 0.5;
    c *= 2;
    //c = rot(fGlobalTime)*c;
    vec2 z = c;
    out_color = vec4(0,0,0,0.95);
    // threshold seems to be 0.2 on the grabber but 0.1 on my machine
    if(texture(texFFT, 0.02).x > 0.1 && texture(texPreviousFrame, vec2(0.5)).r < 0.3) {
      out_color = vec4(1,1,1,0.9);
      // hexagonal dot pattern commented out
      /*vec2 test = mod(uv, 0.05)-0.025;
      if(mod(uv.y, 0.1) > 0.05) {
        test.x += 0.025;
        test.x = mod(test.x+0.025, 0.05)-0.025;
      }
      if(length(test) < 0.01) out_color.rgb = vec3(0,0,1);*/
      
      /*vec4 logocol = texture(texInerciaLogo2024, uv*vec2(1,-1)*1.5-0.5);
      if(dot(logocol.rgb, vec3(1)) > 0.1) {
        out_color = logocol;
        out_color.a = 0;
      }*/
      
    }
    c = rot(fGlobalTime*4)*c;
    for(int i = 0; i < 100; i++) {
      //z = vec2(z.x*z.x-z.y*z.y,2*z.x*z.y)+c;
      //z = cpow(z, 4+mod(int(fGlobalTime),5)*2) + c;
      z = cpow(z, 4+sin(fGlobalTime)) + c;
      
      if(length(z) > 10) {
        float x = sin(float(i)/100.0*3.14);
        //out_color = vec4((float(i)/80.0).xxx,0.95);
        out_color = vec4(sin(x), 0, cos(x), 0.95);
        outside = true;
        
        vec2 greenuv = noise2d(uv);
        out_color.g = texture(texFFT, atan(greenuv.y,greenuv.x)/3.14/2-fGlobalTime).x*30;
        //out_color.g = 1;
        
        break;
      }
      //z += (texture(texNoise, z).xy-0.2)*0.005;
    }
    
    if(outside) {
      vec4 logocol = texture(texInerciaLogo2024, normalize(z));
      //logocol.a = 1;
      out_color += (logocol - out_color)*0.5;
    }
  }
  
  vec2 readpos = gl_FragCoord.xy/v2Resolution.xy;
  readpos -= 0.5;
  if(!outside) readpos *= 1.02;
  else readpos /= 1.005;
  float noiseamt = texture(texFFT, 0.02).x*0.5+0.01;
  readpos += noise2d(uv+fGlobalTime)*noiseamt;
  readpos *= rot(texture(texFFT, 0.01).x*0.1 - texture(texFFT, 0.03).x*0.2);
  //readpos *= pow(length(readpos),-0.03);
  readpos += 0.5;
  vec4 oldcol = texture(texPreviousFrame, readpos);
  oldcol.rgb *= oldcol.a; // allows a previous round to set alpha to indicate how much it should fade on the next frame
  if(dot(oldcol.rrb,vec3(1)) > dot(out_color.rrb,vec3(1))) {
    out_color = oldcol;
    out_color.a = oldcol.a;
  }
}