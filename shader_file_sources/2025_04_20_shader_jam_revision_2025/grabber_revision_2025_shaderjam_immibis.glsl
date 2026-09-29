#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAcorn1;
uniform sampler2D texAcorn2;
uniform sampler2D texChecker;
uniform sampler2D texLeafs;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;
uniform sampler2D texLynn;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything



// (distance, object type, unused, unused)
// 1: cube
// 2: anticube
// 3: sphere
  
vec4 sdfCube(vec3 pos, float radius) {
  return vec4(max(max(abs(pos.x),abs(pos.y)),abs(pos.z))-radius,1,0,0); // not accurate
}
vec4 sdfExcludeRegion(vec3 pos) {
  float f;
  f = max(abs(pos.x),abs(pos.z))-0.5;
  f = max(f, pos.y);
  return vec4(f,0,0,0);
  return vec4(f,0,0,0);
}
vec4 sdfAnticube(vec3 pos, float radius) {
  pos = abs(pos);
  //pos.x = pos.y;
  float f = max(max(min(pos.x,pos.y), min(pos.x, pos.z)), min(pos.y, pos.z))-radius; // not accurate
  // how to exclude one dimension
  //pos.zy = pos.yz;
  //float f = max(max(min(pos.x,pos.y), min(pos.x, pos.z)), pos.y)-radius;
  return vec4(f,2,0,0);
}
vec4 sdfSphere(vec3 pos, float radius) {
  return vec4(length(pos) - radius,3,0,0);
}

void rotate(inout vec2 v, float a) {v = vec2(v.x*cos(a)+v.y*sin(a), v.y*cos(a)-v.x*sin(a));}

vec4 union_(vec4 a, vec4 b) {
  if(a.x < b.x) return a; else return b;
}

vec4 zcyl(vec3 pos, float radius) {
  return vec4(length(pos.xy) - radius, 4, 0, 0);
}

vec4 subtract(vec4 a, vec4 b) {
  //if(b.x < 0)
    //return vec4(-b.x,0,0,0);
  //else
    return vec4(max(a.x,-b.x),a.yzw);
}

float b, c;
vec3 camera;

vec4 pipe(vec3 pos) {
  return zcyl(pos, 0.3);
}

vec4 sdf(vec3 pos) {
  
  float depth = (pos.z - camera.z);
  
  //if(0 != (int(floor(pos.y)) & 1)) pos.z += 2.5;
  //if(0 != (int(floor(pos.x)) & 1)) pos.y += 2.5;
  
  //pos.y += mod(floor(pos.z) - floor(camera.z), 5)/5;
  //pos.y += mod(pos.z - camera.z, 5)/5;
  //pos.y += sin((camera.z - pos.z)/2)*0.2;
  
  //rotate(pos.xy, pos.z/10);
  
  vec3 realpos = pos;
  //pos /= 5.0;
  
  
  if(true) {
    for(int rep = 0; rep < 3; rep++) {
      pos.x = abs(pos.x);
    //pos.y += pos.z*pos.z/10;
    
      rotate(pos.xy, fGlobalTime/(3+rep)/* + pos.z*0.1*/);
      //pos.xyz = pos.yzx;
      //pos = mod(pos, 20.0) - 10.0;
    }
  }
  
  if(false) {
    for(int rep = 0; rep < 1; rep++) {
      rotate(pos.xy, floor(pos.z)*fGlobalTime/15);
      pos.xyz = pos.yzx;
    }
  }
  
  vec4 result = sdfAnticube((mod(pos, 1.0)-0.5), 0.02);
  //result = subtract(result, sdfExcludeRegion(realpos));
  result = union_(result, pipe(mod(realpos,5.0)-2.5));
  //vec4 result = pipe(mod(realpos,5.0)-2.5);
  return result;
}

vec3 normal(vec3 pos) {
  vec2 d = vec2(0.01,0);
  return normalize(vec3(sdf(pos+d.xyy).x,sdf(pos+d.xyx).x,sdf(pos+d.xxy).x)-sdf(pos).x);
}
  
void main(void)
{
  vec2 fragcoord = gl_FragCoord.xy;
  
	vec2 uv = fragcoord / v2Resolution.xy;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  //uv.x += texture(texFFTSmoothed, abs(uv.y)).x*abs(uv.y)*10;
  
  vec3 dir = normalize(vec3(uv.x, 1.1, uv.y));
  vec3 pos = vec3(0, -5, 0);
  
  if(false) {
    rotate(pos.xz, fGlobalTime/3);
    rotate(dir.xz, fGlobalTime/3);
  }
  //pos.z += fGlobalTime*2;
  
  rotate(dir.xz, cos(fGlobalTime/2)/3);
  rotate(dir.yz, sin(fGlobalTime/3)/3);
  
  rotate(pos.xy, fGlobalTime/2);
  rotate(dir.xy, fGlobalTime/2);
  
  
  
  camera = pos;
  
  pos += dir*2; // near clipping sphere
  
  float a = texture(texFFTSmoothed, 0.02).x*5;
  b = texture(texFFTSmoothed, 0.03).x;
  c = texture(texFFTSmoothed, 0.1).x;
  //c=b-c; b=b-c;
  
  out_color = vec4(0);
  float halo = 0;
  for(int step = 0; step < 100; step++) {
    vec4 sdf = sdf(pos);
    //float bright = 1/length(pos-camera);
    float bright=1;
    if(sdf.x < 0.008) {
      vec3 normal = normal(pos);
      if(sdf.y == 4) {
        //dir = normalize(reflect(normalize(dir), normalize(vec3(pos.xy,0)));
        //pos.xy = -pos.xy;
        pos += dir*0.1;
        //dir = dir.yxz;
        
        
        // needs correct formula to remove hack
        vec3 ball = vec3(0,0,floor(pos.z)+fract(fGlobalTime));
        if(abs(ball.z-pos.z) > abs(ball.z+1-pos.z)) ball.z+=1;
        else if(abs(ball.z-pos.z) > abs(ball.z-1-pos.z)) ball.z-=1;
        
        out_color += vec4(1,1,1,0)*(1-out_color.a)/length(ball.z-pos.z)/50*bright;
        
        float fft = mod(abs(pos.y/2),1);
        out_color += vec4(0,1,0,0)*(1-out_color.a)*0.2*texture(texFFT, fft).x*fft*40*bright;
        
        continue;
        //break;
      }
      /*if(pos.y < 0 && abs(pos.x) < 0.5 && abs(pos.z) < 0.5) {
        pos += dir * 0.2;
        continue;
      }*/
      float shading = (0.5+0.5*normal.x)*5/length(pos - camera);
      
      //if(sdf.y == 3 || sdf.y == 1)
        //out_color = vec4(0,shading,0,1);
      //else
        out_color += vec4(shading,0,0,1)*(1-out_color.a);
      break;
    }
    halo += 0.003/sdf.x*bright;
    pos += dir * sdf.x;
    //pos += dir * 0.05;
  }
  out_color.b += halo*(0.03+a/2);
  
  if(false) {
    float whichtex = mod(fGlobalTime*0.5, 2.0);
    if(whichtex < 0.2 || (whichtex >= 0.4 && whichtex <= 0.6)) {
      //vec2 uv = vec2(gl_FragCoord.xy - (v2Resolution.xy)/2) / v2Resolution.yy);
      uv = -uv;
      uv -= 0.5;
      if(abs(uv.x+0.5) < 0.5) {
        vec4 texval;
        if(whichtex < 0.2) {
          texval = texture(texRevisionBW, uv);
        } else {
          texval = texture(texLynn, uv);
        }
        out_color += (texval - out_color)*texval.a;
      }
    }
  }
  
  //float d = texture(texFFT, 0.01).x;
  //out_color += (texture(texPreviousFrame, gl_FragCoord.xy/v2Resolution.xy)-out_color)*(1 - d);
  
}