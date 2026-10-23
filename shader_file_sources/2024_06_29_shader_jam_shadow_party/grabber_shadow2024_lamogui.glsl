#version 410 core

#define DOWN_SCALE 6.0

#define MAX_INT_DIGITS 4

#define CHAR_SIZE vec2(8, 12)
#define CHAR_SPACING vec2(8, 12)

#define STRWIDTH(c) (c * CHAR_SPACING.x)
#define STRHEIGHT(c) (c * CHAR_SPACING.y)

#define NORMAL 0
#define INVERT 1
#define UNDERLINE 2

int TEXT_MODE = NORMAL;

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

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec4 ch_spc = vec4(0x000000,0x000000,0x000000,0x000000);
vec4 ch_exc = vec4(0x003078,0x787830,0x300030,0x300000);
vec4 ch_quo = vec4(0x006666,0x662400,0x000000,0x000000);
vec4 ch_hsh = vec4(0x006C6C,0xFE6C6C,0x6CFE6C,0x6C0000);
vec4 ch_dol = vec4(0x30307C,0xC0C078,0x0C0CF8,0x303000);
vec4 ch_pct = vec4(0x000000,0xC4CC18,0x3060CC,0x8C0000);
vec4 ch_amp = vec4(0x0070D8,0xD870FA,0xDECCDC,0x760000);
vec4 ch_apo = vec4(0x003030,0x306000,0x000000,0x000000);
vec4 ch_lbr = vec4(0x000C18,0x306060,0x603018,0x0C0000);
vec4 ch_rbr = vec4(0x006030,0x180C0C,0x0C1830,0x600000);
vec4 ch_ast = vec4(0x000000,0x663CFF,0x3C6600,0x000000);
vec4 ch_crs = vec4(0x000000,0x18187E,0x181800,0x000000);
vec4 ch_com = vec4(0x000000,0x000000,0x000038,0x386000);
vec4 ch_dsh = vec4(0x000000,0x0000FE,0x000000,0x000000);
vec4 ch_per = vec4(0x000000,0x000000,0x000038,0x380000);
vec4 ch_lsl = vec4(0x000002,0x060C18,0x3060C0,0x800000);
vec4 ch_0 = vec4(0x007CC6,0xD6D6D6,0xD6D6C6,0x7C0000);
vec4 ch_1 = vec4(0x001030,0xF03030,0x303030,0xFC0000);
vec4 ch_2 = vec4(0x0078CC,0xCC0C18,0x3060CC,0xFC0000);
vec4 ch_3 = vec4(0x0078CC,0x0C0C38,0x0C0CCC,0x780000);
vec4 ch_4 = vec4(0x000C1C,0x3C6CCC,0xFE0C0C,0x1E0000);
vec4 ch_5 = vec4(0x00FCC0,0xC0C0F8,0x0C0CCC,0x780000);
vec4 ch_6 = vec4(0x003860,0xC0C0F8,0xCCCCCC,0x780000);
vec4 ch_7 = vec4(0x00FEC6,0xC6060C,0x183030,0x300000);
vec4 ch_8 = vec4(0x0078CC,0xCCEC78,0xDCCCCC,0x780000);
vec4 ch_9 = vec4(0x0078CC,0xCCCC7C,0x181830,0x700000);
vec4 ch_col = vec4(0x000000,0x383800,0x003838,0x000000);
vec4 ch_scl = vec4(0x000000,0x383800,0x003838,0x183000);
vec4 ch_les = vec4(0x000C18,0x3060C0,0x603018,0x0C0000);
vec4 ch_equ = vec4(0x000000,0x007E00,0x7E0000,0x000000);
vec4 ch_grt = vec4(0x006030,0x180C06,0x0C1830,0x600000);
vec4 ch_que = vec4(0x0078CC,0x0C1830,0x300030,0x300000);
vec4 ch_ats = vec4(0x007CC6,0xC6DEDE,0xDEC0C0,0x7C0000);
vec4 ch_A = vec4(0x003078,0xCCCCCC,0xFCCCCC,0xCC0000);
vec4 ch_B = vec4(0x00FC66,0x66667C,0x666666,0xFC0000);
vec4 ch_C = vec4(0x003C66,0xC6C0C0,0xC0C666,0x3C0000);
vec4 ch_D = vec4(0x00F86C,0x666666,0x66666C,0xF80000);
vec4 ch_E = vec4(0x00FE62,0x60647C,0x646062,0xFE0000);
vec4 ch_F = vec4(0x00FE66,0x62647C,0x646060,0xF00000);
vec4 ch_G = vec4(0x003C66,0xC6C0C0,0xCEC666,0x3E0000);
vec4 ch_H = vec4(0x00CCCC,0xCCCCFC,0xCCCCCC,0xCC0000);
vec4 ch_I = vec4(0x007830,0x303030,0x303030,0x780000);
vec4 ch_J = vec4(0x001E0C,0x0C0C0C,0xCCCCCC,0x780000);
vec4 ch_K = vec4(0x00E666,0x6C6C78,0x6C6C66,0xE60000);
vec4 ch_L = vec4(0x00F060,0x606060,0x626666,0xFE0000);
vec4 ch_M = vec4(0x00C6EE,0xFEFED6,0xC6C6C6,0xC60000);
vec4 ch_N = vec4(0x00C6C6,0xE6F6FE,0xDECEC6,0xC60000);
vec4 ch_O = vec4(0x00386C,0xC6C6C6,0xC6C66C,0x380000);
vec4 ch_P = vec4(0x00FC66,0x66667C,0x606060,0xF00000);
vec4 ch_Q = vec4(0x00386C,0xC6C6C6,0xCEDE7C,0x0C1E00);
vec4 ch_R = vec4(0x00FC66,0x66667C,0x6C6666,0xE60000);
vec4 ch_S = vec4(0x0078CC,0xCCC070,0x18CCCC,0x780000);
vec4 ch_T = vec4(0x00FCB4,0x303030,0x303030,0x780000);
vec4 ch_U = vec4(0x00CCCC,0xCCCCCC,0xCCCCCC,0x780000);
vec4 ch_V = vec4(0x00CCCC,0xCCCCCC,0xCCCC78,0x300000);
vec4 ch_W = vec4(0x00C6C6,0xC6C6D6,0xD66C6C,0x6C0000);
vec4 ch_X = vec4(0x00CCCC,0xCC7830,0x78CCCC,0xCC0000);
vec4 ch_Y = vec4(0x00CCCC,0xCCCC78,0x303030,0x780000);
vec4 ch_Z = vec4(0x00FECE,0x981830,0x6062C6,0xFE0000);
vec4 ch_lsb = vec4(0x003C30,0x303030,0x303030,0x3C0000);
vec4 ch_rsl = vec4(0x000080,0xC06030,0x180C06,0x020000);
vec4 ch_rsb = vec4(0x003C0C,0x0C0C0C,0x0C0C0C,0x3C0000);
vec4 ch_pow = vec4(0x10386C,0xC60000,0x000000,0x000000);
vec4 ch_usc = vec4(0x000000,0x000000,0x000000,0x00FF00);
vec4 ch_a = vec4(0x000000,0x00780C,0x7CCCCC,0x760000);
vec4 ch_b = vec4(0x00E060,0x607C66,0x666666,0xDC0000);
vec4 ch_c = vec4(0x000000,0x0078CC,0xC0C0CC,0x780000);
vec4 ch_d = vec4(0x001C0C,0x0C7CCC,0xCCCCCC,0x760000);
vec4 ch_e = vec4(0x000000,0x0078CC,0xFCC0CC,0x780000);
vec4 ch_f = vec4(0x00386C,0x6060F8,0x606060,0xF00000);
vec4 ch_g = vec4(0x000000,0x0076CC,0xCCCC7C,0x0CCC78);
vec4 ch_h = vec4(0x00E060,0x606C76,0x666666,0xE60000);
vec4 ch_i = vec4(0x001818,0x007818,0x181818,0x7E0000);
vec4 ch_j = vec4(0x000C0C,0x003C0C,0x0C0C0C,0xCCCC78);
vec4 ch_k = vec4(0x00E060,0x60666C,0x786C66,0xE60000);
vec4 ch_l = vec4(0x007818,0x181818,0x181818,0x7E0000);
vec4 ch_m = vec4(0x000000,0x00FCD6,0xD6D6D6,0xC60000);
vec4 ch_n = vec4(0x000000,0x00F8CC,0xCCCCCC,0xCC0000);
vec4 ch_o = vec4(0x000000,0x0078CC,0xCCCCCC,0x780000);
vec4 ch_p = vec4(0x000000,0x00DC66,0x666666,0x7C60F0);
vec4 ch_q = vec4(0x000000,0x0076CC,0xCCCCCC,0x7C0C1E);
vec4 ch_r = vec4(0x000000,0x00EC6E,0x766060,0xF00000);
vec4 ch_s = vec4(0x000000,0x0078CC,0x6018CC,0x780000);
vec4 ch_t = vec4(0x000020,0x60FC60,0x60606C,0x380000);
vec4 ch_u = vec4(0x000000,0x00CCCC,0xCCCCCC,0x760000);
vec4 ch_v = vec4(0x000000,0x00CCCC,0xCCCC78,0x300000);
vec4 ch_w = vec4(0x000000,0x00C6C6,0xD6D66C,0x6C0000);
vec4 ch_x = vec4(0x000000,0x00C66C,0x38386C,0xC60000);
vec4 ch_y = vec4(0x000000,0x006666,0x66663C,0x0C18F0);
vec4 ch_z = vec4(0x000000,0x00FC8C,0x1860C4,0xFC0000);
vec4 ch_lpa = vec4(0x001C30,0x3060C0,0x603030,0x1C0000);
vec4 ch_bar = vec4(0x001818,0x181800,0x181818,0x180000);
vec4 ch_rpa = vec4(0x00E030,0x30180C,0x183030,0xE00000);
vec4 ch_tid = vec4(0x0073DA,0xCE0000,0x000000,0x000000);
vec4 ch_lar = vec4(0x000000,0x10386C,0xC6C6FE,0x000000);

vec2 res = vec2(0);
vec2 print_pos = vec2(0);

//Extracts bit b from the given number.
//Shifts bits right (num / 2^bit) then ANDs the result with 1 (mod(result,2.0)).
float extract_bit(float n, float b)
{
    b = clamp(b,-1.0,24.0);
	return floor(mod(floor(n / pow(2.0,floor(b))),2.0));   
}

//Returns the pixel at uv in the given bit-packed sprite.
float sprite(vec4 spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    
    //Calculate the bit to extract (x + y * width) (flipped on x-axis)
    float bit = (size.x-uv.x-1.0) + uv.y * size.x;
    
    //Clipping bound to remove garbage outside the sprite's boundaries.
    bool bounds = all(greaterThanEqual(uv,vec2(0))) && all(lessThan(uv,size));
    
    float pixels = 0.0;
    pixels += extract_bit(spr.x, bit - 72.0);
    pixels += extract_bit(spr.y, bit - 48.0);
    pixels += extract_bit(spr.z, bit - 24.0);
    pixels += extract_bit(spr.w, bit - 00.0);
    
    return bounds ? pixels : 0.0;
}

//Prints a character and moves the print position forward by 1 character width.
float print_char(vec4 ch, vec2 uv)
{
    if( TEXT_MODE == INVERT )
    {
      //Inverts all of the bits in the character.
      ch = pow(2.0,24.0)-1.0-ch;
    }
    if( TEXT_MODE == UNDERLINE )
    {
      //Makes the bottom 8 bits all 1.
      //Shifts the bottom chunk right 8 bits to drop the lowest 8 bits,
      //then shifts it left 8 bits and adds 255 (binary 11111111).
      ch.w = floor(ch.w/256.0)*256.0 + 255.0;  
    }

    float px = sprite(ch, CHAR_SIZE, uv - print_pos);
    print_pos.x += CHAR_SPACING.x;
    //print_pos.y += 10.0*cos( print_pos.x + 10.0*fGlobalTime);
    return px;
}


//Returns the digit sprite for the given number.
vec4 get_digit(float d)
{
    d = floor(d);
    
    if(d == 0.0) return ch_0;
    if(d == 1.0) return ch_1;
    if(d == 2.0) return ch_2;
    if(d == 3.0) return ch_3;
    if(d == 4.0) return ch_4;
    if(d == 5.0) return ch_5;
    if(d == 6.0) return ch_6;
    if(d == 7.0) return ch_7;
    if(d == 8.0) return ch_8;
    if(d == 9.0) return ch_9;
    return vec4(0.0);
}

mat2 rot( float a ) {
    float c = cos( a );
    float s = sin( a );
    return mat2( c, s, -s, c);
}  

float map( vec3 g ) {
   vec3 p = g;
    p.xy *= rot( p.z * 0.6 );
    float d = cos( p.x) + cos(p.y) + cos(p.z);
    d = min( d, p.x + 0.2 + texture( texNoise, p.yz*0.05 + fGlobalTime*0.1 ).r);
  return d;
}
vec3 grad( vec3 p ) {
    vec2 e = vec2( 0.01, 0.0 );
    float d = map( p );
    return normalize( vec3( d - map( p + e.xyy ), 
                            d - map( p + e.yxy ), 
                            d - map( p + e.yyx ) )
          );
}

float text(vec2 uv)
{
    float col = 0.0;
    
    vec2 center = res/2.0;
    
    //Greeting Text
    
    print_pos = floor(center - vec2(STRWIDTH(1.0),STRHEIGHT(1.0))/2.0) + vec2(-(1500.*(0.1*fGlobalTime - floor(0.1*fGlobalTime))) + 1500.*0.5 , 15.0*cos(fGlobalTime+0.02*uv.x));
       
    col += print_char(ch_H,uv);
    col += print_char(ch_a,uv);
    col += print_char(ch_l,uv);
    col += print_char(ch_l,uv);
    col += print_char(ch_o,uv);
    
    col += print_char(ch_spc,uv);
    
    col += print_char(ch_S,uv);
    col += print_char(ch_h,uv);
    col += print_char(ch_a,uv);
    col += print_char(ch_d,uv);
    col += print_char(ch_o,uv);
    col += print_char(ch_w,uv);
    col += print_char(ch_exc,uv);
    
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    
    col += print_char(ch_W,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_S,uv);
    col += print_char(ch_que,uv);
    col += print_char(ch_que,uv);
    col += print_char(ch_que,uv);
    col += print_char(ch_que,uv);
    
        col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    
    col += print_char(ch_A,uv);
    col += print_char(ch_L,uv);
    col += print_char(ch_K,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_M,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_exc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_L,uv);
    col += print_char(ch_K,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_M,uv);
    col += print_char(ch_A,uv);
   col += print_char(ch_exc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_L,uv);
    col += print_char(ch_K,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_M,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_exc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_L,uv);
    col += print_char(ch_K,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_M,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_exc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_spc,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_L,uv);
    col += print_char(ch_K,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_M,uv);
    col += print_char(ch_A,uv);
    col += print_char(ch_exc,uv);
    
    
  
    return col;
}



vec3 rm( vec3 ro, vec3 rd ) {
    vec3 p = ro;
    for ( float st = 0.0; st < 100.0; ++st ) {
        float d = map( p ) ;
         if ( abs( d) < 0.01 ) {
            break;
         }
         p+=rd * d;
    }
    return p;
}

vec3 color( vec2 uv ) {
    vec3 ro = vec3( 0.0, 0.0, fGlobalTime + texture( texFFTIntegrated, 0.05) * 5.0 );
  vec3 rd = normalize( vec3( uv, 0.7 ) );
  
  vec3 p = rm( ro, rd );
  
  vec3 n = grad( p );
  return  n *0.5 + 0.5;
}

void main(void)
{
  
  res = v2Resolution.xy / DOWN_SCALE;
	vec2 duv = floor(gl_FragCoord.xy / DOWN_SCALE);
  
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec2 puv = uv;
  //uv += 0.1 * texture( texTex4, uv + sin( cos( fGlobalTime + texture( texNoise, uv ).r ) ) ) .rg ;
  
  vec3 c = color( uv );
  for ( float s = 0.; s < 7.0; ++s ) {
     vec2 off = vec2( cos( s * 2.39), sin( 2.39 ) ) * 0.2*texture( texNoise, puv).r;
    c += color( uv + off );
  }
  
  float t = text(duv );
  c = mix( c / 8.0, vec3( 1.0), t );

	out_color = vec4(c  , 1.0);
}