#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D black_cat;
uniform sampler2D cream_cat;
uniform sampler2D grey_cat;
uniform sampler2D grey_white_cat;
uniform sampler2D orange_cat;
uniform sampler2D texChecker;
uniform sampler2D texLogo;
uniform sampler2D texMsdf;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D white_cat;








//
//
//
// Konbanwa AEP ! 
// PARTY PARTY, AKIBA~~~~~~ !!
// Ikimashou~~~!!!!
//
//




const float GLYPH_1[212] = float[](
    0.180, 0.437, 0.180, 0.361, 0.180, 0.285, 0.177, 0.209, 0.174, 0.147, 0.170, 0.086,
    0.171, 0.024, -0.095, -0.434, 0.008, -0.368, 0.079, -0.273, 0.119, -0.158, 0.130, -0.125,
    0.139, -0.091, 0.147, -0.056, 0.151, -0.036, 0.151, -0.011, 0.159, 0.008, 0.162, 0.015,
    0.167, 0.019, 0.171, 0.024, 0.435, -0.428, 0.330, -0.364, 0.265, -0.262, 0.226, -0.148,
    0.215, -0.117, 0.190, -0.004, 0.184, 0.008, 0.181, 0.015, 0.176, 0.019, 0.171, 0.024,
    -0.238, -0.436, -0.238, -0.263, -0.233, -0.090, -0.239, 0.083, -0.095, 0.418, -0.096, 0.418,
    -0.098, 0.418, -0.099, 0.419, -0.104, 0.419, -0.108, 0.419, -0.114, 0.422, -0.118, 0.421,
    -0.130, 0.420, -0.231, 0.386, -0.240, 0.381, -0.091, 0.418, -0.092, 0.418, -0.092, 0.418,
    -0.093, 0.418, -0.099, 0.419, -0.100, 0.419, -0.102, 0.419, -0.103, 0.419, -0.240, 0.381,
    -0.232, 0.304, -0.238, 0.223, -0.238, 0.145, -0.240, 0.381, -0.280, 0.382, -0.368, 0.358,
    -0.413, 0.350, -0.123, -0.065, -0.138, -0.041, -0.199, 0.059, -0.216, 0.074, -0.223, 0.080,
    -0.230, 0.081, -0.239, 0.083, -0.238, 0.145, -0.180, 0.145, -0.122, 0.145, -0.064, 0.145,
    -0.238, 0.145, -0.238, 0.145, -0.239, 0.145, -0.239, 0.144, -0.239, 0.144, -0.240, 0.125,
    -0.243, 0.106, -0.244, 0.087, -0.239, 0.144, -0.302, 0.148, -0.365, 0.146, -0.427, 0.145,
    -0.244, 0.087, -0.250, 0.083, -0.256, 0.081, -0.261, 0.075, -0.272, 0.061, -0.295, -0.002,
    -0.305, -0.022, -0.342, -0.098, -0.386, -0.172, -0.440, -0.237, -0.244, 0.087, -0.242, 0.086,
    -0.240, 0.084, -0.239, 0.083, 0.397, 0.209, 0.365, 0.130, 0.330, 0.051, 0.289, -0.024,
    -0.046, -0.023, 0.001, 0.047, 0.022, 0.130, 0.035, 0.212);
const int GLYPH_1_SEGMENT[29] = int[](
    0, 6, 14, 20, 26, 32, 40, 46, 52, 60, 68, 76, 82, 90, 98, 106, 114, 122, 128, 136, 144, 152, 160, 168,
    174, 180, 188, 196, 204);

// '?' U+8449 glyph 'uni8449': 83 points, 14 trails, 23 cubics, stroke half-width ~0.015
const float GLYPH_2[166] = float[](
    -0.426, 0.357, -0.142, 0.357, 0.143, 0.357, 0.427, 0.357, 0.167, 0.262, 0.167, 0.320,
    0.167, 0.377, 0.167, 0.435, -0.172, 0.266, -0.172, 0.322, -0.172, 0.379, -0.172, 0.435,
    -0.442, -0.409, -0.446, -0.407, -0.451, -0.406, -0.456, -0.405, 0.451, -0.409, 0.453, -0.408,
    0.455, -0.408, 0.457, -0.407, 0.251, 0.257, 0.249, 0.186, 0.255, 0.110, 0.248, 0.040,
    0.154, 0.036, 0.054, 0.035, -0.040, 0.041, -0.045, 0.114, -0.040, 0.191, -0.042, 0.265,
    0.042, -0.202, 0.060, -0.244, 0.120, -0.274, 0.157, -0.299, 0.243, -0.351, 0.337, -0.389,
    0.434, -0.415, 0.428, -0.197, 0.301, -0.199, 0.172, -0.194, 0.046, -0.200, 0.018, -0.199,
    -0.019, -0.191, -0.048, -0.203, -0.098, -0.191, -0.158, -0.200, -0.211, -0.197, -0.283, -0.198,
    -0.354, -0.197, -0.425, -0.198, -0.458, -0.404, -0.457, -0.404, -0.457, -0.404, -0.456, -0.405,
    0.427, 0.167, 0.143, 0.167, -0.142, 0.167, -0.426, 0.167, 0.395, -0.070, 0.261, -0.071,
    0.124, -0.068, -0.008, -0.072, -0.095, -0.066, -0.184, -0.075, -0.270, -0.067, -0.276, 0.039,
    -0.270, 0.148, -0.273, 0.254, 0.459, -0.406, 0.459, -0.406, 0.458, -0.407, 0.458, -0.407,
    -0.003, -0.435, -0.003, -0.315, -0.003, -0.194, -0.003, -0.074, -0.433, -0.412, -0.299, -0.369,
    -0.153, -0.309, -0.050, -0.212, -0.049, -0.209, -0.048, -0.206, -0.048, -0.203);
const int GLYPH_2_SEGMENT[23] = int[](
    0, 8, 16, 24, 32, 40, 46, 52, 60, 66, 74, 80, 86, 92, 100, 108, 116, 122, 128, 136, 144, 152, 158);


// '?' U+539F glyph 'uni539F': 65 points, 8 trails, 19 cubics, stroke half-width ~0.015
const float GLYPH_3[130] = float[](
    -0.432, -0.426, -0.304, -0.182, -0.343, 0.103, -0.331, 0.366, -0.201, 0.371, -0.066, 0.370,
    0.065, 0.367, 0.181, 0.372, 0.302, 0.368, 0.420, 0.369, -0.090, -0.437, -0.040, -0.425,
    0.089, -0.473, 0.068, -0.378, 0.067, -0.287, 0.068, -0.195, 0.068, -0.103, 0.327, 0.059,
    0.333, 0.106, 0.332, 0.165, 0.327, 0.212, 0.226, 0.218, 0.123, 0.211, 0.023, 0.216,
    -0.047, 0.210, -0.119, 0.219, -0.188, 0.211, -0.192, 0.160, -0.191, 0.106, -0.188, 0.056,
    -0.191, 0.007, -0.192, -0.049, -0.187, -0.097, -0.103, -0.104, -0.013, -0.095, 0.070, -0.102,
    0.155, -0.094, 0.245, -0.105, 0.328, -0.096, 0.331, -0.047, 0.334, 0.010, 0.327, 0.059,
    0.156, 0.059, -0.015, 0.059, -0.187, 0.059, -0.106, -0.427, -0.105, -0.427, -0.105, -0.427,
    -0.104, -0.428, -0.102, -0.429, -0.102, -0.429, -0.103, -0.428, -0.104, -0.428, 0.068, 0.365,
    0.063, 0.315, 0.034, 0.266, 0.026, 0.217, 0.431, -0.386, 0.374, -0.314, 0.303, -0.254,
    0.229, -0.200, -0.302, -0.391, -0.230, -0.337, -0.164, -0.274, -0.110, -0.202);
const int GLYPH_3_SEGMENT[19] = int[](
    0, 6, 12, 20, 26, 34, 40, 46, 52, 58, 64, 70, 76, 82, 90, 98, 106, 114, 122);



layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
struct Grid{vec3 cell,hash;float d;};

vec4 txt(vec2 uv){
    return texture(texLogo,uv*vec2(1,-1)-.5);
}

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
float bpm= fGlobalTime*120/60;
vec3 hash3d(vec3 p){
    uvec3 q =floatBitsToUint(p);
    q+=((q>>16U)^q.yzx)*1111111111u;
    q+=((q>>15U)^q.zyx)*1111111111u;
    q+=((q>>16U)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}

// BEZIER CURVE TO DRAW GLYPH WITH DATA POINT
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
mat4 bm = mat4(1,-3,3,-1, 0,3,-6,3, 0,0,3,-3, 0,0,0,1);
vec3 bezier(vec3 p1,vec3 p2,vec3 p3,vec3 p4,float t){
    
    return vec4(1,t,t*t,t*t*t)*bm*transpose(mat4x3(p1,p2,p3,p4));
 
     
  }
Grid grid;
void doGrid(vec3 ro,vec3 rd){
    grid.cell = (floor(ro+rd*.001)+.5);
     grid.cell.y=0; 
   grid.hash = hash3d(grid.cell);
  
    vec3 s= -(ro-grid.cell)/rd;
    s += abs(.5/rd);
    grid.d= min(s.x,min(s.z,s.z));
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec3 iso(vec3 p){
     p= erot(p,vec3(1,0,0),atan(cos(-1)));
     p= erot(p,vec3(0,-1,0),.785);
   return p;
  }
 vec3 riso(vec3 p){
       p= erot(p,vec3(0,-1,0),-.785);
     p= erot(p,vec3(1,0,0),-atan(cos(-1)));
 
   return p;
  }
  
vec2 toBuf(vec3 p){
     p= riso(p)/2;
     vec2 rx= vec2(v2Resolution.x/v2Resolution.y,1);
     return (p.xy+.5*rx)/rx*v2Resolution;
}
void set(vec2 p,vec3 c){for(int i=0;i<3;i++){imageAtomicAdd(computeTex[i],ivec2(p),int(c[i]*2048));}}
vec3 get(vec2 p){
     vec3 c=vec3(0);
     for(int i=0;i<3;i++){ c[i] = imageLoad(computeTexBack[i],ivec2(p)).x;}
     return c/2048.;
  }
vec4 intro(vec2 uv){
   vec2 uuv =uv-bpm*.125;
  uv.y = fract(uv.y-bpm*.125)-.5;

  vec2 off= vec2((texture(texFFTSmoothed,mix(.01,.4,floor(fract(uuv.y)*100)/100)).r)*5.5,0);
  vec4 logo = vec4(
  txt((uv+off)*.5).r,
  txt((uv-off)*.5).g,
  txt((uv-off)*.5).b,
  txt((uv-off)*.5).a);
  float  quad = mod(floor(uv.x*10)+floor(uv.y*10),2);
  
  
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
  
	vec4 col = (f*.005 + t)*logo+(f*quad)*.125+dFdx(logo.x)*vec4(-1,1,1,1);
  col = mix(sqrt(col),.01/(.01+(2*sqrt(col))),mod(floor(uuv.y),2));
  return col;
}
// AI, Raylmach ISOMETRIC
float box(vec3 p,vec3 b){p=abs(p)-b;return length(max(vec3(0),p))+min(0.,max(p.x,max(p.y,p.z)));}
vec2 sdf(vec3 p){
    
    vec3 hp=p-grid.cell;
    vec2 h;
  
    h.x = box(hp,vec3(.45,.45+sqrt(texture(texFFTSmoothed,grid.hash.x).r)*5,.45));
    h.y = 1.;
    return h;
}

#define q(s) s*sdf(p+s).x
vec3 norm(vec3 p,float ee){vec2 e=vec2(-ee,ee);return normalize(q(e.xyy)+q(e.yxy)+q(e.yyx)+q(e.xxx));}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 col = vec3(0);
  vec3 ro=vec3(uv,-1)*10;
  vec3 rd=vec3(0,0,1);
  vec3 light = vec3(1.,2.,-3);
  vec2 d;
  vec3 rp=ro;
  float rl= 0;;
  float glen =0.;
  vec3 acc=vec3(0);
  for(float i=0.;i++<128;){
       rp.xy+=(hash3d(vec3(floor(bpm),132465978,-1u)).xz*2-1)*5*exp(-3*fract(bpm));
       rp= iso(rp);
     if(glen<=rl){
         doGrid(rp,iso(rd));
         glen+=grid.d;
       }
      d= sdf(rp);
      if(grid.hash.y <.5){
         acc+=vec3(.95,.4,.2)*5*exp(-abs(d.x))/(100-99*exp(-5*fract(bpm*.125+rp.y*.01+grid.hash.z)));
        }
      if(d.x<.001)break;
      rl=min(rl+d.x,glen);
      rp=ro+rd*rl;
  }
  
  if(d.x<.001){
       vec3 n= norm(rp,.001);
       vec3 ld = normalize(light-rp);
       float dif = pow((1+dot(ld,n))/2,2);
       col +=dif*.1;
       vec4 tt = txt(rp.xz*.1);
      col = mix(col,tt.rgb*2*exp(-3*fract(bpm)),tt.a);
    
          vec2 gl=gl_FragCoord.xy;
    vec3 p=rp;
      
       float tmp = mod(floor(fGlobalTime*5),3);

     // DOESN4T WORK FUCK MY LIFE 
   if(tmp<1){ 
          float GLYPH[]= GLYPH_1; 
     int GLYPH_SEGMENT[]=GLYPH_1_SEGMENT; 
   if(gl.x<=2 && gl.y <=2){
    for(int k=0;k<GLYPH_SEGMENT.length();k++){
       int s = GLYPH_SEGMENT[k];
      vec3 a = vec3(GLYPH[s+0],GLYPH[s+1],0);
      vec3 b = vec3(GLYPH[s+2],GLYPH[s+3],0);
      vec3 c = vec3(GLYPH[s+4],GLYPH[s+5],0);
      vec3 d = vec3(GLYPH[s+6],GLYPH[s+7],0);
      for(float i=0,im=50;i<im;i++){
         p = bezier(a,b,c,d,i/im);
        // p.y+=texture(texFFTSmoothed,mix(.1,.5,fract(floor(i/im*10)/10+gl.x/v2Resolution.x+gl.y/v2Resolution.y))).r*10;
          p =erot(p,vec3(0,1,0),fGlobalTime );
        for(float j=0,jm=50;j<jm;j++){
            float js = j/jm;
          float r= 5.;
          vec3 rnd = hash3d(p*js);
           vec3 pp  = p+vec3(r*cos(rnd.x)*cos(rnd.y),r*cos(rnd.x)*sin(rnd.y),r*sin(rnd.x))*.01;
            set(toBuf( pp),vec3(.95,.4,.2)*.3);
        }
      }
    }
    
    
    
  }
  
    
    
    
    

  
  }
   else if(tmp<2){ 
          float GLYPH[]= GLYPH_2; 
     int GLYPH_SEGMENT[]=GLYPH_2_SEGMENT; 
   if(gl.x<=2 && gl.y <=2){
    for(int k=0;k<GLYPH_SEGMENT.length();k++){
       int s = GLYPH_SEGMENT[k];
      vec3 a = vec3(GLYPH[s+0],GLYPH[s+1],0);
      vec3 b = vec3(GLYPH[s+2],GLYPH[s+3],0);
      vec3 c = vec3(GLYPH[s+4],GLYPH[s+5],0);
      vec3 d = vec3(GLYPH[s+6],GLYPH[s+7],0);
      for(float i=0,im=50;i<im;i++){
         p = bezier(a,b,c,d,i/im);
        // p.y+=texture(texFFTSmoothed,mix(.1,.5,fract(floor(i/im*10)/10+gl.x/v2Resolution.x+gl.y/v2Resolution.y))).r*10;
          p =erot(p,vec3(0,1,0),fGlobalTime );
        for(float j=0,jm=50;j<jm;j++){
            float js = j/jm;
          float r= 5.;
          vec3 rnd = hash3d(p*js);
           vec3 pp  = p+vec3(r*cos(rnd.x)*cos(rnd.y),r*cos(rnd.x)*sin(rnd.y),r*sin(rnd.x))*.01;
            set(toBuf( pp),vec3(.95,.4,.2)*.3);
        }
      }
    }
    
    
    
  }  
    
    
    
  } else{ 
          float GLYPH[]= GLYPH_3; 
     int GLYPH_SEGMENT[]=GLYPH_3_SEGMENT; 
    /// NANI THE FUCK
   if(gl.x<=2 && gl.y <=2){
    for(int k=0;k<GLYPH_SEGMENT.length();k++){
       int s = GLYPH_SEGMENT[k];
      vec3 a = vec3(GLYPH[s+0],GLYPH[s+1],0);
      vec3 b = vec3(GLYPH[s+2],GLYPH[s+3],0);
      vec3 c = vec3(GLYPH[s+4],GLYPH[s+5],0);
      vec3 d = vec3(GLYPH[s+6],GLYPH[s+7],0);
      for(float i=0,im=50;i<im;i++){
         p = bezier(a,b,c,d,i/im);
        // p.y+=texture(texFFTSmoothed,mix(.1,.5,fract(floor(i/im*10)/10+gl.x/v2Resolution.x+gl.y/v2Resolution.y))).r*10;
          p =erot(p,vec3(0,1,0),fGlobalTime );
        for(float j=0,jm=50;j<jm;j++){
            float js = j/jm;
          float r= 5.;
          vec3 rnd = hash3d(p*js);
           vec3 pp  = p+vec3(r*cos(rnd.x)*cos(rnd.y),r*cos(rnd.x)*sin(rnd.y),r*sin(rnd.x))*.01;
            set(toBuf( pp),vec3(.95,.4,.2)*.3);
        }
      }
    }
  
    
    
    
    

  
    }
  
    
    
    
    

  
    }
      
    
   }
   
   col += get(gl_FragCoord.xy).bgr*15*exp(-5*fract(bpm*4));
  col+=acc;

   col = mix(col,.1/col,step(3.,mod(bpm,4))*exp(-10*fract(bpm*4)));
      col += cross(sin(col),cos(col*5))*.1;
   ivec2 off=ivec2(hash3d(uv.xxx).xy*2);
   vec3 pcol = vec3(
      texelFetch(texPreviousFrame,ivec2(gl_FragCoord.xy-off),0).r,
      texelFetch(texPreviousFrame,ivec2(gl_FragCoord.xy+off),0).g,
      texelFetch(texPreviousFrame,ivec2(gl_FragCoord.xy-off),0).b
   

   );   
   col = mix((col),pcol,.5);
  out_color = vec4(col,1);//+.1*intro(uv);
}