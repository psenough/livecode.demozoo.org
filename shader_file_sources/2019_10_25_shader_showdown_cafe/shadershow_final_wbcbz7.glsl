#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
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


float t = fGlobalTime;


int ca[22*7] = int[22*7](
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0,
0,1,0,0,0,0,1,0,0,1,0,1,0,0,0,0,1,0,0,0,0,0,
0,1,0,0,0,0,1,1,1,1,0,1,1,1,0,0,1,1,1,1,0,0,
0,1,0,0,0,0,1,0,0,1,0,1,0,0,0,0,1,0,0,0,0,0,
0,1,1,1,1,0,1,0,0,1,0,1,0,0,0,0,1,1,1,1,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
);

// RE+_RERECYCLIIIIING GHAHAHAHAHAHAHAHAHAHAHAHHAHAHAHAHAH

void main(void)
{
  vec2 uvraw = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  uvraw.x += 2.6*texture(texFFT, 0.3).r * mod(int(uvraw.y*36.4), 3);
  uvraw.y += 1.6*texture(texFFT, 0.1).r * mod(int(uvraw.x*23.4), 3);
  
  
  vec2 uv = uvraw - 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  
  vec3 acc = vec3(0.0);
  
  for (int i = 0; i < 3*3; i++) {
      
    float color;
    
      if (mod(fGlobalTime, 5.4) < 1.5) 
      
      
        color = mod((uv.x+uv.y + t) * 2.5, 1.0) < 0.5 ? 1.0 : 0.0;
    
      else if (mod(fGlobalTime, 2.4) < 1.5) 
        color = mod((abs(uv.x)*abs(uv.y) + t) * 5.5, 1.0) < 0.5 ? 1.0 : 0.0;    
      
      else 
        color = mod((abs(uv.x)+abs(uv.y) + t) * 5.5, 1.0) < 0.5 ? 1.0 : 0.0;    
      
      
      
      acc += vec3(color) * (0.45 + 0.8 * vec3(0.6*mod(int(uvraw.y*366.4), 3), 0.27*mod(int(uvraw.y*35.4), 3), 0.9*mod(int(uvraw.y*23.4), 3)));      
  }
    
  if (mod(fGlobalTime, 0.9) < 0.2) 
    acc *= 0.1+(0.2*float(ca[int((1-uvraw.y) * 7)*22 + int(uvraw.x * 22)])); 
  else
    acc *= 0.01 + (0.2*float(ca[int((1-uvraw.y) * 7)*22 + int(uvraw.x * 22)])); 
  
  
  acc = acc * (1.0 / 3*3) * (1.0 - 0.6*dot(uv, uv));  
  
  
  // vingette
  out_color = vec4(acc, 1.0);
  
  
  
  
  /*
  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1 / length(uv) * .2;
  float d = m.y;

  float f = texture( texFFT, d ).r * 100;
  m.x += sin( fGlobalTime ) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );
  out_color = f + t;
  */
  
  
  
}

// RIGHT