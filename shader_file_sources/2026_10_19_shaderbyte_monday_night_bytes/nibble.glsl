#version 420 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

/*vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
}
*/

// colors
#define bg_color vec4(0.0, 0.0, 0.0, 1.0)
#define line_color vec4(1.0, 1.0, 1.0, 1.0) // [ for the moment ]

// space
#define num_lines    16
#define num_cells    16
//#define grid_spacing 0.01
#define grid_spacing 0.1
#define line_width   0.0005

float dist_point_seg(float x, float y, vec4 seg)
{
  vec2 p0 = vec2(seg.x, seg.y);
  vec2 p1 = vec2(seg.z, seg.w);
  
  // point-point dist
  float d2_0 = (x - p0.x)*(x - p0.x) + (y - p0.y)*(y - p0.y);
  float d2_1 = (x - p1.x)*(x - p1.x) + (y - p1.y)*(y - p1.y);
  
  // seg len
  float seg_len2 = (p1.x - p0.x)*(p1.x - p0.x) + (p1.y - p0.y)*(p1.y - p0.y);
  
  // t
  float t = -(d2_1 - d2_0 - seg_len2)/(2.0*seg_len2);
  
  // dist
  float dist = sqrt(-(t*t*seg_len2 - d2_0));
  
  return dist;
}

// fx
float dist_point_seg_displace(float x, float y, float off, vec4 seg)
{
  vec2 p0 = vec2(seg.x, seg.y + off);
  vec2 p1 = vec2(seg.z, seg.w + off);
  
  // point-point dist
  float d2_0 = (x - p0.x)*(x - p0.x) + (y - p0.y)*(y - p0.y);
  float d2_1 = (x - p1.x)*(x - p1.x) + (y - p1.y)*(y - p1.y);
  
  // seg len
  float seg_len2 = (p1.x - p0.x)*(p1.x - p0.x) + (p1.y - p0.y)*(p1.y - p0.y);
  
  // t
  float t = -(d2_1 - d2_0 - seg_len2)/(2.0*seg_len2);
  
  // dist
  float dist = sqrt(-(t*t*seg_len2 - d2_0));
  
  return dist;
}

// grid
vec4 get_grid_seg(int i, int j)
{
  vec2 p0;
  vec2 p1;
  
  p0.x = float(i)/num_cells;
  p0.y = j*grid_spacing;
  
  p1.x = float(i)/num_cells;
  //p1.x = float(i)/num_cells + 0.0001; // dither
  p1.x = float(i)/num_cells + 0.01;
  p1.y = j*grid_spacing;
  
  vec4 seg = vec4(p0.x, p0.y, p1.x, p1.y);
  
  return seg;
}

vec4 get_color(vec2 uv)
{
  vec4 col = bg_color;
  float min_dist = 1.0;
  int j;
  
  for (int j = 0; j < num_lines; j++)
    for (int i = 0; i < num_cells; i++)
    {
      vec4 seg = get_grid_seg(i, j);
      vec2 seg0 = vec2(seg.x, seg.y);
      vec2 seg1 = vec2(seg.z, seg.w);
    
      // point
      float x = uv.x;
      float y = uv.y;
      
      //float d = dist_point_seg(x, y, seg);
    
      // fft
      float ff = texture(texFFTSmoothed, i*0.001).r;
      float d = dist_point_seg_displace(x, y, ff, seg);
    
      if (d < min_dist)
        min_dist = d;
    }
  
  if (min_dist <= line_width)
    col = line_color; // [ for the moment ]
  
  return col;
}

void main(void)
{
  // setup uvs
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  //uv -= vec2(0.25, 0.0);
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  uv *= vec2(10.0, 0.25);
  
  // out color
  out_color = get_color(uv);
}
