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
uniform sampler2D texRevision;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float fft = 0.0;
float fftS = 0.0;
float fftI = 0.0;
float beat = 0.0;
float beatStep = 0.0;

vec3 repeat( vec3 p, vec3 c)
{
  vec3 q = mod( p+0.5*c, c)-0.5*c;
  return q;
}

vec3 rotate( vec3 p, float x, float y, float z)
{
  mat3 rotx = mat3( 1.0, 0., 0, 0, cos(x), -sin(x),0, sin(x), cos(x));
  mat3 roty = mat3( cos(y), 0, sin(y), 0,1,0, -sin(y), 0, cos(y));
  mat3 rotz = mat3( cos(z), -sin(z), 0, sin(z), cos(z), 0,0,0,1);
  return rotx*roty*rotz*p;
}

vec3 getcam( vec3 cam, vec3 target, vec2 uv, float fov)
{
  vec3 forward = normalize( target - cam );
  vec3 right = normalize( cross( vec3(0,1,0), forward ));
  vec3 up = normalize(cross( forward, right) );
  
  return normalize(vec3( uv.x * right + uv.y * up + fov*forward));
}

float prism( vec3 p, vec2 h)
{
  vec3 q = abs(p);
  return max(q.z-h.y, max(q.x*0.866025+p.y*0.5, -p.y) -h.x*0.5);
}

float roundcube(vec3 p, vec3 b, float r)
{
  vec3 d = abs(p) -b;
  return min(max(d.x, max(d.y,d.z)),0.0)+length(max(d,0.0))-r;
}

float cube( vec3 p, vec3 size)
{
  vec3 q = abs(p)-size;
  return length( max(q,0.0) + min( max(q.x, max(q.y,q.z) ), 0.0 ));
}

float sphere( vec3 p, float r)
{
  return length(p)- r;
}

vec3 map( vec3 p)
{
  float rx =beat*0.7+beatStep*0.1 + fftI*8.0;// smoothstep(0.0,0.85, mod(fftI*10.,1.0))*0.1;
  float ry =beat*0.5+beatStep*0.1 + fftI*1.0;// smoothstep(0.0,0.85, mod(fftI*20.,1.0))*0.1;
  float rz =beat*1.0+beatStep*0.1 + fftI*1.0;// smoothstep(0.0,0.85, mod(fftI*10.,1.0))*0.1;
  
  vec3 id = floor(p*0.5-0.5);
  
  vec3 cp = repeat( p, vec3( 2.0, 2.0, 2.0));
  cp = rotate(cp, rx+id.x,ry+id.y,rz);
  
  float size = fract(id.x*100. + id.z*10+ id.y)*0.1;
  
  vec3 c =vec3(roundcube(cp,vec3(0.4+size), 0.025));
  vec3 s = vec3(prism(cp,vec2(0.5+size)));
  c.x = mix(c.x, s.x, mod(beat,2.0));
  return c;
}

vec3 normal( vec3 p)
{
  vec3 c = map(p);
  vec2 e = vec2(0.0001,0.0);
  return normalize( vec3(
    map(p+e.xyy).x,
    map(p+e.yxy).x,
    map(p+e.yyx).x
  )-c.x);
}

float diffuse(vec3 p, vec3 l, vec3 n)
{
  return max( dot( n, normalize(l-p)), 0.0);
}

vec3 march( vec3 cam, vec3 rd, out float t)
{
  t= 0.0;
  for(int i = 0; i < 100; i++)
  {
    vec3 p = cam + rd*t;
    vec3 r = map(p);
    float bx = cube(
      repeat( p + vec3(1.0), vec3(2.0,0,0)),
      vec3(0.00001,100,100));
    float bz = cube(
      repeat( p + vec3(1.0), vec3(0.0,0,2)),
      vec3(100,100,0.00001));
    float by = cube(
      repeat( p + vec3(1.0), vec3(0.0,2,0)),
      vec3(100,0.0001,100));
    
    float delta = min(max(0.1, bx), r.x);
    delta = min( max(0.1, bz), delta);
    delta = min( max(0.1, by), delta);
    
    if(r.x < 0.001)
    {
      return r;
    }
    t+=delta*0.9;
    if(t> 10.0) return vec3(-1);

  }
  return vec3(-1);
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec4 col = vec4(0.);
  
  vec4 previous = texture(texPreviousFrame, uv);
  
  beat = floor( fGlobalTime*2.0);
  beatStep = fract( fGlobalTime*2.0);
  
  fft = texture(texFFT, 0.2).r;
	fftS = texture(texFFTSmoothed, 0.2).r;
	fftI = texture(texFFTIntegrated, 0.1).r;
	
  float bm = mod( beat/4.0, 6.0);
  
  float time = mod(fGlobalTime,100.0);
  
  vec3 cam = vec3(1,1,1);
  float cabeat = floor(beat/8.0);
  vec3 target = vec3(
    sin(cabeat*11.4)*10.,
    sin(cabeat*5.2)*10.,
    sin(cabeat*3.46)*10
  );
  
  
  if(bm < 0.5) {
    cam.x += time;
    target.x+=time;
  }
  else if(bm < 1.5) {
    cam.y += time;
    target.y+=time;
  }
  else if(bm < 2.5) {
    cam.z += time;
    target.z+=time;
  }
  else if(bm < 3.5) {
    cam.z -= time;
    target.z-=time;
  }
  else if(bm < 4.5) {
    cam.x -= time;
    target.x-=time;
  }
  
  vec3 light = vec3(0,4, sin(fGlobalTime));
  vec3 rd = getcam(cam, target, uv, 1.0);
  
  vec3 bg = vec3(1.0, 0.7,0.2);
  if(bm < 0.5) {
    bg *= 0.0;
  }
  else if(bm < 1.5) {
    bg *= fft*255.;
  }
  else if(bm < 2.5) {
    
  }
  else if(bm < 3.5) {
    cam.z -= time;
    target.z-=time;
  }
  else if(bm < 4.5) {
    cam.x -= time;
    target.x-=time;
  }
  
  
  
  
  float travel = 0.0;
  vec3 r = march(cam, rd, travel);
  vec3 p = cam + rd*travel;
  if(r.y < -0.5)
  {
    // bg
    
  }
  else if(r.y < 0.5)
  {
    vec3 n = normal(p);
    col.rgb =vec3( 1.0,0.5,0.2) * (0.25+diffuse(p, light, n)) * (fftS*50.+0.2);
    
    
    
    vec3 refd = reflect( rd, n);
    float reft = 0.0;
    vec3 refr = march( p + n*0.1, refd, reft);
    vec3 refc = vec3(0.0);
    vec3 refp = reft *refd + p+n*0.1;
    if(refr.y < -0.5){}
    else if(refr.y < 0.5){
      vec3 rn = normal(p);
      refc.rgb =vec3( 1.0,0.5,0.2) * (0.25+diffuse(refp, light, rn)) * (fftS*50.+0.5);
      refc.rgb *=1.0+ 15.0 / length(  100.*sin(fftI - refp.x*5.0+time) ) * (0.2+fftS*350.0);
      refc.rgb *=1.0+ 15.0 / length(  100.*sin(fftI - refp.z*5.0-time) ) * (0.2+fftS*350.0);
    }
    refc.rgb = mix(refc, bg, smoothstep( 8.0, 10.0, reft));
    col.rgb = mix(col.rgb, refc, 0.5);
    col.rgb *=1.0+ 15.0 / length(  100.*sin(fftI - p.x*5.0+time) ) * (0.2+fftS*350.0);
    col.rgb *=1.0+ 15.0 / length(  100.*sin(fftI - p.z*5.0-time) ) * (0.2+fftS*350.0);
  }
  
  col.rgb = mix(col.rgb, bg, smoothstep( 8.0, 9.0, travel));
  
  if(bm < 0.5) col.rgb = col.rbg;
  else if(bm < 1.5) col.rgb = col.brg;
  else if(bm < 2.5) col.rgb = col.bgr;
  else if(bm < 3.5) col.rgb = col.gbr;
  else if(bm < 4.5) col.rgb = col.grb;
  
  col.rgb += previous.rgb*smoothstep(0.5, 0.0, fftS*512.)*0.5;
  
	out_color = col;
}
















