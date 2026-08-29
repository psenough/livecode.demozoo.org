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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define UV gl_FragCoord.xy  //Shortcut for gl_FragCoord
#define R v2Resolution.xy   //Shortcut for v2Resolution
float t;                    //Time global variable

// hi all, long time no see, hope things are well
//   I'm referencing some stuff, and maybe some copy+paste, full jam mode baby
//   remember to call your folks and eat vegetables
//   greets to lgc, cns, $MACE, hg, pb, lns, 0b5vr, monad, polarity, fr, z10, nce, cat, inque, lj, atz, rbs, brcr, ivory labs, approximate, brain control, anyone else making (64k) intros, c64+snes+dmg sceners, norwegian sceners, everyone using st4b (hi wrl), friends, family, and YOU
//   special thanks to wrighter and evvvil for compute bonzo examples etc
//   see (saw?) you at the last TRSAC
//   <3

//READ / WRITE COMPUTE TEXTURE FUNCTIONS
void Add(ivec2 u, float c){//add pixel to compute texture
  ivec3 q = ivec3(c*1000);//squish float into int, we use this trick to keep it additive as floatToInt wouldn't work additively
  imageAtomicAdd(computeTex[0], u,q.x);
  //imageAtomicAdd(computeTex[1], u,q.y);
  //imageAtomicAdd(computeTex[2], u,q.z);
}
float Read(ivec2 u){       //read pixel from compute texture
  return 0.001     * //unsquish int to float
    float(imageLoad(computeTexBack[0],u).x)
    //imageLoad(computeTexBack[1],u).x,
    //imageLoad(computeTexBack[2],u).x
  ;
}

//HASH NOISE FUNCTIONS: Make particles random
uint seed = 1; //hash noise seed
uint hashi( uint x){x^=x>>16;x*=0x7feb352dU;x^=x>>15;x*=0x846ca68bU;x^=x>>16; return x;}// hash integer
float hash_f(){return float(seed=hashi(seed))/float(0xffffffffU);}                      // hash float
vec3 hash_v3(){return vec3(hash_f(),hash_f(),hash_f());}                                // hash vec3
vec2 hash_v2(){return vec2(hash_f(),hash_f());} 

vec3 unitSquareToNGon(vec2 p, float n, float amount)
{
    float a = p.x * 2.0 - 1.0;
    float b = p.y * 2.0 - 1.0;

    float pi = 3.141592;

    float r, theta;
    if (a > -b)
    {
        if (a > b)
        {
            r = a;
            theta = (pi / 4.0) * (b / a);
        }
        else
        {
            r = b;
            theta = (pi / 4.0) * (2.0 - (a / b));
        }
    }
    else
    {
        if (a < b)
        {
            r = -a;
            theta = (pi / 4.0) * (4.0 + (b / a));
        }
        else
        {
            r = -b;
            if (b != 0.0)
            {
                theta = (pi / 4.0) * (6.0 - (a / b));
            }
            else
            {
                theta = 0.0;
            }
        }
    }

    float circleRadius = r;

    r *= mix(1.0, cos(pi / n) / cos(theta - (2.0 * pi / n) * floor((n * theta + pi) / (2.0 * pi))), amount);
    // This is just so that the shape isn't aligned to an axis, which looks a bit nicer
    theta += .6;

    float u = r * cos(theta);
    float v = r * sin(theta);
    return vec3(u, v, circleRadius);
}

vec2 get_random_point_in_disk() {
  /*float angle = fract(hash_f()) * 3.14159265 * 2.0;
  float rad = hash_f();
  return vec2(cos(angle), sin(angle)) * rad;*/
  vec2 s = vec2(hash_f(), hash_f());
  return unitSquareToNGon(s, 5.0, 1.0).xy;
}


mat2 rot(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, s, -s, c);
}

vec3 pallete(float k){
	// Simple variation of https://iquilezles.org/articles/palettes/
	// You can use anything here.
	//return 0.5 + 0.5 * sin(vec3(3,2,1) + k);
  return pow(vec3(k), vec3(3.0, 1.4, 1.0));
}

void main(void)
{
	t=fGlobalTime*.1;                               //Set global time variable
  seed=0;                                         //Init hash
  seed+=hashi(uint(UV.x))+hashi(uint(UV.y)*125);  //More hash
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); //Default uv calc from Bonzo
  //uv-=.5;                                                                         //We want uv range 0->1 not -.5->.5 so things start at zero
  uv/=vec2(v2Resolution.y / v2Resolution.x, 1);                                     //uv now hold uv coordinates in 0->1 range
  
  //PLEASE NOTE: we have two uv coordinates variables: uv and UV
  //uv is from 0 -> 1
  //UV is from 0 -> screen resolution, and is basically a shortcut to gl_FragCoord.xy
  //Depending on what we want to achieve, sometimes we'll use uv, sometimes UV. Generally because the uv range simplifies the calculation, stick around yeah?

  // Classic camera example: remove this if not using camera and just using transforms in proj_point function
  float rad = 7.0 + sin(t * 8.2) * 3.0;
  vec3 cameraTarget=vec3(0,0,0),                                //Camera target
  cameraPosition=vec3(cos(t)*rad,0.0,sin(t)*rad);                   //Camera position
  cameraPosition.xz *= rot(sin(t * 0.9) * 12.0);
  cameraPosition.xy *= rot(sin(t * 0.7) * 12.0);
  vec3 cameraForward=normalize(cameraTarget-cameraPosition),         //Camera forward
  cameraLeft=normalize(cross(cameraForward,vec3(0,1,0))),       //Camera left
  cameraTop=normalize(cross(cameraLeft,cameraForward));         //Camera top
  mat3 cameraDirection=mat3(cameraLeft,cameraTop,cameraForward);//Camera direction matrix
  
	if(UV.x<100){                      //Amount / Density of particles
    vec3 p=hash_v3();
    p -= 0.5;
    p *= 10.0;
    
    for (int i = 0; i < 4; i++) {
      float r = hash_f();
      // Random variable

      // Pick a transformation
      if(r<.3){
        p += 0.3;
        p.xz *= rot(t);
        p /= clamp(dot(p,p),-0.1,4.);
        p += vec3(texture(texFFTSmoothed, 0.1).x,0.4,0.);
      } else if(r<.66){
        p.xz *= rot(5.2+ sin(float(uv.x * 1000.)*0.00001)*0.001);
        p.yz *= rot(5.2 + texture(texFFTSmoothed, 0.1).x * 10.0);
        p += vec3(-1.,0.4,0.);
        p /= clamp(dot(-p,p),-3.2,1.);
        p *= vec3(2,1.5,1.2)*1.5;
      }
      else {
        p -= vec3(-0.2,0.2,0.2);
        p /= clamp(dot(p,p),-4.5,10.);
        p += vec3(-1.,0.4,0.);
        p *= vec3(2,1.5,1.2)*3.1;
      }
    }

    int num_plots = 500;
    for (int i = 0; i < num_plots; i++) {
      vec3 p2 = p;
      // Classic camera example
  p2-=cameraPosition;                                             //Shift p to cameraPosition
  p2=p2*cameraDirection;                                          //Multiply by camera direction matrix

  //No camera example: careful, order matters
  //p.xz*=rotate2D(t);
  //p.z+=50;

  if(p2.z> 0.) {
    float fov=0.5;              //FIELD OF VIEW amount
    const float focus_dist = 6.0;
    float dof_scale = 70.0 + texture(texFFTSmoothed, 0.8).x * 2000.0;
    vec2 dof_sample = dof_scale * get_random_point_in_disk() * abs(p2.z - focus_dist) / min(v2Resolution.x, v2Resolution.y);
    p2.xy += dof_sample;
    vec2 anti_aliasing = get_random_point_in_disk() / min(v2Resolution.x, v2Resolution.y); 
    p2.xy += anti_aliasing;
    p2.xy/=p2.z*fov;              //Perspective projection using field of view above
    p2.x -= 0.3;
    p2.y -= 0.2;
    ivec2 q=ivec2((p2.xy+vec2(R.x/R.y,1)*0.5)*vec2(R.y/R.x,1)*R); //Convert to int
        //If point is NOT behind camera, draw point with gradient along p.z. Removing if(q.x>0) will make it trippy where things behind camera appear at front
        //CAREFUL when calling Add function. Here we are not doing it in a loop so it's ok. But if you were inside a loop, then you shouldnt do this like 100 times, if you do have loop of 100 make sure to exit early and / or not call Add every iterations
        if(q.x>0)Add(q,(10.0 + texture(texFFTSmoothed, 0.5).x * 2000.0)/float(num_plots)/p2.z);
      }
    }
  }
  //vec3 s = Read(ivec2(UV))*.3; //Read back compute texture pixel, *.3 controls the brightness of the  whole thing as it's additive

  //Recalculate uv for vignette: This is only done to simplify making a vignette background by using uv in range -.5,.5. It's the original uv calc you get in bonzomatic start tunnel
  /*uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y); //Default uv calc from Bonzo, used for vignette
  uv-=.5;                                                                      //Default uv calc from Bonzo, used for vignette
  uv/=vec2(v2Resolution.y / v2Resolution.x, 1);                                //Default uv calc from Bonzo, used for vignette

  vec3 col = vec3(.4)-length(uv)*.5;                                           //Background colour and vignette
  col+=pow(s,vec3(.45));                                                       //Particle colour and gamma correction
  out_color = vec4(col,0);                                                     //Return final colour for pixel
  */
	float density_scaled = Read(ivec2(UV));
  int box_scale = 100 + int(texture(texFFT, 0.2).x * 80.0);
  density_scaled += Read(ivec2(UV) / box_scale * box_scale) * 0.1;
  float brightness = 10.0;
	density_scaled *= brightness;

	vec3 colour = pallete(density_scaled);
	colour *= density_scaled;
  colour += vec3(0.0, 1.0, 1.0) * texture(texFFT, 0.8).x * 100.0 * uv.y;
  //colour += vec3(0.0, 0.0, 0.7) * texture(texFFT, 0.2).x * 10.0 * (1.0 - uv.y);
	colour = colour / (1. + colour);

	out_color = vec4(vec3(1.0) - colour, 1.);
  
  out_color.xyz = mix(out_color.xyz, texture(texPreviousFrame, vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y)).xyz, 0.01);
  
  if (abs(uv.y - 0.5) > 0.3)
     out_color = vec4(vec3(0.0), 1.0);
}