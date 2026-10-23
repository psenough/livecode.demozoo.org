#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texAnim1;
uniform sampler2D texAnim2;
uniform sampler2D texAnim3;
uniform sampler2D texBorder;
uniform sampler2D texGlare;
uniform sampler2D texNytrik;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

// 
// GORE VALSSPEELERIJEEEEEE
//

// basisje 
const uniform float lutRes = 4096.0;
const uniform float guy = 512.0;
const uniform float ritchie = 275.0;
const uniform float frame_count = 111.0;

const uniform float animFPS = 25*0.624; // ? fine..

vec2 calcUV(vec2 uv, float frame)
{
  // verhoudingen..
  const float per_x = lutRes/guy;
  const float per_y = floor(lutRes/ritchie);
  const float y_adj = -fract(lutRes/ritchie);
  
  uv.x/=lutRes;
  uv.y/=lutRes+y_adj;
   
  // boooo fucking dacious
  uv.x *= guy;
  uv.y *= ritchie;
  
  frame = mod(frame, frame_count);
//  frame = mod(frame + texture(texFFT, uv.x)*exp(uv.y)).x, frame_count);
  float y_offs = ceil(frame/per_x);
  float x_offs = floor(mod(frame, per_x));
  
  uv.x += x_offs*(guy/lutRes);
  uv.y += y_offs*(ritchie/(lutRes+y_adj));
  
  return uv;
}

vec4 sampleFiltered(sampler2D lut, vec2 uv)
{
  float t = fGlobalTime;
  float frame = t*animFPS;
  
  // samplen met die fucking handel man
  vec2 uv0 = calcUV(uv, frame-2.f);
  vec2 uv1 = calcUV(uv, frame-1.f);
  vec2 uv2 = calcUV(uv, frame-0.f);
  vec2 uv3 = calcUV(uv, frame+1.f);
  vec2 uv4 = calcUV(uv, frame+2.f);

  vec4 frame0 = texture2D(lut, uv0);
  vec4 frame1 = texture2D(lut, uv1);
  vec4 frame2 = texture2D(lut, uv2); 
  vec4 frame3 = texture2D(lut, uv3);
  vec4 frame4 = texture2D(lut, uv4);

  // the dists are just the frame sampling things (-2 to 2) plus an offset thats the frac of uv.y minus a half (bends shit)
  float offset_dist = fract(uv.y)-0.5;
  float offs = offset_dist;
  float dist0 = 2.0 + offs;
  float dist1 = 1.0 + offs;
  float dist2 = 0.0 + offs;
  float dist3 = 1.0 + offs;
  float dist4 = 2.0 + offs;

  // add modulated "scan(d)lines" (<- booze cruise)
  vec4 scanline = frame0 * exp(-5.0 * dist0*dist0);
  scanline += frame1 * exp(-5.0 * dist1*dist1);
  scanline += frame2 * exp(-5.0 * dist2*dist2);
  scanline += frame3 * exp(-5.0 * dist3*dist3);
  scanline += frame4 * exp(-5.0 * dist4*dist4);

  return scanline;
}

//
// HEAVYWEIGHT SHADER GRAND PRIX ROUND #1
// kijk die hele bende kopieren we dus gewoon, het is niet alsof we verdrinken in tijd
//

// YES YES THIS IS MY CODE DONT GO ALL FUCKING POSTAL ON ME OK?

float laura(vec3 p)
{
    return cos(p.x)+cos(p.y*0.8)+cos(p.z);
    // ADD BLOBS
}

mat2 laurarot(float theta)
{
    return mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
}
                
vec3 lauranormal(vec3 p)
{                    
    float mid = laura(p);
    float eps = 0.1;
    vec3 normal;
    normal.x = laura(vec3(p.x+eps, p.y, p.z))-mid;
    normal.y = laura(vec3(p.x, p.y+eps, p.z))-mid;
    normal.z = laura(vec3(p.x, p.y, p.z+eps))-mid;
    return normalize(normal);
}

vec3 laurapath(float time)
{
    return vec3(0., 0., time*3.);
}


vec4 grandprix(vec2 uv)
{
   // store raw
   vec2 fragCoord=uv;
  
    // calc fx uv
//    uv /= v2Resolution;

  // Calculate P which is [-1..1] on 2 axis
    vec2 p = -1. + 2. * uv.xy/v2Resolution.xy;

    // Final color (RGB), reset
    vec3 col = vec3(0.);
    
    // Eye position
    vec3 eye = laurapath(fGlobalTime);
    
    // Main direction vector
    vec3 dir = vec3(p.x, p.y, 1.);

    vec4 syncding = texture(texFFTSmoothed,0.1);
    
    // Rotate that vector
    // ** SYNC **
    mat2 mrot1 = laurarot(fGlobalTime*0.3);
    mat2 mrot2 = laurarot(fGlobalTime*0.6);
    dir.yx *= mrot1;
    dir.zy *= mrot2 + syncding.x;
    dir =  normalize(dir);
    
    // Light position (REMEMBER: add eye pos.)    
    vec3 lpos = vec3(dir.x, dir.y, -1.);
    lpos += eye;
    
    // March shape + calculate normal 
    float total = 0.;
    float march;
    vec3 hit = vec3(0.);
    for (int i = 0; i < 96; ++i)
    {
        march = laura(hit);
        total += march;
        hit = eye + dir*total;
    }
    
    vec3 normal = lauranormal(hit);

    // March reflection
    vec3 reflhit = hit;
    float refltotal = total; // IMPORTANT: do *not* set to 0!
    vec3 refldir = reflect(dir, normal);
    vec3 refleye = hit;
    for (int i = 0; i < 64; ++i)
    {
        float march = laura(reflhit);
        refltotal += march; 
        reflhit = refleye + refldir*refltotal;
    }
    
    // Lighting for reflection
    vec3 r_normal = lauranormal(reflhit);
    vec3 r_ldir = normalize(lpos-reflhit);
    float r_diffuse = max(0., dot(r_normal, r_ldir));
    float r_fresnel = pow(max(0., dot(r_normal, r_ldir)), 24.);

    // Main color
    vec3 albedo = vec3(0.2, 0.3, 0.6);

    // Lighting for main shape
    vec3 ldir = normalize(lpos-hit);
    float diffuse = max(0., dot(normal, ldir));
    float fresnel = pow(max(0., dot(normal, ldir)), 24.);

    // Rim lighting (IMPORTANT)
    float rim = diffuse*diffuse;
    rim = clamp((rim-0.13)*8., 0., 1.);

    // This is a powerful part, easy to memorize, just recalculate the normal
    // using hit position and wobble it, then use it to influence yMod for stripes
 //   vec3 funk = lauranormal(hit + cos(fGlobalTime*0.3) + texture(texFFTSmoothed, rim).xxx);
   vec3 funk = lauranormal(hit + cos(fGlobalTime*0.3));
    float ymod = 0.5 + 0.5*sin(hit.y*16. + funk.x*32. + cos(fGlobalTime*0.4));
  //  ymod = 3.14*texture(texFFTSmoothed, funk*rim);
    diffuse *= ymod;
    ymod *= 0.5;
    ymod *= ymod;
    diffuse += ymod;
    // ^ Many variations of this work
 
    // Lighting: just set to diffuse, then add diffuse*rim, add fresnel and mix
    // with reflection albedo*diffuse*fresnel*ymod based on a factor of sorts
    col = albedo*diffuse;
    col += albedo*diffuse*rim;
    col += fresnel;
    col = mix(col, albedo*r_diffuse*r_fresnel*ymod, diffuse); 
    
    // Add fog (can colorize withou artifacts)
    float fog = 1.-(exp(-0.01*total*total));
    col = mix(col, vec3(0.1, 0., 0.), fog); // COLOR YOUR FOG!
    
    // Multiply with vignette, only special part is pow(vignette*(1.-fog), ..)
    float vignette = 1./(p.x*p.x + p.y*p.y);
    col *= pow(vignette*(1.-fog), 1.4); // REMEMBER *= and *= 1.-fog

    // Interlace
    float inter = mod(fragCoord.y, 2.);
    if (inter > 1.)
        col *= 0.76;
    
    //col.xyz = vec3(r_fresnel);
    
    // Output to screen
    return vec4(col,1.0);
}


//
// THE PIMP BRIGADE LIVES!!
//

#define GRAND_PRIX
#define LOGOMASK // alles erachter plakken
//#define HUUBSTAPEL // alleen movie

vec2 radialDistort(vec2 uv)
{
  vec2 ctr = vec2(uv.x-0.5, uv.y+0.5);
  float dist = dot(ctr, ctr) * 0.08314;
  uv += ctr*((1.0+dist)*dist);
  return uv;  
}

void main(void)
{
  // RM UV
  vec2 rawuv = vec2(gl_FragCoord.x, gl_FragCoord.y);
  
  vec4 final = vec4(0.0);

  // all else UV
  vec2 uv = vec2(gl_FragCoord.x, gl_FragCoord.y*-1.0);
  uv /= v2Resolution;
  
  // crt bend
  vec2 rad_uv = radialDistort(uv);
  
  //
  // doe hier van je 2 fx blenden zodirect
  //
  
  // HIER GAAN WE DAN
  
    // blenden tussen die zooi is misschien wel handig

    float blendie = mod(fGlobalTime, animFPS); // waarom ook niet he
    float halfanimFPS = animFPS*0.5;
    if (blendie > halfanimFPS) blendie = halfanimFPS-(blendie-halfanimFPS);
    blendie /= halfanimFPS;


//#ifndef GRAND_PRIX
    float looper = mod(fGlobalTime*animFPS, frame_count*3.0);
    if (looper < 1.0*frame_count)
      final = sampleFiltered(texAnim1, rad_uv);
   else if (looper < 2.0*frame_count)
     final = sampleFiltered(texAnim2, rad_uv);
  else
      final = sampleFiltered(texAnim3, rad_uv);
  
  // godse smerig
  if (rad_uv.x < 0.0) final = vec4(0.0);
  if (rad_uv.x > 1.0) final = vec4(0.0);
  if (rad_uv.y > 0.0) final = vec4(0.0);
  if (rad_uv.y > 1.0) final = vec4(0.0); // fuck die geflipte bs altijd
  
//#else
  vec4 hadikmeegewonnen = grandprix(rawuv);
//#endif

#ifndef HUUBSTAPEL  
  final += hadikmeegewonnen*pow(blendie,4.0);
#endif
  //mix(final, final + 0.314*hadikmeegewonnen, blendie);
//    final = hadikmeegewonnen;
//  final = vec4(blendie);

  // bleed
  vec4 dotWeights = mix(
    vec4(1.0, 0.7, 1.0, 1.0),
    vec4(0.7, 1.0, 0.7, 1.0),
  0.134+floor(mod(uv.x*v2Resolution.x, 2.0)));
  
  final *= dotWeights;
    
  // lowlife sony
  vec4 border = texture(texBorder, uv);
  final = mix(final, border*0.7, border.w);

  // glare dingetje
  vec4 glare = texture(texGlare, uv);
  final = final + final*glare;

  // nytrik (masked or not)
  vec2 nytuv = rad_uv;
#ifdef LOGOMASK
  // in het midden en de rest wegmodulaten
  vec4 nytrik = texture2D(texNytrik, nytuv);
  final = final*0.1314*nytrik;
#else
  // gewoon lekker optellen die shit en in de hoek sodemieteren
  nytuv.x += -0.35;
  nytuv.y -= 0.134;
  vec4 nytrik = texture(texNytrik, nytuv);
  final += nytrik;
#endif


  // rare vignette, ff denken...
  float vignette = pow(abs(1.0-length(uv*uv)), 1.28);
  final = (0.5*final + 0.5*(final*vignette));
  
  // beetje lichter? ff kijken..
  float invgamma = log(55.22); // haha dit slaat fucking nergens op
  final *= invgamma;
  
  

  out_color = final;
}
