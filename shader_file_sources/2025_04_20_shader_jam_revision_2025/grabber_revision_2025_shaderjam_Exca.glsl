#version 410 core

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
uniform sampler2D texLynn;
uniform sampler2D texNoise;
uniform sampler2D texRevisionBW;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

/** 
* Shared values
**/
vec2 screenUv;
float time;
float fft;
float fftI;
float fftS;
float beat = 0.0;
float beatstep = 0.0;
float bar = 0.0;
float barstep = 0.0;


/**
* Utility functions
**/
float hash( float p )
{
  return fract(dot( sin(p)*52.0451, p*123.51));
}

vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
  return a + b*cos( 6.283185*(c*t+d) );
}

vec3 getcam( vec3 from, vec3 to, vec2 uv, float fov)
{
  vec3 forward = normalize( to - from );
  vec3 right = normalize( cross( vec3(0,1,0), forward) );
  vec3 up = normalize( cross( forward, right ) );
  return normalize( forward * fov + uv.x * right + uv.y * up );
}

vec3 textureMapLynn( vec3 surfacepos, vec3 normal )
{
  mat3 trimap = mat3( 
    texture( texLynn, surfacepos.yz).rgb,
    texture( texLynn, surfacepos.xz).rgb,
    texture( texLynn, surfacepos.xy).rgb
  );
  return trimap * normal;
}
vec3 textureMapNoise( vec3 surfacepos, vec3 normal )
{
  mat3 trimap = mat3( 
    texture( texNoise, surfacepos.yz).rgb,
    texture( texNoise, surfacepos.xz).rgb,
    texture( texNoise, surfacepos.xy).rgb
  );
  return trimap * normal;
}

vec2 rot2d( float a, vec2 p)
{
  return mat2( cos(a), -sin(a), sin(a), cos(a)) * p;
}

/**
* Sdf operators
**/
vec3 repeat( vec3 p, vec3 q)
{
   return mod(p + q*0.5, q) - q*0.5;
}

/**
* SDF
**/
float sphere( vec3 p, float r )
{
  return length(p) - r;
}


/** MAP **/
vec3 map( vec3 p )
{
  vec2 id = floor( p.xz + 0.5);
  vec3 pS1 = repeat( p -vec3(0., 0.5, 0.0), vec3( 1.0, 0.0, 1.0));
  float n = textureMapNoise( pS1, pS1 + vec3(0,0.0, 0) ).r;
  
  float s1 = sphere( 
    pS1, 
    0.7 - sin(fftI)*0.1 - n*3.0 * smoothstep(0.0, 0.025, abs(sin(fftI*4.0+length(id)*0.5))*0.0125) 
  );
  vec3 S1 = vec3(s1, 1.0, 0.0);
  return S1;
}


/** Lights, normals etc **/
vec3 normal( vec3 p )
{
  vec3 c = map(p);
  vec2 e = vec2(0.1, 0.0);
  return normalize( vec3(
    map( p + e.xyy).x,
    map( p + e.yxy).x,
    map( p + e.yyx).x
  )) - c.x;
}

float diffuse( vec3 point, vec3 normal, vec3 light )
{
  return max( 0.0, dot( normal, normalize( light - point ) ) );
}

/** March loop **/
vec3 march( vec3 from, vec3 rayDir, out vec3 p, out float travel )
{
  float minDistance = 999.9;
  for(int i = 0; i < 100; i++)
  {
    p = from + rayDir * travel;
    vec3 result = map( p );
    travel += result.x * 0.5;
    minDistance = min( minDistance, result.x );
    if(result.x < 0.0001){
      result.z = minDistance;
      return result;
    }
    if( travel > 50.0 ) {
      travel = 50.0;
      return vec3( -1.0, -1.0, minDistance );
    }
  }
}

void main(void)
{
  // Set timing & audio sync related stuff
  time = fGlobalTime;
  fft = texture( texFFT, 0.25).r;
  fftS = texture( texFFTSmoothed, 0.2).r;
  fftI = texture( texFFTIntegrated, 0.15).r;
  beat = floor(time * 175.0 / 60.0);
  beatstep = fract( time * 175.0 / 60.0*1.0);
  bar = floor(beat/4.0);
  barstep = fract(beat/4.0);

  float bm = mod(bar,4.0);
  
  // Screen uv soordinates from [-1, 1]with fixed aspect
  float aspect = v2Resolution.y / v2Resolution.x;
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  
  
  
  vec2 ouv = uv;
  uv -= 0.5;
	uv /= vec2(aspect, 1);
  
  uv = rot2d( floor(fftI*0.4 ), uv);
  uv *= 1.5+ 0.3 * sin(time*0.25);
  
  screenUv = uv;
  
  vec2 gridSize = vec2( 5.0, 14.0);
  
  float hx = abs(hash(floor(mod(fftI*0.5,500.0))));
  float hy = abs(hash(floor(mod(-fftI*0.4+0.5,500.0))));
  gridSize.x = mix( 4.0, 45.0, hx*hx*hx );
  gridSize.y = mix( 4.0, 45.0, hy*hy*hy );
  
  vec2 grid = vec2( uv.x*gridSize.x*aspect, uv.y*gridSize.y);
  vec2 gridId = floor(grid);
  uv = rot2d( fftI+ length(floor(grid)), uv);
  
  // Raymarch camera & targets
  vec3 cameraPos = vec3( 
    sin( time*0.2 * mix(-1.0, 1.0, sin(gridId.x+gridId.y*0.7+ time*0.0001)) ) * 1.0, 
    1.75,  
    cos( time*0.156 ) * 1.5
  );
  vec3 lookAt = vec3( 0, 0.5, 0);
  float fov = 0.35;
  
  // Lights and additional nonmapped objects.
  vec3 light1 = vec3(
    sin( time ) * 5.0,
    5.0,
    cos( time * 0.35) * 5.0
  );
  
  
  // Actual marching
  
  vec3 rayDir = getcam( cameraPos, lookAt, uv, fov );
  float travel = 0.0;
  vec3 hitPos = cameraPos;
  vec3 marchResult = march( cameraPos, rayDir, hitPos, travel );
  vec3 color = vec3(0.0);
  // Color according to result material (y-channel)
  if( marchResult.y < -0.5){
    // Nothing was hit
  }
  else if( marchResult.y < 0.5){
    // Material 0
  }
  else if( marchResult.y < 1.5){
    // Material 1
    vec3 n = normal( hitPos );
    float d = diffuse( hitPos, n, light1 );
    vec3 c = palette( length( hitPos) + sin(time*0.25), vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20) );
    vec3 c2 = palette( length( hitPos) + sin(time*0.25), vec3(0.5,0.5,0.5),vec3(0.5,0.0,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.0,0.20) );
    vec3 c3 = palette( length( hitPos) + sin(time*0.25), vec3(0.2,0.1,0.6),vec3(0.3,0.5,0.7),vec3(0.7,1.0,0.5),vec3(0.5,0.5,0.10) );
    c = mix(c, c2, abs(sin(fftI)) );
    c = mix(c, c3*0.15, abs(sin(fftI*0.7)) )*0.45;
    
    color = (0.5 + d) * c * textureMapLynn( hitPos, normal( hitPos) );
    
  }
  
  if(bm < 1.0) color.rgb = color.grb;
  else if(bm < 2.0) color.rgb = color.brg;
  else if(bm < 3.0) color.rgb = color.rbg;
  else if(bm < 4.0) color.rgb = color.gbr;
  
  
  vec2 repeatUv = ouv;
  repeatUv -= 0.5;
  repeatUv *= 0.999 -smoothstep( 0.0, 0.05, fftS)*0.02;
  repeatUv += 0.5;
  vec3 prev = texture(texPreviousFrame, repeatUv).rgb;
  color = mix( color, color+prev*0.975, smoothstep(0.0, 0.01, fftS));
	
  vec2 gridoff = grid - 0.5 - gridId;
  color *=1.0- smoothstep(0.47, 0.471,max( abs(gridoff.x), abs(gridoff.y)) );
  
  color *=0.3+ smoothstep( 0.15,  0.75, hash( length(gridId) + floor(fftI*2.0) ));  
  
  color *= smoothstep( 0.0,0.05, fftS)*1.0+0.75;
  out_color = vec4(color, 0.0);
}