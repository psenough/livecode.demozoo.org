#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAmiga;
uniform sampler2D texAtari;
uniform sampler2D texC64;
uniform sampler2D texDritterLogo;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

#define PI 3.1456789034455

mat2 rot(float a)
{
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

//vec3 getEnv


float opSmoothUnion(float d1, float d2, float k)
{
    k *= 4.0;
    float h = max(k -abs(d1-d2), 0.0);
    return min(d1,d2) - h *h *0.25/k;
}



float map(vec3 p)
{
    
    vec3 pos = p;
    float rep = 5 * sin(fGlobalTime);
    p.x += sin(fGlobalTime) * 2;
    float rep2 = 3;
  
    p.xy *= rot(PI *sin(fGlobalTime)*2);
    p.xy = mod(p.xy +.5 * rep, rep) - .5 *rep;
    
  
    if (p.z > 0.)
    {
      p.z = mod(p.z +.5 * rep2, rep2) - .5 *rep2;  
    }
    float acc = 10000.; 
  
    float s = length(p)-1;
    
    float s2 = length(p + vec3(sin(fGlobalTime +345675) * 7, sin(fGlobalTime) * 5, cos(fGlobalTime +332) * 1))-1;
    
    float u = opSmoothUnion(s, s2, 1);
    
    //acc = min(acc, s);
    //acc = min(acc, s2);
    acc = min(acc, u);
    return acc;
}

vec3 getNorm(vec3 p)
{
    vec2 e = vec2(0.01, 0);
    return normalize(
    vec3(map(p))-
    vec3(map(p - e.xyy), map(p - e.yxy), map(p - e.yyx))
    );
}


vec3 render(vec2 uv)
{
    vec3 col = vec3(0.);
    vec3 ro = vec3(0, 0, -5);
  
    vec3 rd = normalize(vec3(uv, 1));
    vec3 p = ro;
  
    vec3 lightPos = ro;
    lightPos.y += 5; 
    lightPos.z += 1;
  
  
    for (int i=0; i<128; i++)
    {
        float dist = map(p);
      
        vec3 lightDir = normalize(p - lightPos);
        if (dist < 0.01)
        {
          col = vec3(1);
          vec3 n = getNorm(p);
          col = n *.5 +.5;
          col *= dot(n, lightDir) * 10;
          col += -n;
          break;
        }
        p+= rd *dist;
      
    }
    return col;
}


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
  
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	//t = clamp( t, 0.0, 1.0 );
  
  vec3 col = render(uv);
  //out_color = vec4(col, 1) +t;
  out_color = vec4(col, 1);

}