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
uniform sampler2D texSessions;
uniform sampler2D texShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define res v2Resolution
#define time fGlobalTime

const float PACK_SCALE = 65535.0;
const float PACK_SPLIT = 65536.0;
const uint PACK_SPLIT_U = 65536u;

// presets
vec3 hsv2rgb(vec3 c) {
  vec3 p = abs(fract(c.xxx + vec3(0.0, 1.0 / 3.0, 2.0 / 3.0)) * 6.0 - 3.0);
  return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

mat3 orthbas(vec3 z) {
    z = normalize(z);
    vec3 up = abs(z.y) > 0.99 ? vec3(0, 0, 1) : vec3(0, 1, 0);
    vec3 x = normalize(cross(up, z));
    return mat3(x, cross(z, x), z);
}

vec3 cyclic(vec3 p, float pers, float lacu) {
    mat3 b = orthbas(vec3(-4, sin(fGlobalTime), -2));
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 5; i++) {
        p *= b;
        p += sin(p.zxy);
        sum += vec4(cross(cos(p), sin(p.yzx)), 1.0);
        sum /= pers;
        p *= lacu;
    }
    return sum.xyz / sum.w;
}


vec3 lookAt(vec3 from, vec3 at, vec2 uv, float fov) {
    vec3 z = normalize(at - from);
    vec3 x = normalize(cross(vec3(0, 1, 0), z)); // keep right-handed basis (avoids horizontal flip)
    vec3 y = normalize(cross(z, x));
    return normalize(z * fov + uv.x * x + uv.y * y);
}

// compute

uint pack(float v){return uint(clamp(v,0.,1.) *PACK_SCALE + 0.5);}
float unpack(uint v){return float(v)/ PACK_SCALE;}

float getDepthBack(vec2 idx) {
  ivec2 id = ivec2(idx*res);
  return unpack(imageLoad(computeTexBack[0],id).x);
  }

vec3 unpackHSV(vec2 idx) {
    ivec2 id = ivec2(idx*res);
    uint hU = imageLoad(computeTexBack[1],id).x;
    uint svU = imageLoad(computeTexBack[2],id).x;
    uint sU = svU /PACK_SPLIT_U;
    uint vU = svU -sU* PACK_SPLIT_U;
  return vec3(float(hU),float(sU),float(vU))/PACK_SPLIT;
}

vec4 getBack(vec2 uv){
  vec3 c = hsv2rgb(unpackHSV(uv));
  float d = getDepthBack(uv);
  return vec4(c,d);
 }
 
 vec4 getBackBlur(vec2 idx) {
  float sumW = 0.0;
  float sumD = 0.0;
  vec3 sumC = vec3(0.0);
  for (int oy = -1; oy <= 1; ++oy) {
    for (int ox = -1; ox <= 1; ++ox) {
      vec2 uv = idx + vec2(float(ox), float(oy)) / res;
      uv = clamp(uv, 0.0, 1.0);
      float d = getDepthBack(uv);
      if (d > 0.0 && d < 1.0) {
        float w = (ox == 0 && oy == 0) ? 4.0 : 1.0;
        sumW += w;
        sumD += d * w;
        sumC += hsv2rgb(unpackHSV(uv)) * w;
      }
    }
  }
  if (sumW > 0.0) {
    return vec4(sumC / sumW, sumD / sumW);
  }
  return vec4(0.0);
}


//tex
vec3 getTexture(vec2 uv){
    vec2 size = vec2(textureSize(texShort,0));
  float aspect = size.x /size.y;
  vec2 origin = vec2(1.0-aspect,0.0);
  vec2 local = (uv - origin) /vec2(aspect,1.0);
  local.y = 1.0 - local.y;
  return vec3(1.0 - texture(texShort,local)).rgb;
  }


vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float map(vec3 p) {
    float sph = length(p)-0.25;
    return sph;
}


void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    vec2 uvView = uv - 0.5;
    uvView /= vec2(v2Resolution.y / v2Resolution.x, 1);

    vec2 m;
    m.x = atan(uvView.x / uvView.y) / 3.14;
    m.y = 1 / length(uvView) * .2;
    float d = m.y;

	float f = texture( texFFT, d ).r * 100;
  f *= 0.15;
	m.x += sin( fGlobalTime ) * 0.1;
    m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  

    //vec3 cyc = cyclic(vec3(gl_FragCoord.xy*0.016+time*0.02,time*0.1),5.1,0.85);
    vec3 cyc = cyclic(vec3(gl_FragCoord.xy*0.02+time*1.2,time*5.1),8.1,1.0);
    //texUV += cyc.yz*0.15;
    // background: radial fade similar to reference
    float bg = smoothstep(2.0,0.5,length(uvView*2.0));
    t = vec4(vec3(0.5) * bg,1.0);

  //tex
    vec2 texUV = uv;
  texUV.x += time*0.05;
    //t -= vec4(getTexture(texUV),1.);

  //init
  float dist = 0.;
  float depth = 1.;
  
  
  
  
  //rayMarch
  float focal = 1.5;
  vec3 roCam=vec3(0.,0.,-2.5);
  vec3 rdCam=lookAt(roCam,vec3(0.0),uvView,focal);

    float maxSteps = 30.;
  float maxDist =30.;
  float steps = 0.;
  float travel = 0.;

    vec3 pos = roCam;
  for(steps = maxSteps; 0.0 < steps; --steps){
        float d = map(pos);
    if(d<travel / res.y || maxDist < travel) break;
        d *= 0.9 + 0.2 * cyc.x;
        pos += rdCam *d + .5 * cyc;
        travel += d;
    }

    float shade = steps / maxSteps;

  if(0.0001 < shade && travel < maxDist){
        vec2 noff = vec2(0.002,0.0);
        vec3 normal = normalize(
            map(pos) -vec3(
                map(pos - noff.xyy),
                map(pos - noff.yxy),
    map(pos - noff.yyx)
      )
    );
    

        float light = dot(reflect(rdCam,normal),vec3(0,1,0))*0.5 + 0.5;

        t.rgb = vec3(0.1);
        t.rgb += vec3(0.5) * pow(light,4.5);
        t.rgb *= pow(shade,0.5);
        depth = clamp(travel/maxDist,0.0,1.0);

    }

  
    //compute load

    vec4 back = getBackBlur(uv);
    float backRainbow = dot(normalize(vec3(uvView,0.0)), vec3(0,1,0)) * 0.5 + 0.5;
    vec3 backPalette = 0.5 + 0.5 * cos(vec3(0.0,0.3,0.6)*6.0 + (uvView.y*3.0 + time));
    float mask = smoothstep(0.03 + abs(sin(time))*0.1,0.0, back.a); 
    back.rgb = clamp(back.rgb + backPalette * pow(backRainbow,1.0) * mask, 0.0, 1.0);

    bool usedBack = false;
    //if(0.5 < length(back.rgb)){
    // allow equal depth so background still wins when we stored max depth (no hit)
  if(0.0 < back.a && back.a <= depth){
        //t =mix(t,back,0.5);
        //t*= back;

        t.rgb = back.rgb;
        depth = back.a;          // use stored depth for reprojection
        usedBack = true;
    }

  t = clamp( t, 0.0, 1.0 );
    //offset

    vec3 offset = cyclic(vec3(uvView*1.,fract(time*0.1)*10.1),6.,0.804)*.035;

    //proj
    float travelForProj = usedBack ? depth * maxDist : travel;
    vec3 baseCamSpace = rdCam * travelForProj;
    vec3 worldPos = baseCamSpace + roCam;
    vec3 movedPos = worldPos + offset;
    vec3 camSpace = movedPos - roCam;

    if (camSpace.z > 0.001) {
        vec2 proj = camSpace.xy * focal /  camSpace.z;

 
        //vec2 targetUV = uv + offset.xy;
        vec2 targetUV =0.5 + proj * vec2(res.y/res.x,1.0);
        targetUV = clamp(targetUV,0.0,1.0);
        ivec2 targetID = ivec2(targetUV * res);
        depth = length(camSpace)/maxDist;
        depth = clamp(depth,0.0,1.0);

        //pack
  vec3 hsv = rgb2hsv(t.rgb);
  imageStore(computeTex[0],targetID,uvec4(pack(depth)));
  imageStore(computeTex[1],targetID,uvec4(pack(hsv.x)));
        uint sPacked = pack(hsv.y);
        uint vPacked = pack(hsv.z);
  imageStore(computeTex[2],targetID,uvec4(sPacked*PACK_SPLIT_U+vPacked));
}
  
  
  
  

    // motion blur
    vec4 prevTex = texture(texPreviousFrame,uv);
  t = mix(t,prevTex,0.5);

    out_color = t;
}