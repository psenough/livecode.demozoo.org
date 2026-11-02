// can you see me? =)

// artemka @ SESSIONS 2o25 - 13.12.2o25

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

float hash3(vec3 co){
    return 2*fract(sin(dot(co, vec3(12.9898, 24.233, 16.4495))) * 47358.5453)-.5;
}

float hash2(vec2 co){
    return 2*fract(sin(dot(co, vec2(180.9898, 180.4495))) * 47358.5453)-.5;
}

float time = fGlobalTime;
float mt   = mod(time, 120);
float tt = mod(fGlobalTime + 0.00*hash2(gl_FragCoord.xy/v2Resolution), 180.0);

const float PHI = 1.6180339887498948482;
const float PI  = 3.141592653589793;

mat2 rot2(float a) {return mat2(cos(a), sin(a), -sin(a), cos(a)); }

// font
const int font[] =  int[](
    0,0,0,0,0,0,48,48,48,0,48,0,
    40,40,0,0,0,0,20,62,20,62,20,0,
    30,40,28,10,60,0,34,4,8,16,34,0,
    16,40,26,36,26,0,16,32,0,0,0,0,
    16,32,32,32,16,0,32,16,16,16,32,0,
    8,42,28,42,8,0,0,16,56,16,0,0,
    0,0,0,48,16,32,0,0,56,0,0,0,
    0,0,0,48,48,0,2,4,8,16,32,0,
    28,54,58,50,28,0,24,56,24,24,60,0,
    60,6,28,48,62,0,62,6,12,38,28,0,
    12,28,52,62,4,0,62,48,60,6,60,0,
    28,48,60,50,28,0,62,6,12,24,48,0,
    28,50,28,50,28,0,28,50,30,2,28,0,
    48,48,0,48,48,0,48,48,0,48,16,32,
    8,16,32,16,8,0,0,56,0,56,0,0,
    32,16,8,16,32,0,60,12,24,0,24,0,
    28,42,46,32,28,0,28,50,50,62,50,0,
    60,50,60,50,60,0,28,50,48,50,28,0,
    60,50,50,50,60,0,62,48,60,48,62,0,
    62,48,60,48,48,0,30,48,54,50,30,0,
    50,50,62,50,50,0,60,24,24,24,60,0,
    62,6,6,54,28,0,50,52,56,52,50,0,
    48,48,48,48,62,0,54,62,62,42,34,0,
    50,58,62,54,50,0,28,50,50,50,28,0,
    60,50,50,60,48,0,28,50,50,50,28,2,
    60,50,50,60,50,0,30,56,28,14,60,0,
    60,24,24,24,24,0,50,50,50,50,28,0,
    50,50,50,28,8,0,34,42,62,62,54,0,
    50,50,28,50,50,0,52,52,60,24,24,0,
    62,12,24,48,62,0,48,32,32,32,48,0,
    32,16,8,4,2,0,48,16,16,16,48,0,
    8,20,34,0,0,0,0,0,0,0,60,0,
    32,16,0,0,0,0,0,30,38,38,30,0,
    48,60,50,50,60,0,0,30,56,56,30,0,
    6,30,38,38,30,0,0,28,54,56,28,0,
    14,24,62,24,24,0,0,28,38,62,6,28,
    48,60,50,50,50,0,48,0,48,48,48,0,
    6,0,6,6,38,28,48,50,60,50,50,0,
    48,48,48,48,28,0,0,52,62,42,42,0,
    0,60,50,50,50,0,0,28,50,50,28,0,
    0,60,50,50,60,48,0,30,38,38,30,6,
    0,60,50,48,48,0,0,30,56,14,60,0,
    24,62,24,24,14,0,0,50,50,50,28,0,
    0,50,50,28,8,0,0,34,42,62,54,0,
    0,54,28,28,54,0,0,38,38,30,6,28,
    0,62,12,24,62,0,24,16,48,16,24,0,
    32,32,32,32,32,0,48,16,24,16,48,0,
    0,20,40,0,0,0,48,48,0,0,0,0
);

int text[] = int[](
    0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,
    73,78,70,73,78,73,84,69,0,82,69,90,73,78,65,0,
    69,78,71,73,78,69,0,86,16,14,16,18,17,0,0,0,0,0,0
    // quake N balls
);

// char grid
vec3 drawgrid(vec2 fuv, vec2 o, vec4 b, float scale, vec3 col, int ofs) { 
  if (fuv.x < b.x || fuv.y < b.y || fuv.x > b.z || fuv.y > b.w) return col;
  
  // aa borked at the last time :/
#if 1
  vec3 ccc  = vec3(0.0);
  for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
  fuv += vec2(-b.x,b.y);
  fuv.y = 1.0 - fuv.y;
  
  ivec2 cg = ivec2(floor(fuv*scale));
  if (cg.y < 0 || cg.y > 5) return col;
  
  int bitpos = 0x20 >> (cg.x%6);
  int bit = font[((text[(ofs + cg.x/6) % text.length()]*6)+(int((cg.y)))) % font.length()] & bitpos;
    //ccc += ;
    return bit==0 ? col : col + 0.5*vec3(1.0);
  }
#else
  vec3 ccc  = vec3(0.0);
  for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
    fuv += vec2(-b.x,b.y) + 0.1*vec2(x,y);
    fuv.y = 1.0 - fuv.y;
    
    ivec2 cg = ivec2(floor(fuv*scale));
    if (cg.y < 0 || cg.y > 5) ccc += vec3(0.0);
    
    int bitpos = 0x20 >> (cg.x%6);
    int bit = font[((text[(ofs + cg.x/6) % text.length()]*6)+(int((cg.y)))) % font.length()] & bitpos;
    ccc += (bit==0 ? col : col + 0.5*vec3(1.0));
  }
  return ccc;
#endif
}

// raymarching stuff
// some of those was recycled, blatantly. you know :)
// thanks for iq, 0b5vr, canmom and everyone else

float smin( float a, float b, float k )
{
    k *= 2.0;
    float x = b-a;
    return 0.5*( a+b-sqrt(x*x+k*k) );
}

float sdRoundCone( vec3 p, float r1, float r2, float h )
{
  float b = (r1-r2)/h;
  float a = sqrt(1.0-b*b);

  vec2 q = vec2( length(p.xz), p.y );
  float k = dot(q,vec2(-b,a));
  if( k<0.0 ) return length(q) - r1;
  if( k>a*h ) return length(q-vec2(0.0,h)) - r2;
  return dot(q, vec2(a,b) ) - r1;
}

vec3 sphericalFibonacci(float t) {
    float z = 1 - 2 * t;
    float r = sqrt(max(0, 1 - z * z));
    float theta = 2 * PI * t * PHI;
    return vec3(r * cos(theta), r * sin(theta), z);
}

mat3 matup(vec3 u) {
    u = normalize(u);
    vec3 r = abs(u.y) < 0.999 ? vec3(0,1,0) : vec3(1,0,0);
    r = normalize(cross(r, u));
    vec3 f = cross(u, r);
    return mat3(r, u, f);
}

float sphere(vec3 p, float r) {return length(p) - r;}

float map(vec3 p) {
  p.xy*=rot2(tt*0.4+sin(length(p.xy))*(0.4 + 0.2*(1+sin(mt*0.4))));
  p.yz*=rot2(tt*0.5+sin(length(p.yz))*(0.3 + 0.2*(1+cos(mt*0.2))));
  p.xz*=rot2(tt*0.7+sin(length(p.xz))*(0.5 + 0.2*(1+cos(mt*0.23))));
  
  p += vec3(sin(mt*0.2), 0.3*sin(mt*0.2), 0.3*sin(mt*0.2));
  
  float sph = sphere(p, 1 + 0.8*pow(texture(texFFT, 0.01).r, 0.4));
  for (int i = 0; i < 5; i += 1) {
    sph = smin(sph, sdRoundCone( p*matup(sphericalFibonacci(i/5.0)), 0.5, 0.1, 3), 0.1);
    sph = smin(sph, sdRoundCone(-p*matup(sphericalFibonacci(i/5.0)), 0.5, 0.1, 3), 0.1);
  }

  return sph*0.4;
}

vec3 norm(vec3 p) {
  vec2 b = vec2(0., 0.001);
  float a = map(p);
  return normalize(vec3(
    -a+map(p+b.yxx),
    -a+map(p+b.xyx),
    -a+map(p+b.xxy)
  ));
}

vec3 trace(vec3 o, vec3 d) {
  float t = 0.;
  float mct = 1000.0;
  float refl = 0.0;
  for (int i = 0; i < 128; i++) {
    vec3 p = o + t*d;
    float ct = map(p);
    if ((ct < 0.001) || (t > 32.)) break;
    t += ct;
    mct = min(mct, abs(ct));
    refl += exp(-abs(ct)*90);
  }
  
  return vec3(t, mct, refl/(10+refl));
}

vec3 light(vec3 p, vec3 o, vec3 l, vec3 n, vec3 r) {
 
  float al = 3*textureLod(texNoise,n.xy*0.3,2).r+textureLod(texNoise,n.yz*0.5,2).g+textureLod(texNoise,n.xz*0.2,2).b;
  float a = 0.2;
  a += 0.2*max(dot(n, l), 0);
  a *= al;
  a += 0.8*pow(max(dot(l, r), 0), 16);
  a  = a/(1.0+0.1*a);
  a  = min(a, 1.0);
  //a  = pow(a, 2.4);
  vec3 b = pow(vec3(a),vec3(1,0.7, 0.6));
  b = pow(b, vec3(1.9));
  return b;
}

float box2(vec2 p, vec2 b) {
  vec2 d = abs(p)-b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0)-.02;
}

vec3 bgqrap(vec2 u) {
  vec3 a = vec3(0.0);
  for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {  
    vec3 c = 0.5*vec3(0.85, 0.99, 0.45);
    vec2 uv  = u + 0.0005*vec2(x,y);
    vec2 auv = abs(uv);
    bool h =  (auv.y > 0.48  || (auv.y > 0.47  && (-auv.x+auv.y > -0.1)));
    bool h2 = (auv.y > 0.485 || (auv.y > 0.475 && (-auv.x+auv.y > -0.05)));
    if (!((h&&h2) || (!h&&!h2))) c += vec3(0.6);
    
#if 1
    if (!h) {
      // first sub screen
      float dist = smin(dot(uv, normalize(vec2(0.3,0.1))) - 0.0, -(auv.y - 0.38), 5e-3);
      if (dist > -0.005) c = vec3(1.0);
      if (dist > 0) {
        c = 0.7*vec3(0.28, 0.56, 0.74);
        vec2 auv = (uv + vec2(mt*0.2,0)) * 2.9;
        vec2 gr  = mod(auv, 0.1) - 0.05;
        vec2 igr = auv - gr;
        if (length(gr) < texture(texFFT, mod(abs(igr.x) * 0.1, 0.2)).r) c += vec3(0.6);
      }
      
      // 2nd subscreen
      dist = smin(dot(uv, normalize(-vec2(0.3,0.1))) - 0.1, -(auv.y - 0.38), 5e-3);
      if (dist > -0.005) c = vec3(1.0);
      if (dist > 0) {
        c = 0.7*vec3(0.83, 0.66, 0.86);
        vec2 auv = (uv * rot2(tt*0.3)) * 2.9;
        vec2 gr  = mod(auv, 0.1) - 0.05;
        vec2 igr = auv - gr;
        if (length(gr) < (
          0.03+0.05*(sin(igr.x*(6.3+3.2*sin(mt*1.4))+mt*6.5)+sin(igr.y*+3.5*sin(mt*1.4)+mt*7.3)))
        ) c += vec3(0.6);
      }
    }
#endif
    
    if ((auv.x>0.84)&&(auv.x<0.843)&&(auv.y>0.35)&&(auv.y<0.45))  c += vec3(0.5);
    if ((auv.x>0.74)&&(auv.x<0.843)&&(auv.y>0.45)&&(auv.y<0.453)) c += vec3(0.5);
    
    for (int i = 0; i < 75; i++) {
      vec2 a = vec2(auv.x, uv.y) - vec2(i*0.01, -0.45);
      if (a.x > 0.05 && a.x < 0.055 && a.y > 0.01 && a.y < 0.2*pow(texture(texFFT, i*0.0004).r, 0.6)) c += vec3(0.3);
    }
    
    a += c;
  }
  return a/9;
}

void main(void)
{
	vec2 fuv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 uv = fuv - 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec3 color = bgqrap(uv);
  vec3 rmcol = vec3(0);
  
  // REZINA ENGINE
  {
    text[0] = (int(time)/1000 % 10) + 16;
    text[1] = (int(time)/100 % 10) + 16;
    text[2] = (int(time)/10 % 10) + 16;
    text[3] = (int(time)/1 % 10) + 16;
    text[5] = (int(time*10) % 10) + 16;
    text[6] = (int(time*100) % 10) + 16;
    text[7] = (int(time*1000) % 10) + 16;
    
    text[44] = (mod(time, 1) < 0.5) ? 0 : 63;
  }
  
  color = drawgrid(fuv/vec2(v2Resolution.y / v2Resolution.x, 1), vec2(0.0), vec4(0.065+1.495,0.065,0.3+1.8,1), 300, color, 0);
  color = drawgrid(fuv/vec2(v2Resolution.y / v2Resolution.x, 1), vec2(0.0), vec4(0.065,0.065,0.7,1), 300, color, 16);
  color *= 1.0-0.7*length(fuv-vec2(0.5)-0.05*hash2(uv+0.002*mt));
  
  // anyway we're continuing
  
  // todo better ray position
  vec3 ray = normalize(vec3(uv, -0.7));
  vec3 o = vec3(0,0,4);
  float d = 0.6*sin(tt*2.2)+0.9;
  vec3 fp = o + d*ray;
  o.x += 0.01*hash2(uv*3+mod(mt,1));
  o.y += 0.01*hash2(uv*2+mod(mt,1));
  ray = normalize(fp - o);
  
  vec3 tm = trace(o, ray);
  //vec3 tm = vec3(128,0,0);
  vec3 l = normalize(o);
  float t = tm.x;
  //color += 0.3*vec3(tm.z);
  if (!((t == 0.0) || (t > 32.0))) {
    vec3 p = o+t*ray;
    vec3 n = norm(p);
    vec3 r = reflect(-l, n);
    rmcol = light(p, o, l, n, r);
    
    rmcol = rmcol / (1.0 + 0.3*rmcol);
    color = rmcol;
  }
  
  vec2 pp = vec2(ivec2(fuv/vec2(v2Resolution.y / v2Resolution.x, 1)*20));
  pp = 0.01*(vec2(hash2(90*pp), hash2(91*pp)))*vec2(sin(pp.y*40.4+tt*2.3),cos(pp.x*40.4+tt*3.3));
  vec3 pf = vec3(0.0);
  for(int i = -1; i<=1; i++) {
    for(int j = -1; j<=1; j++) {
      pf += textureLod(texPreviousFrame, 1.0*(gl_FragCoord.xy + vec2(i,j))/v2Resolution + pp, 0).xyz;
    }
  }
  
  color = pow(color,vec3(0.6));
  color = mix(color,pf/9, exp(-fFrameTime*(90 + 50*sin(mt*0.3))));
  color = clamp(color, vec3(0), vec3(1));
  
	out_color = vec4(color,1.0);
}