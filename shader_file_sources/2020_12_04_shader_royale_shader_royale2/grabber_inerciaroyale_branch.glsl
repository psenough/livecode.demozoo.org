#version 410 core
uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing

#define iTime fGlobalTime
#define iResolution v2Resolution
#define fragCoord gl_FragCoord
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float sdSphere(vec3 p, float s){ 
  return length(p) - s;
}
float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p) {
  float d = 1e10;
  float t= mod(iTime,20.);
  for(float i=1.0; i < 24.; i++) {
    p.z *= 0.1;
    if(t<5.0) {
      p.x += sin(p.z * 12. + iTime + i) * i;  // state 0
      p.y += cos(p.z * 12. + iTime + i) * i;  // state 1
      d = min(d, sdSphere(p, 0.5 + sin(i * 12. + iTime + p.z) + texture(texFFTSmoothed,0.3).x*12.));
    }
    else if(t<10.0) {
      float angle = i/32. + (p.z * 12.) * 0.2;
      float s= sin(angle);
      float c =cos(angle);
      mat2 rotMat = mat2(c,s,-s,c);
      p.xy *= rotMat;
      p.x += sin(p.z * 12. + iTime + i) * i;  // state 0
      p.y += cos(p.z * 12. + iTime + i) * i;  // state 1
      
      d = min(d, sdBox(p, vec3(    0.2 + sin(i * 3. + iTime + p.z)  )  + texture(texFFTSmoothed,0.1).x*0.3  ));
    } 
    else if(t<15.0) {
      float angle = i/32. + (p.z * 12.) * 0.2;
      float s= sin(angle);
      float c =cos(angle);
      mat2 rotMat = mat2(c,s,-s,c);
      p.xy *= rotMat;
      p.x += sin(p.z * 12.) * min(p.z*0.2,6.);  // state 0
      p.y += cos(p.z * 12.) * min(p.z*0.2,6.);  // state 1
      
      d = min(d, sdBox(p, vec3(    0.2 + sin(i * 3. + iTime + p.z) + texture(texFFTSmoothed,0.3).x*1.2 )   ));
    } else {
      p.x += sin(p.z * 12. + iTime + i);  // state 0
      p.y += cos(p.z * 12. + iTime + i) * i * 0.2;  // state 1
      d = min(d, sdSphere(p, 0.5 ));
    }
    
  }
  return d;
}

float rand(vec2 c) {
  return fract(sin(dot(c.xy,vec2(12.9898,78.233))) * 41231.51222); 
  //i don't remember exactly... hopefully this is good enough
  
}
void main(void)
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5 ;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
  vec2 uv2=uv;
  float vessa = mod(iTime*2.,13.121);
  if(vessa<3.0) { 
    uv += 0.333;
  }
  if(vessa>10.0) { 
    uv -= 0.333;
  }
  float kickoff = floor(mod(iTime,12.0)); 
  if(kickoff < 2.) { 
    kickoff = 12.;
  }
  if(kickoff < 4.) { 
    kickoff = -1.;
  }
  if(mod(iTime*0.6,12.0)<3.0) { 
    float angle = rand(floor(uv*1.5 + 0.5)) * 3. + iTime * 4.;
    float s= sin(angle);
    float c =cos(angle);
    mat2 rotMat = mat2(c,s,-s,c);
    uv *=rotMat;
  }
  
  
  float vignette = 1.0 / max( 0.25 + 0.9 * dot(uv,uv), 1.0);
  vec3 rayOrigin = vec3(0.);
  vec3 rayDirection = normalize(vec3(uv*(1.333 + 0.5*sin(iTime+length(uv) * 0.2) +  kickoff),1.0));
  vec3 col = vec3(0.0);
  float dist = 0.0;
  float t = 0.01;
  float d;
  vec3 p = vec3(0.0);
  
  
  
  for(int i=0; i <64; i++) {
    p = rayOrigin + t * rayDirection;
    d = map(p);
    t +=d;
    
    
  }
  if(d < 0.01) {
    col = vec3(1.0) * floor(mod(p.z*4. + iTime * 12., 2.0));
    col = mix(col, vec3(0.0), max(0.0, p.z - 2. - texture(texFFT, 0.4).r * 12. ) * 0.05);
  }
  float homer = mod(iTime*0.333 + floor(mod(uv2.x + 0.5,2.0)),4.);
  if(homer<1.0) {
    col = vec3(1.0,0.5,0.7) - col;
  }
  if(homer<2.0) {
    col = vec3(0.5,0.2,0.7) - col;
  }
  if(homer<3.0) {
    col = vec3(0.5,0.7,0.7) * col;
  }
  if(length(uv2.x)<0.80 ) {
    if(length(uv2.x)>0.795) {
      col = vec3(0.15);
    }
  }
  if(length(uv2.y)<0.47 ) {
    if(length(uv2.y)>0.465) {
      col = vec3(0.15);
    }
  }
  if(mod(iTime*12.,4.)<1.0 && mod(iTime,12.) < 2.0) {
    col.r = floor(col.r*3.) / 2.;
    col.g = floor(col.g*3.) / 2;
    col.b  = floor(col.b*3.) / 2;
  }
  out_color = vec4(col,1.0) * vignette + rand(uv2 + mod(iTime*12.,3.0))*0.13 ;
}