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

 const vec2 ep = vec2(.00035,-.00035);
 const float far=80.;
 
 float box(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
 
 vec2 map(vec3 p) {
   vec2 m1=vec2(box(p,vec3(2,2,2)),1);
   vec2 m2=vec2(box(p,vec3(1,2.5,1)),2);
   vec2 scene = m1.x<m2.x?m1:m2;
   return m1;
 }
 
 vec2 raycast(vec3 rO, vec3 rD){
   vec2 dist,result=vec2(0.);
   for (int i=0;i<128;i++){
        dist=map(rO+rD*result.x);
        if (dist.x<0001||result.x>far) break;
        result.x=dist.x;result.y=dist.y;
   }
   return result;
     
 }
   
void main()
   {
  
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 rO = vec3(0,0,100);
  vec3 cforward = normalize(vec3(0)-rO);
  vec3 cleft = normalize(cross(cforward,vec3(0,1,0)));
  vec3 cup = normalize(cross(cleft,cforward));
  vec3 rD= mat3(cleft,cup,cforward)*normalize(vec3(uv,.5));
  vec3 lightD = normalize(vec3(-.1,.4,.3));
  vec3 backgroundColor=vec3(.1,.1,.1)-length(uv)*.1;
  vec3 color=backgroundColor;
  vec2 result=raycast(rO,rD);
  if(result.x<far){
    vec3 hitPos=rO+rD*result.x;
    vec3 normals=normalize(ep.xyy*map(hitPos+ep.xyy).x+ep.yyx*map(hitPos+ep.yyx).x+ep.yxy*map(hitPos+ep.yxy).x+ep.xxx*map(hitPos+ep.xxx).x);
    vec3 albedo=vec3(.5,.5,.5);
    
    if(result.y<1.) albedo=vec3(.0,.0,.0);
    float diffuse=max(0.,dot(normals,lightD));
    float fresnel=min(1.,pow(1.+dot(normals,rD),4.));
    float specular=pow(max(dot(reflect(-lightD,normals),-rD),0.),30.);
    float ao = clamp(map(hitPos+normals*.1).x/.1,0.,1.);
    float sss=smoothstep(0.,1.,map(hitPos+lightD*.4).x/.4);
    color=mix(specular+albedo*(ao+.2)*(diffuse+sss*.5),backgroundColor,fresnel);
    color=mix(backgroundColor,color,exp(-.0001*result.x*result.x*result.x));
  
  }
	out_color =vec4(pow(max(color,0.),vec3(.4545)),1);
}