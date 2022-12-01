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

float time = fGlobalTime;
int id = 0;
float offset = 0.0;

#define FAR 40.0
#define STEPS 30
#define E 0.001

void rot(inout vec2 p, float a){
  p = sin(a)*p + cos(a)*vec2(p.y, -p.x);
}

float kuutio(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return max(max(d.x, d.y), d.z);
}

float pallo(vec3 p, float r){
  return length(p)-r;
}

float scene(vec3 p){
  vec3 pp = p;
  rot(pp.xy, time);
  float k = -kuutio(pp, vec3(2.0, 2.0, 2*FAR));
  rot(pp.yz, time*2.0);
  float b = pallo(p, 0.8);
  float kk = kuutio(pp, vec3(0.85));
  offset = length(texture(texNoise, sin(pp.xy+time)).rgb*0.5 + texture(texTex2, sin(pp.xz+time)).rgb*0.3);
  b -= offset;
  //b -= texture(texFFTIntegrated, b+time).r*0.001;
  
  //b = max(b, -kk);
  
  
  if(b < k){
    id = 1;
  }
  else{
    id = 0;
  }
  
  
  return min(b, k);
  
}


vec3 march(vec3 ro, vec3 rd){
  vec3 p = ro;
  float t = E;
  
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    p += d*rd;
    
    if(d < E || t > FAR){
      break;
    }
  }
  
  vec3 col = vec3(0.0);
  if( t <= FAR){
    col = vec3(0.8, 0.3, 0.5);
    
    float m = mod(p.z+time*8.0, 8.0)-4.0;
    if(m > 0.0 && m > 2.0){
      col = col.bgr;
    }
    else if(m < 0.0 && m < -2.0){
      col = col.gbb;
    }
    /*else if((m > 0.0 && m > 1.0) ||(m < 0.0 && m < -1.0)){
      col = vec3 (0.0);
    }*/
    if(id == 1){
      col = vec3(0.4, 0.2, 0.5);
    }
  }
  float f = texture(texFFTSmoothed, pallo(p, 0.8)-offset).r*500.0;
  return col*t*0.5 * (f+vec3(0.2, 0.6, 0.6));
}

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv = -1.0 + 2.0*uv;
  uv.x *= v2Resolution.x/v2Resolution.y;
  
  vec3 ro = vec3(0.0, 0.0, 6.5-mod(time, 4.0));
  vec3 rt = vec3(0.0, 0.0, -FAR);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0.0, 1.0, 0.0)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z)*vec3(uv, radians(50.0)));
  vec3 col = march(ro, rd);
  
  
  /*uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1 / length(uv) * .2;
  float d = m.y;

  float f = texture( texFFT, d ).r * 100;
  m.x += sin( fGlobalTime ) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );*/
  
  col = smoothstep(0.2, 0.9, col);
  col = pow(col, 1.0/vec3(2.2));
  out_color = vec4(col, 1.0);//f + t;
}