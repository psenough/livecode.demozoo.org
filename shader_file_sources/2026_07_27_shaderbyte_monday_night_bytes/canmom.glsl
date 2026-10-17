#version 460 core

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

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

//hey let's make swizzle
//soon to be seen in the skies over köln!

float sdTriangle( in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2 )
{
    vec2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
    vec2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
    vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
    vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
    vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign( e0.x*e2.y - e0.y*e2.x );
    vec2 d = min(min(vec2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                     vec2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
                     vec2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
    return -sqrt(d.x)*sign(d.y);
}

float edge(in vec2 p, in vec2 p0, in vec2 p1) {
  return (p.x - p0.x) * (p1.y - p0.y) - (p.y - p0.y) * (p1.x - p0.x);
}

struct Triangle {
  vec2[3] positions;
  vec3[3] colours;
  float[3] back_left_weight;
  float[3] back_right_weight;
  float[3] front_left_weight;
  float[3] front_right_weight;
  float[3] head_weight;
  float[3] tail_weight;
};

const int TRI_COUNT = 11;

const Triangle tris[TRI_COUNT] = Triangle[](
  //tail
  Triangle(
    vec2[3](
      vec2(-2.785, 1.043),
      vec2(-4.092, 0.780),
      vec2(-4.381, 0.022)
    ),
    vec3[3](
      vec3(0.510, 0.265, 0.768),
      vec3(0.408, 0.160, 0.757),
      vec3(0.437, 0.039, 0.757)
    ),
    float[3](0.488, 0.0, 0.0),
    float[3](0.488, 0.0, 0.0),
    float[3](0.012, 0.0, 0.0),
    float[3](0.012, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 1.0, 1.0)
  ),
    //back leg back left
  Triangle(
    vec2[3](
      vec2(-2.715, 1.124),
      vec2(-1.613, 1.852),
      vec2(-1.996, 0.026)
    ),
    vec3[3](
      vec3(0.255, 0.132, 0.384),
      vec3(0.255, 0.132, 0.384),
      vec3(0.198, 0.033, 0.108)
    ),
    float[3](0.488, 0.488, 0.977),
    float[3](0.488, 0.488, 0.0),
    float[3](0.012, 0.012, 0.23),
    float[3](0.012, 0.012, 0.0),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0)
  ),
      //back leg front left
  Triangle(
    vec2[3](
      vec2(-1.898, 0.280),
      vec2(-1.575, 1.863),
      vec2(-0.838, 1.459)
    ),
    vec3[3](
      vec3(0.315, 0.145, 0.208),
      vec3(0.187, 0.155, 0.453),
      vec3(0.255, 0.132, 0.384)
    ),
    float[3](0.910, 0.487, 0.165),
    float[3](0.067, 0.487, 0.165),
    float[3](0.022, 0.013, 0.335),
    float[3](0.002, 0.013, 0.335),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0)
  ),


  //front leg left
  Triangle(
    vec2[3](
      vec2(-1.267, 0.906),
      vec2(-0.002, 0.003),
      vec2(-0.819, 1.409)
    ),
    vec3[3](
      vec3(0.172, 0.092, 0.255),
      vec3(0.185, 0.031, 0.100),
      vec3(0.086, 0.075, 0.379)
    ),
    float[3](0.531, 0.002, 0.170),
    float[3](0.142, 0.000, 0.170),
    float[3](0.189, 0.998, 0.330),
    float[3](0.138, 0.000, 0.330),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0)
  ),
  //back leg back right
  Triangle(
    vec2[3](
      vec2(-2.715, 1.124),
      vec2(-1.613, 1.852),
      vec2(-1.996, 0.026)
    ),
    vec3[3](
      vec3(0.510, 0.265, 0.768),
      vec3(0.510, 0.265, 0.768),
      vec3(0.396, 0.067, 0.214)
    ),
    float[3](0.488, 0.488, 0.0),
    float[3](0.488, 0.488, 0.977),
    float[3](0.012, 0.012, 0.0),
    float[3](0.012, 0.012, 0.23),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0)
  ),

  //back leg front right
  Triangle(
    vec2[3](
      vec2(-1.898, 0.280),
      vec2(-1.575, 1.863),
      vec2(-0.838, 1.459)
    ),
    vec3[3](
      vec3(0.629, 0.290, 0.415),
      vec3(0.373, 0.310, 0.906),
      vec3(0.510, 0.265, 0.768)
    ),
    float[3](0.070, 0.487, 0.165),
    float[3](0.906, 0.487, 0.165),
    float[3](0.002, 0.013, 0.335),
    float[3](0.022, 0.013, 0.335),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0)
  ),

  //front leg right
  Triangle(
    vec2[3](
      vec2(-1.267, 0.906),
      vec2(-0.002, 0.003),
      vec2(-0.819, 1.409)
    ),
    vec3[3](
      vec3(0.510, 0.265, 0.768),
      vec3(0.396, 0.067, 0.214),
      vec3(0.510, 0.265, 0.768)
    ),
    float[3](0.142, 0.000, 0.170),
    float[3](0.531, 0.002, 0.170),
    float[3](0.138, 0.000, 0.330),
    float[3](0.189, 0.998, 0.330),
    float[3](0.0, 0.0, 0.0),
    float[3](0.0, 0.0, 0.0)
  ),
  //neck 1
  Triangle(
    vec2[3](
      vec2(-0.319, 0.663),
      vec2(-0.781, 1.425),
      vec2(0.393, 1.306)
    ),
    vec3[3](
      vec3(0.396, 0.067, 0.214),
      vec3(0.272, 0.439, 0.633),
      vec3(0.566, 0.149, 0.476)
    ),
    float[3](0.076, 0.174, 0.0),
    float[3](0.076, 0.174, 0.0),
    float[3](0.145, 0.326, 0.0),
    float[3](0.705, 0.326, 0.0),
    float[3](0.0, 0.0, 1.0),
    float[3](0.0, 0.0, 0.0)
  ),
  //neck 2
  Triangle(
    vec2[3](
      vec2(-0.781, 1.425),
      vec2(0.393, 1.306),
      vec2(0.465, 1.631)
    ),
    vec3[3](
      vec3(0.272, 0.439, 0.633),
      vec3(0.566, 0.149, 0.476),
      vec3(0.567, 0.223, 0.584)
    ),
    float[3](0.174, 0.0, 0.0),
    float[3](0.174, 0.0, 0.0),
    float[3](0.326, 0.0, 0.0),
    float[3](0.326, 0.0, 0.0),
    float[3](0.0, 1.0, 1.0),
    float[3](0.0, 0.0, 0.0)
  ),
  //head
  Triangle(
    vec2[3](
      vec2(0.502, 1.915),
      vec2(1.574, 1.343),
      vec2(0.323, 1.148)
    ),
    vec3[3](
      vec3(0.209, 0.636, 0.323),
      vec3(0.009, 0.723, 1.000),
      vec3(0.137, 0.636, 0.445)
    ),
    float[3](0.0,0.0,0.0),
    float[3](0.0,0.0,0.0),
    float[3](0.0,0.0,0.0),
    float[3](0.0,0.0,0.0),
    float[3](1.0,1.0,1.0),
    float[3](0.0,0.0,0.0)
  ),
  //ear
  Triangle(
    vec2[3](
      vec2(0.160, 1.868),
      vec2(0.447, 1.924),
      vec2(0.387, 1.661)
    ),
    vec3[3](
      vec3(0.209, 0.636, 0.323),
      vec3(0.009, 0.723, 1.000),
      vec3(0.137, 0.636, 0.445)
    ),
    float[3](0.0,0.0,0.0),
    float[3](0.0,0.0,0.0),
    float[3](0.0,0.0,0.0),
    float[3](0.0,0.0,0.0),
    float[3](1.0,1.0,1.0),
    float[3](0.0,0.0,0.0)
  )
);

// http://www.jcgt.org/published/0009/03/02/
vec3 hash(uvec3 v) {

    v = v * 1664525u + 1013904223u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return vec3(v) * (1.0/float(0xffffffffu));
}

uvec3 uhash(uvec3 v) {
  v = v * 1664525u + 1013904223u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return v;
}

//borrowing noise with derivatives from Inigo Quilez
//https://www.shadertoy.com/view/4dffRH
//thanks Inigo we would be nowhere without you <3
vec4 noised( in vec3 x )
{
  // grid
  uvec3 i = uvec3(floor(x));

  vec3 f = fract(x);

  // quintic interpolant
  vec3 u = f*f*f*(f*(f*6.0-15.0)+10.0);
  vec3 du = 30.0*f*f*(f*(f-2.0)+1.0);

  // gradients
  vec3 ga = hash( i+ivec3(0,0,0) );
  vec3 gb = hash( i+ivec3(1,0,0) );
  vec3 gc = hash( i+ivec3(0,1,0) );
  vec3 gd = hash( i+ivec3(1,1,0) );
  vec3 ge = hash( i+ivec3(0,0,1) );
  vec3 gf = hash( i+ivec3(1,0,1) );
  vec3 gg = hash( i+ivec3(0,1,1) );
  vec3 gh = hash( i+ivec3(1,1,1) );

  // projections
  float va = dot( ga, f-vec3(0.0,0.0,0.0) );
  float vb = dot( gb, f-vec3(1.0,0.0,0.0) );
  float vc = dot( gc, f-vec3(0.0,1.0,0.0) );
  float vd = dot( gd, f-vec3(1.0,1.0,0.0) );
  float ve = dot( ge, f-vec3(0.0,0.0,1.0) );
  float vf = dot( gf, f-vec3(1.0,0.0,1.0) );
  float vg = dot( gg, f-vec3(0.0,1.0,1.0) );
  float vh = dot( gh, f-vec3(1.0,1.0,1.0) );

  // interpolations
  float k0 = va-vb-vc+vd;
  vec3  g0 = ga-gb-gc+gd;
  float k1 = va-vc-ve+vg;
  vec3  g1 = ga-gc-ge+gg;
  float k2 = va-vb-ve+vf;
  vec3  g2 = ga-gb-ge+gf;
  float k3 = -va+vb+vc-vd+ve-vf-vg+vh;
  vec3  g3 = -ga+gb+gc-gd+ge-gf-gg+gh;
  float k4 = vb-va;
  vec3  g4 = gb-ga;
  float k5 = vc-va;
  vec3  g5 = gc-ga;
  float k6 = ve-va;
  vec3  g6 = ge-ga;

  return vec4( va + k4*u.x + k5*u.y + k6*u.z + k0*u.x*u.y + k1*u.y*u.z + k2*u.z*u.x + k3*u.x*u.y*u.z,    // value
               ga + g4*u.x + g5*u.y + g6*u.z + g0*u.x*u.y + g1*u.y*u.z + g2*u.z*u.x + g3*u.x*u.y*u.z +   // derivatives
               du * (vec3(k4,k5,k6) +
                     vec3(k0,k1,k2)*u.yzx +
                     vec3(k2,k0,k1)*u.zxy +
                     k3*u.yzx*u.zxy ));
}

vec3 hue_shift(vec3 color, float hue) {
    const vec3 k = vec3(0.57735, 0.57735, 0.57735);
    float cosAngle = cos(hue);
    return vec3(color * cosAngle + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - cosAngle));
}

void main(void)
{
  vec2 uv = (gl_FragCoord.xy /v2Resolution)/vec2(v2Resolution.y/v2Resolution.x,1.)*2.0;

  vec3 noise_1 = noised(vec3(20.0*uv+vec2(100.0), fGlobalTime)).yzw;
  vec3 noise_2 = noised(vec3(20.0*uv, fGlobalTime)).yzw;
  vec3 noise_curl = cross(noise_1, noise_2);


  float angle = -3.0*texture(texFFTIntegrated, 0.9).r;
  float c = cos(angle);
  float s = sin(angle);

  float scale_osc = (1.0+0.5*sin(texture(texFFTIntegrated,0.05).r));

  vec2 scale = vec2(0.1,0.3) * scale_osc;

  uv = mat2(c, s, -s, c) * uv;

  uv += vec2(c,s)*texture(texFFTIntegrated, 0.8).r * 0.05 /scale_osc;

  uv = fract(uv*scale*10.0);

  uv += (noise_curl.yz * texture(texFFTSmoothed,0.2).r + noise_curl.xy * texture(texFFTSmoothed,0.1).r);

  vec3 colour = vec3(0.0);

  vec2 offset = vec2(0.65,0.0);

  float back_leg_time = 10.0*texture(texFFTIntegrated, 0.3).r;
  float front_leg_time = 10.0*texture(texFFTIntegrated, 0.5).r;

  float tail_offset = texture(texFFTSmoothed, 0.1).r*4.0;
  float back_left_offset = max(texture(texFFTSmoothed, 0.3).r*5.0*cos(back_leg_time),0.0);
  float back_right_offset = max(-texture(texFFTSmoothed, 0.3).r*5.0*cos(back_leg_time), 0.0);
  float front_left_offset = max(texture(texFFTSmoothed, 0.5).r*20.0*cos(front_leg_time),0.0);
  float front_right_offset = max(-texture(texFFTSmoothed, 0.5).r*10.0*cos(front_leg_time),0.0);
  float head_offset = texture(texFFTSmoothed, 0.7).r*10.0;

  float front_fb = 0.07*sin(front_leg_time);
  float back_fb = 0.07*sin(back_leg_time);

  for (int i = 0; i < TRI_COUNT; i++) {
    vec2[3] pos = vec2[3](
      tris[i].positions[0]*scale+offset,
      tris[i].positions[1]*scale+offset,
      tris[i].positions[2]*scale+offset
    );

    for (int j = 0; j<3; j++) {
      pos[j] += tris[i].back_left_weight[j] * vec2(back_fb, back_left_offset)
              + tris[i].front_left_weight[j] * vec2(front_fb, front_left_offset)
              + tris[i].back_right_weight[j] * vec2(-back_fb, back_right_offset)
              + tris[i].front_right_weight[j] * vec2(-front_fb, front_right_offset)
              + tris[i].head_weight[j] * vec2(0.0, head_offset)
              + tris[i].tail_weight[j] * vec2(0.0, tail_offset);
    }

    float[3] e = float[3](
      edge(uv, pos[1], pos[2])/edge(pos[0], pos[1], pos[2]),
      edge(uv, pos[2], pos[0])/edge(pos[1], pos[2], pos[0]),
      edge(uv, pos[0], pos[1])/edge(pos[2], pos[0], pos[1])
    );

    if (e[0] > 0 && e[1] > 0 && e[2] > 0) {
      //calculate barycentric coordinates
      colour = e[0] * tris[i].colours[0]
             + e[1] * tris[i].colours[1]
             + e[2] * tris[i].colours[2];
    }
  }

  colour = hue_shift(colour, texture(texFFTIntegrated,0.05).r);

  vec2 tunnel = 0.5+0.3*vec2(s,-c);

	out_color = vec4(colour,1.0) + texture(texPreviousFrame, 1.015*(gl_FragCoord.xy/v2Resolution-tunnel)+tunnel)*0.4;
  //out_color = vec4(noise_curl, 1.0);
}
