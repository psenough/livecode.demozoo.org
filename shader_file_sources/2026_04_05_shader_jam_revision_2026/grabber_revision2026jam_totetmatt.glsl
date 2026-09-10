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
uniform sampler2D texDritterLogo;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texZX;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;
ivec2 font_data[37] = ivec2[](
    ivec2(0x7f88887f,0x00000000), //A
    ivec2(0x6e9191ff,0x00000000), //B
    ivec2(0x4281817e,0x00000000), //C
    ivec2(0x7e8181ff,0x00000000), //D
    ivec2(0x919191ff,0x00000000), //E
    ivec2(0x909090ff,0x00000000), //F
    ivec2(0x4685817e,0x00000000), //G
    ivec2(0xff1010ff,0x00000000), //H
    ivec2(0x0081ff81,0x00000000), //I
    ivec2(0x80fe8182,0x00000000), //J
    ivec2(0x413608ff,0x00000000), //K
    ivec2(0x010101ff,0x00000000), //L
    ivec2(0x601060ff,0x000000ff), //M
    ivec2(0x0c1060ff,0x000000ff), //N
    ivec2(0x7e81817e,0x00000000), //O
    ivec2(0x609090ff,0x00000000), //P
    ivec2(0x7f83817e,0x00000001), //Q
    ivec2(0x619698ff,0x00000000), //R
    ivec2(0x4e919162,0x00000000), //S
    ivec2(0x80ff8080,0x00000080), //T
    ivec2(0xfe0101fe,0x00000000), //U
    ivec2(0x0e010ef0,0x000000f0), //V
    ivec2(0x031c03fc,0x000000fc), //W
    ivec2(0x340834c3,0x000000c3), //X
    ivec2(0x300f30c0,0x000000c0), //Y
    ivec2(0xe1918d83,0x00000081), //Z
    ivec2(0x00000000,0x00000000), //space
    ivec2(0x7e91897e,0x00000000), //0
    ivec2(0x01ff4121,0x00000000), //1
    ivec2(0x71898543,0x00000000), //2
    ivec2(0x6e919142,0x00000000), //3
    ivec2(0x08ff4838,0x00000000), //4
    ivec2(0x8e9191f2,0x00000000), //5
    ivec2(0x0e91916e,0x00000000), //6
    ivec2(0xc0b08f80,0x00000000), //7
    ivec2(0x6e91916e,0x00000000), //8
    ivec2(0x6e919162,0x00000000) //9
);vec3 font(vec2 uv,int id){
    vec2 uv1 = uv;
    uv = uv * 8.0;
    ivec2 texel = ivec2(uv);
    int bit_offset = texel.x * 8 + texel.y;

    int s,t;
    s = font_data[id].x;
    t = font_data[id].y;

    int tex = 0;
    
    if(bit_offset <= 31){
        s = s >> bit_offset;
        s = s & 0x00000001;
        tex = s;
    }
    else{
        t = t >> (bit_offset - 32);
        t = t & 0x00000001;
        tex = t;
    }

    tex = (abs(uv1.x - 0.5) < 0.5 && abs(uv1.y - 0.5) < 0.5) ? tex : 0;
    return vec3(tex); 
}
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float bpm = fGlobalTime*135/60;
vec3 hash3d(vec3 p){
    uvec3 q= floatBitsToUint(p);
    q += ((q>>16u)^q.yzx)*1111111111u;
    q += ((q>>16u)^q.yzx)*1111111111u;
    q += ((q>>16u)^q.yzx)*1111111111u;
  return vec3(q)/float(-1U);
}
vec3 stepNoise(float t,float n){
    return mix(hash3d(vec3(floor(t),-1u,123456789)),hash3d(vec3(floor(t+1),-1u,123456789)),smoothstep(.5-n,.5+n,fract(t)));
  }
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}
vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
 vec3 C = vec3(.95,.4,.2);
vec3 _MAKE(vec2 uv){
  uv.x +=.5;
  uv.y += sin(bpm+uv.x)*.1;
    //// MAKE
  vec3 f=font(uv*8,12);
  f+=font(uv*8-vec2(1,0),0);
  f+=font(uv*8-vec2(2,0),10);
  f+=font(uv*8-vec2(3,0),4);
  return f;
  }
 vec3 _SOMENOISE(vec2 uv){
  uv.x +=.5;
    //// SOME
  vec3 f=font(uv*8,18);
  f+=font(uv*8-vec2(1,0),14);
  f+=font(uv*8-vec2(2,0),12);
  f+=font(uv*8-vec2(3,0),4);
   
   // NOISE
   f+=font(uv*8-vec2(0,-2),13);
   f+=font(uv*8-vec2(1,-2),14);
  f+=font(uv*8-vec2(2,-2),8);
  f+=font(uv*8-vec2(3,-2),25);  
   f+=font(uv*8-vec2(4,-2),4);
  return f;
  }
 vec3 _FORDRITTER(vec2 uv){
   uv.x +=.5;
   uv.y -=.2;
   uv/=1.5;
   //FOR
   vec3 f=font(uv*8,5);
  f+=font(uv*8-vec2(1,0),14);
  f+=font(uv*8-vec2(2,0),17);
   uv+=(hash3d(vec3(floor(uv.xy*10)/10,bpm)).xz-.5)*.01;
   // DRITTER
   f+=font(uv*8-vec2(0,-2),3);
   f+=font(uv*8-vec2(1,-2),17);
  f+=font(uv*8-vec2(2,-2),8);
    f+=font(uv*8-vec2(3,-2),19);
  f+=font(uv*8-vec2(4,-2),19);
    f+=font(uv*8-vec2(5,-2),4); 
     f+=font(uv*8-vec2(6,-2),17);
   return f;
   }
 vec3 _LAUTER(vec2 uv){
      uv*=1-exp(-3*fract(bpm));
    uv.x +=.33;
     uv.y +=.05;
      vec3 f=font(uv*8,11);
  f+=font(uv*8-vec2(1,0),0);
  f+=font(uv*8-vec2(2,0),20);
    f+=font(uv*8-vec2(3,0),19);
       f+=font(uv*8-vec2(4,0),4);
       f+=font(uv*8-vec2(5,0),17);
      return f;
 }
 
     void set(ivec2 p,vec3 c){
        for(int i=0;i<3;i++){imageAtomicAdd(computeTex[i],p,int(2048*c[i]));}
      }
      vec3 get(ivec2 p){
          vec3 c= vec3(0);
          for(int i=0;i<3;i++){c[i] = imageLoad(computeTexBack[i],p).x;}
          return c/2048;
        }
////////////////////////////////////////////////////////
vec4 s4(vec2 fc,vec2 res){
  vec2 uv = (fc-.5*res)/min(res.x,res.y);
  vec4 hd = sqrt(texture(texZX,clamp(uv*vec2(1,-1)*4-vec2(2,1)+stepNoise(bpm*2,.5).xy-.5,-.5,.5)-.5));

  vec3 col =vec3(0);
  vec3 ro=vec3(1.5,1.,0),rt=vec3(0);
  vec3 z = normalize(rt-ro),x=vec3(z.z,0,-z.x);
  mat3 rd= mat3(x,cross(z,x),z);
  
  vec3 p =vec3(0);
  p.xz += hash3d(fc.xyy).xz*2-1;
  
   float d= 0;
   vec3 hp=p;
   hp.xz += stepNoise(bpm*.5,.5).xz*4-2;
  for(float i=0;i++<4;){
      d+= clamp(asin(sin(hp.x))*i+asin(cos(hp.z))*i,-1,1)*.1*i;
      hp=abs(hp)-.5;
      hp*=i*2;
    }
    
    p.y += d;
  
  p= (p-ro)*rd;
  p.xy/=p.z;
  
  vec2 rx= vec2(res.x/res.y,1);
  vec2 q= (p.xy+.5*rx)/rx*res;
  
  set(ivec2(q),sin(floor(d*5)/5+C+bpm));
  col = get(ivec2(fc));
    
    vec3 ccol = _LAUTER(uv);
    col = mix(col,2*cross(sin(col),cos(col*5)),ccol.x);
	return vec4(mix(col,hd.rgb,hd.a),1);
 }
 ////////////////////////////////////////////////////////
 vec2 sdf(vec3 p){
    p.y +=bpm*.5;
    vec3 hp=p;
   vec2 h;
  h.x = 1e4;
  h.y = hash3d(floor(p)).x;
  float f= 1.;
  hp=asin(sin(hp*2))/2;
  for(float i=0;i++<8;){
       hp= erot(hp,vec3(0,1,0),i/f);
      hp= abs(hp)-.5*f;
      h.x = min(h.x,max(hp.x,max(hp.y,hp.z)));
      f/=1.8;
  }
  h.x = max(-h.x,min(abs(p.x),abs(p.z))-.5);
  
  return h;
}
vec4 s3(vec2 fc,vec2 res){
  vec2 uv = (fc-.5*res)/min(res.x,res.y);
   vec4 hd = sqrt(texture(texAtari,clamp(uv*vec2(1,-1)*4-vec2(2,1)+stepNoise(26-bpm*.9,.3).xy-.5,-.5,.5)-.5));

	vec3 col = 1-_FORDRITTER(uv);
  
  
	return vec4(mix(col,hd.rgb,hd.a),1);
 }
 ////////////////////////////////////////////////////////
vec4 s2(vec2 fc,vec2 res){
  vec2 uv = (fc-.5*res)/min(res.x,res.y);
 vec4 hd = sqrt(texture(texAmiga,clamp(uv*vec2(1,-1)*4-vec2(2,1)+stepNoise(56+bpm*1.1,.3).xy-.5,-.5,.5)-.5));
  
	vec3 col =_MAKE(uv);
  
  vec3 ro= vec3(uv,-2)*2+stepNoise(bpm*8,.1)*.05,rd=vec3(0,0,1);
  vec3 rp=ro;
  float rl=0;;
  vec2 d;
  for(float i=0;i++<99;){
     rp=erot(rp,vec3(1,0,0),atan(cos(-1)));
   rp= erot(rp,vec3(0,-1,0),bpm*.25);
     
    d =sdf(rp);
     float lol =exp(-3*fract(bpm*.125+d.y));
     col+=mix(C.bbr,C.bbr*2,lol)*exp(-abs(d.x))/(150-149*lol);
    if(lol>.5) d.x =max(.001,abs(d.x));
    if(d.x<.001)break;
    rl+=d.x;
     rp=ro+rd*rl;
  }
  col +=cross(sin(col),cos(col.yzx*5))*.2;
  
  
	return vec4(mix(col,hd.rgb,hd.a),1);
 }

////////////////////////////////////////////////////////
vec4 s1(vec2 fc,vec2 res){
  vec2 uv = (fc-.5*res)/min(res.x,res.y);
vec4 hd = sqrt(texture(texC64,clamp(uv*vec2(1,-1)*4-vec2(2,1)+stepNoise(-bpm*1.3,.3).xy-.5,-.5,.5)-.5));
  
  
	vec3 col = vec3(0);
  
   float si=0,sm=8;
   for(;si++<sm;){
       vec3 rnd = hash3d(vec3(si+bpm,uv));
       vec3 ro=vec3(0,0,-5)+stepNoise(bpm*.5,.3)*12-6,rd=normalize(vec3(uv,1.));
       vec3 box = vec3(10,5,20),emit =vec3(1);
      for(float i=0;i++<3;){
          vec3 b= (sign(rd)*box-ro)/rd;
          float d= min(b.x,min(b.y,b.z));
          vec3 n= step(b,vec3(d))*sign(rd);
          vec3 p = ro+rd*(d-.001);
          vec3 ccol= vec3(0);
          if(n.z>0){
            
               vec3 r = hash3d(vec3(floor(bpm*.25),-1u,123456));
               vec3 id = floor(p/floor(mix(1.,4.,r.z)))*r;
               float lol = exp(-7*fract(bpm+id.x+id.y));
               ccol = texture(texDritterLogo,p.xy*vec2(1,-1)/4).r*mix(C.bgr,C*4,lol)*lol;
            }
            float res =.5*rnd.z*step(.5,hash3d(vec3(floor(p))).x);
            ro=p;
            col+=ccol*emit;
             emit*=.5;
            rd= reflect(rd,normalize(n+(rnd*2-1)*res));
        }
     }
  col =sqrt(col/sm);
  col = mix(col,hd.rgb,hd.a);
  col += col*10*_SOMENOISE(uv);
  
  
  //col += texture(texDritterLogo,clamp(uv*vec2(1,-1),-.5,.5)-.5).rgb*.5;;
	return vec4(mix(col,hd.rgb,hd.a),1);
 }
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 fc=  gl_FragCoord.xy,res= v2Resolution.xy;
  
  float slidefactor = .5;
  vec2 s=mix(vec2(.5),.95*smoothstep(-.1,.1,vec2(cos(bpm*slidefactor),-sin(bpm*slidefactor))),.95*smoothstep(-.1,.1,sin(bpm*.5*slidefactor)));
  bvec2 l= lessThan(uv,s);
  fc-=mix(res*s,vec2(0),l);
  res*=mix(1-s,s,l);
  if(l.y&&l.x)out_color=s4(fc,res);
  if(l.y&&!l.x)out_color=s3(fc,res);
  if(!l.y&&l.x)out_color=s2(fc,res);
  if(!l.y&&!l.x)out_color=s1(fc,res);
//out_color.rgb += (dFdy(out_color.rgb)+dFdx(out_color.rgb))*vec3(-1,1,1);
  //out_color = mix(out_color,1-out_color,exp(-3*fract(bpm*4)));
 // out_color = mix(out_color,1-out_color,exp(-3*fract(bpm+float(l.y)*.5+float(l.x)*.25)));
  
}