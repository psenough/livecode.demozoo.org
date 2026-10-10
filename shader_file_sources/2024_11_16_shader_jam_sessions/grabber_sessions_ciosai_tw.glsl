#version 420 core

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
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define U gl_FragCoord.xy
#define R vec2(v2Resolution.xy)
#define T fGlobalTime 

#define pi acos(-1.)
#define tau (acos(-1.)*2.)


#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))



// hashes
uint seed = 1251522;
uint hashi( uint x){
    x ^= x >> 16;x *= 0x7feb352dU;x ^= x >> 15;x *= 0x846ca68bU;x ^= x >> 16;
    return x;
}

#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec3(hash_f(),hash_f(),hash_f(),hash_f())

// https://www.shadertoy.com/view/XlXcW4
vec3 hash3f( vec3 s ) {
  uvec3 r = floatBitsToUint( s );
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  r = ( ( r >> 16u ) ^ r.yzx ) * 1111111111u;
  return vec3( r ) / float( -1u );
}


uint seed_gen(vec3 p){
    return uint(p.x+66341.)*666562+uint(p.y+54324.)*3554+uint(p.z+61441.);
}

vec3 noise(vec3 p){
    vec3 bl_back = hash3f(floor(p));
    vec3 br_back = hash3f(floor(p)+vec3(1,0,0));
    vec3 tr_back = hash3f(floor(p)+vec3(1,1,0));
    vec3 tl_back = hash3f(floor(p)+vec3(0,1,0));
    vec3 bl_front = hash3f(floor(p)+vec3(0,0,1));
    vec3 br_front = hash3f(floor(p)+vec3(1,0,1));
    vec3 tr_front = hash3f(floor(p)+vec3(1,1,1));
    vec3 tl_front = hash3f(floor(p)+vec3(0,1,1));
    return 
    mix(
    mix(
    mix(bl_back, br_back, smoothstep(0.,1.,fract(p.x))),
    mix(tl_back, tr_back, smoothstep(0.,1.,fract(p.x))),
    smoothstep(0.,1.,fract(p.y))
    ),
    mix(
    mix(bl_front, br_front, smoothstep(0.,1.,fract(p.x))),
    mix(tl_front, tr_front, smoothstep(0.,1.,fract(p.x))),
    smoothstep(0.,1.,fract(p.y))
    ),
    smoothstep(0.,1.,fract(p.z))
    )
    ;
}

vec2 sample_disk(){
    vec2 r = hash_v2();
    return vec2(sin(r.x*tau),cos(r.x*tau))*sqrt(r.y);
}

// point projection
ivec2 proj_p(vec3 p){
  p *= 0.6;
  
  p.y *= -1.;
  
  // depth of field
  p.xy += sample_disk() * abs(p.z - 5.)*0.04;
  
  // convert point to ivec2. From 0 to resolution.xy
  ivec2 q = ivec2((p.xy + vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R);
  if(any(greaterThan(q, ivec2(R))) || any(lessThan(q, ivec2(0)))){
      q = ivec2(-1);
  }
  return q;
}


void store_pixel(ivec2 px_coord, vec3 col){
  // colour quantized to integer.
  ivec3 quant_col = ivec3(col * 1000);
  // no clue why it wants ivec4() here...
  imageStore(computeTex[0], px_coord, ivec4(quant_col.x)); 
  imageStore(computeTex[1], px_coord, ivec4(quant_col.y)); 
  imageStore(computeTex[2], px_coord, ivec4(quant_col.z)); 
}

void add_to_pixel(ivec2 px_coord, vec3 col){
  // colour quantized to integer.
  ivec3 quant_col = ivec3(col * 1000);
  imageAtomicAdd(computeTex[0], px_coord, quant_col.x);
  imageAtomicAdd(computeTex[1], px_coord, quant_col.y);
  imageAtomicAdd(computeTex[2], px_coord, quant_col.z);
}

vec3 read_pixel(ivec2 px_coord){
  return 0.001*vec3(
    imageLoad(computeTexBack[0],px_coord).x,
    imageLoad(computeTexBack[1],px_coord).x,
    imageLoad(computeTexBack[2],px_coord).x
  );
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float box(vec2 p)
{
  vec2 q = abs(p);
  return max(q.x, q.y);
}


vec3 fbm(vec3 p)
{
    float retain = .5;
    vec3 acc = p;
    for(int i=0; i<4; i++){
        acc = noise(acc*float(1+i)*1.4) * pow(retain,float(i));
    }
    return acc;
}

void main()
{
vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
 
  float BPM = 140.;
  float BEAT_DUR=60./BPM;
  float time = T/BEAT_DUR;
  
  float intg = texture(texFFTIntegrated, .2).x;
  
  time *= .25;
	
  
  
  if( gl_FragCoord.x < 400 ){
    seed = uint(gl_FragCoord.y*R.x+gl_FragCoord.x);

            float pattern = hash_f();
            {/*
                vec3 pos = vec3((hash_f()*2.-1.)*2.,0,0);
                pos.y = (noise(pos.xxx*4.-time*4.).x*2.-1.)*.5;
                pos*=.75;

                vec3 col = vec3(.4,.8-length(pos),.3+length(pos)*.2);
                col = hsv2rgb(col);
                add_to_pixel(proj_p(pos+vec3(0,0,8.5)), col);
            */}
            
            {
              vec3 pos = vec3(hash_v2()*2.-1.,0);
              bool show = false;
              
              vec2 samp = (fract(pos.xy*rot(.2)*2.)*vec2(1,-1));
              vec2 isamp = floor(pos.xy*rot(.2)*4.);
              samp.y += mod(isamp.x,2.)*.5;
              samp = fract(samp);
              samp += vec2(intg*3. + sin(time*tau)*.1,0)*.5;
              
              if(texture(texSessionsShort, samp).r>.5){show = true;}
              
              pos *= 2.;
              
              if(show){
                vec3 col = vec3(.4,.8-length(pos),.3+length(pos)*.2);
                col = hsv2rgb(col);
                add_to_pixel(proj_p(pos+vec3(0,0,8.5)), col);
               }
            }
            {
              float pattern = hash_f();
              
              vec3 pos = hash_v3();
              //chi
              if(pattern<.25){
                
                if(pos.z<.33){
                  pos.y = -pow(pos.x,2.)*.5 - .5;
                  pos.x = pos.x*2.-1.;
                }
                else if(pos.z<.66){
                  pos.y = .1;
                  pos.x = pos.x*2.-1.;
                }
                else if(pos.z<1.){
                  pos.x = -pow(pos.y,4.);
                  pos.y = (pos.y*2.-1.)*.75 + .1;
                }
                
                pos.xy *= .1;
                pos.x -= .45;
                
                pos.z = 0.;
              }
              //yo
              else if(pattern<.5){
                
                if(pos.z<.25){
                  pos.y = pos.y*2.-1.;
                  pos.x = 1.;
                }
                else{
                  pos.y = floor(hash_f()*3.)/1. - 1.;
                  pos.x = pos.x*2.-1.;
                }
                
                pos.xy *= .066;
                pos.x -= .15;
                
                pos.z = 0.;
              }
              //sa
              else if(pattern<.75){
                
                if(pos.z<.33){
                  pos.y = -.5;
                  pos.x = pos.x*2.-1.;
                }
                else if(pos.z<.66){
                  pos.x = -.5;
                  pos.y = (pos.y*2.-1.)*.75 - .25;
                }
                else if(pos.z<1.){
                  pos.x = -pow(pos.y,4.) + .5;
                  pos.y = (pos.y*2.-1.);
                }
                
                pos.xy *= .1;
                pos.x += .15;
                
                pos.z = 0.;
              }
              //i
              else{
                
                if(pos.z<.5){
                  pos.y = -pow(pos.x,2.)*.5 - .5;
                  pos.x = pos.x*2.-1.;
                }
                else{
                  pos.x = 0.;
                  pos.y = (pos.y*2.-1.)*.75 + .25;
                }
                
                pos.xy *= .1;
                pos.x += .45;
                
                pos.z = 0.;
              }
              
              pos.y -= (texture(texFFTSmoothed, (pos.x*5.)*.5+.5).x)*.6;
              
              pos.xy *= rot(.2);
              
              pos.x += sin(floor(time*4.)*44642.)*.2;
              
              vec3 col = vec3(.4,.8-length(pos),.3+length(pos)*.2);
              col = hsv2rgb(col);
              add_to_pixel(proj_p(pos+vec3(0,0,8.5)), col);
            }
            {
                vec3 pos;
                vec2 scaling = vec2(.5,.5);
                bool show = false;
                if(hash_f()<.05){
                    pos = vec3(hash_f()*2.-1.,step(.5,hash_f())*2.-1.,0);
                    if(hash_f()<.5) { pos.xy = pos.yx; }
                    show = true;
                }
                else{
                    //pos.xy = hash_v2()*2.-1.;
                  float time2 = time*2.;
                    for(int i=0; i<128; i++){
                        pos.xy = hash_v2()*2.-1.;
                        vec2 n_uv = pos.xy/scaling.yx;
                        float acc;
                        acc += sqrt(length(n_uv-(noise(vec3(time2,0,0)*2.).xy*2.-1.)*2.));
                        acc += sqrt(length(n_uv-(noise(vec3(0,time2,0)*2.).xy*2.-1.)*2.));
                        acc += sqrt(length(n_uv-(noise(vec3(0,0,time2)*2.).xy*2.-1.)*2.));
                        acc += sqrt(length(n_uv-(noise(vec3(time2,0,-time2)*2.).xy*2.-1.)*2.));
                        if ( abs(acc-5.) < sin(time*tau*2.)*.5+.5 ) { show = true; break;  }
                    }
                }
                pos.xy *= scaling;
                //pos.xy += vec2(.75,.5);
                if(show){
                  vec3 col = vec3(.4,.8-length(pos),.3+length(pos)*.2);
                  col = hsv2rgb(col);
                  add_to_pixel(proj_p(pos+vec3(0,0,8.5)), col);
                 }
            }
            {
              float time2 = time*2.-.1;
              vec2 balls[4] = {(noise(vec3(time2,0,0)*2.).xy*2.-1.),
                (noise(vec3(0,time2,0)*2.).xy*2.-1.),
                (noise(vec3(0,0,time2)*2.).xy*2.-1.),
                (noise(vec3(time2,0,-time2)*2.).xy*2.-1.)};
              float pattern = hash_f();
              vec3 pos;
               if(pattern<.5){
                 pos = vec3(balls[int(hash_f()*4.)],1);
               }else{
                 pos = vec3(mix(balls[int(hash_f()*4.)],balls[int(hash_f()*4.)],hash_f()),0);
                }
                
              pos.xy*=.5;
                
              vec3 col = vec3(.4,.8-length(pos),.3+length(pos)*.2);
              col = hsv2rgb(col);
              add_to_pixel(proj_p(pos+vec3(0,0,8.5)), col);
            }
  }
  
  
  vec2 read = uv;
  
  /*for(int i=0; i<9; i++){
    seed = uint(i)+4453u + uint(time*.25);
    vec2 funny = (hash_v2()*2.-1.)*.2;
    float goofy = hash_f();
    read *= rot(goofy*tau);
    read += funny;
    read = abs(read);
    read -= funny;
    read *= rot(-goofy*tau);
  }
  
  read = mix(uv, read, pow(sin(time*tau*.25)*.5+.5, 8.));*/
  
  //texPreviousFrame
  
  vec3 s = read_pixel(ivec2( fract(read*vec2(v2Resolution.y / v2Resolution.x, 1)+.5)*R ));
  
  if(fract(time)<.1){
  
  out_color = vec4(s,1);
  }
  else{
    vec2 iread = floor(read*5.);
    vec2 off = normalize(vec2(cos(iread.y*664+iread.x*231),sin(iread.y*264+iread.x*731)));
    read += off*.005;
  vec3 prev = texture(texPreviousFrame, fract(read*vec2(v2Resolution.y / v2Resolution.x, 1)+.5)).rgb;
  out_color = vec4(mix(s,prev,round(cos(iread.y*8.+iread.x*93.+floor(time))*.5+.01)),1);
  }
}
