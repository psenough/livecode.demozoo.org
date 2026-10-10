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
uniform sampler2D texChecker;
uniform sampler2D texCreative;
uniform sampler2D texEvilbotTunnel;
uniform sampler2D texEwerk;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texST;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 tex(sampler2D tx,vec2 uv) {
    return texture(tx,clamp(uv*vec2(1,-1),-.5,.5)-.5);
}
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float angle_from(vec2 uv, vec2 pos){
  vec2 uvp = normalize(uv-pos);
  float a = dot(uvp, vec2(0.0,-1.0))/2+0.5;
  return a;
}

void main(void)
{
    float timeloop = float(int(fGlobalTime * 1000) % 1000)/1000.0;
    vec2 screen = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    vec2 uv = screen - 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
    float fftTime = texture(texFFTIntegrated, 0.1).x*0.5;
  
    vec2 sunpos = vec2(0.2*cos(fftTime/5.0), 0.2*sin(fftTime/7.0)+0.2 - texture(texFFTSmoothed, 0.05).x*0.75);
    vec3 viewray = normalize(vec3(uv.x - sunpos.x,uv.y - sunpos.y,1));
  
  
    float angle = angle_from(uv, sunpos);
  
    //vec3 col = (angle > 0.595 && angle < 0.6) ? vec3(1) : vec3(0); 
  
    // sun
    
    float c = (length(uv-sunpos)) - 10*texture(texFFTSmoothed, angle/2+0.2).x*(sqrt(angle))+0.25;
    float smoothc = smoothstep(1,0,(c-0.5)*50);
  
    float l = pow(smoothstep(0,1,length(uv-sunpos)*3),10);
  
    float sunmask = (smoothc < 0.95) ? 1.0 : 0.0;
    vec3 basecol = (1-l)*vec3(1,0,0) + l*vec3(1,1,0.2);
  
    vec3 skycol = (1-screen.y) * vec3(0,0.5,1.0) + screen.y * vec3(0,0,1);
  
    vec3 col = smoothc*basecol + sunmask * skycol;
    
  
    //float r = 0;//(screen.y < texture(texFFT, screen.x).x ? 1 : 0);
    //float g = 0;//(screen.y < texture(texFFTSmoothed, screen.x).x ? 1 : 0);
    //float fftChange = texture(texFFTSmoothed, abs(screen.x-0.5)).x - texture(texFFT, abs(screen.x-0.5)).x;
    //float b = (screen.y < fftChange+0.25 ? 1 : 0) + 0.75*pow(texture(texPreviousFrame, screen-vec2(0,0.005)).b,2);
    //vec4 col = vec4(b,b,b, 1.0);
    
    float plane_h = -0.75;
    
    //if(viewray.y < -0.001){
      //float plane_intersect = plane_h / viewray.y;
      float p_low = 0.0;
      float p_high = 100.0;
      float p = (p_low+p_high)/2;
      vec3 ray = viewray * p;
      for(int i=0; i<32; i++) {
        ray = viewray * p;
        float s = texture(texNoise, ray.xz/5 + vec2(0,fGlobalTime/5)).x + 2*texture(texFFTSmoothed, ray.x*0.1+0.3).x;
        if(ray.y < s + plane_h) {
          p_high = p;
        } else {
          p_low = p;
        }
        p = (p_low+p_high)/2;
      }
      if(p < 99.0)col = (1-1/ray.z)*col + (1/ray.z) * vec3(0.9, 0.9, 1.0);
    //}
  
    
    out_color = vec4(sqrt(col), 1.0);
}