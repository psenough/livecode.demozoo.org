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


//vec2 res = vec2(1280,720);
vec2 res = vec2(1920,1080);

// DCI-P3 D65
// matrix.py
  const mat3 xyz_rgb = transpose(mat3(
 0.4866, 0.2657, 0.1982,
 0.2290, 0.6917, 0.0793,
 0.0000, 0.0451, 1.0439
));

  const mat3 rgb_xyz = inverse(xyz_rgb);

  const mat3 xyz_lms = transpose(
  mat3(  1.93986443, -1.34664359,  0.43044935,
         0.69283932,  0.34967567,  0.00000000,
         0.00000000,  0.00000000,  2.14687945 ));
  const mat3 lms_xyz = inverse(xyz_lms);
  
vec3 lms_linss10e_approx (float l_nm) {
  float x = log(l_nm)-6.273;
  vec3 v = vec3(0.);
  v = x*v + vec3(-4.359183e+03,-4.035984e+03, 3.583610e+03);
  v = x*v + vec3( 2.829410e+03, 2.551718e+03, 1.379001e+03);
  v = x*v + vec3( 3.527408e+02, 4.054345e+02,-3.470771e+02);
  v = x*v + vec3(-4.034639e+02,-3.158000e+02, 2.066581e+02);
  v = x*v + vec3(-7.734436e+01,-9.981589e+01,-5.692203e+01);
  v = x*v + vec3( 1.505403e+01, 5.000744e+00,-4.881175e+01);
  v = x*v + vec3(-1.404828e-02,-1.124585e+00,-6.330770e+00);
  v = 1./(1.+exp(-v))/vec3(.635,.258,.252);
  if (l_nm>720.) v.z=0.;
  if (l_nm<320.||l_nm>850.) v=vec3(0.);
  //return mix(v,wavelength_to_lms(l_nm),vec3(0,0,0));
  return v;
}

vec3 rgb_wavelength (float l_nm ) {
  return rgb_xyz*xyz_lms*lms_linss10e_approx(l_nm);
}

vec3 tonemap_spectraldesat4 (vec3 rgbin) {
  //rgbin*=.1;
  //return rgbin;
  // stage 1: handle negative values
  // absolutely no dependence on value, so divide it out
  //const vec3 valw = vec3(.213, .715, .072);
  const vec3 valw = vec3(.213, .715, .102);
  float val = dot(valw,rgbin);
  vec3 rgbcol = rgbin/val;
  {
    bvec3 dsel = greaterThan(rgbcol.rgb,rgbcol.gbr);
    float n=length(rgbcol.xz-1.);
    vec3 v=(rgbcol-1.)/n;
    float bc=0.;
    //float bc = (v.b>.9&&v.g>-.142)?max(0.,v.r)*7.:0.;
    //float bc = (v.b>-.1)?max(0.,v.r)*7.:0.;
    //bc=bc*bc*bc;
    //bc=5.*(v.b-.99) +0.*(v.g+.142) -0.*(v.r-.141);
    vec3 d=vec3((v.b-.99),(v.g+.142),(v.r-.141));
    bc=max(0.,d.r*10.);
    bc*=10.;
    float e=v.r-.141;
    bc=1./(1.+200.*e*e)*max(v.b,0.);
    
    //bc*=bc*100.;
    //bc*=max(d.x*540.,0.);
    //if (iMouse.z<0.)
    //bc=0.;
    //bc
#if 1
    float a=10.+50.*(max(v.r-.1,0.));
    //a=10.;
    //float t=max(v.r,0.1)+.7;
    //return vec3(t*.3,0,0);
    float mv=(-log(dot(exp(-v*a),vec3(1)))/a)*n+1.;
    //float b=10.-5.*v.b*v.b;
    float b=10./(1.+10.*bc);
    //probeval=b*.001;
    //probeval=v.r;
    //probeval=rgbcol.r*.2;
    mv=-log(exp(-mv*b)+exp(-(0.)*b))/b;
#else
    float mv=minv(v)*n+1.;
    mv=min(mv,0.);
#endif
    //if (mvout) mvio=mv;
    //else mv=mvio;
  //  mv=min(mv,0.);
    //probeval=max(v.g+1.,0.*.84);
    //if(v.g>-.2&&v.g<-.142)probeval=.5;
    
    rgbcol-=mv;
    rgbcol/=dot(rgbcol,valw);
    //val=.1;
    rgbin = rgbcol*val;
  }
  return rgbin;
}

vec3 tonemap_saturate (vec3 rgbin) {
  rgbin/=.8;
  const vec3 valw = vec3(.213, .715, .072);
  float val = dot(valw,rgbin);
  vec3 rgbcol = rgbin/val;
  float val2=val+.2;
  vec3 v = rgbin/val2;
  float a=10.;
  float mv;
  mv=(log(dot(exp(v*a),vec3(1)))/a)*val2;
  float b=4.;
  mv=log(exp(mv*b/val2)+exp(b/val2))/b*val2;
  //mv=maxv(v);
  //mv=max(mv,1.);
  //probeval=mv;
  float satval=1.-exp(-val);
  float safeval=val/mv;
//  val/=safeval;
//  val=1.-exp(-val);
//  val*=safeval;
  rgbcol=mix(vec3(1.),rgbcol,1./mv);
  val=satval*.8;
  //val*=mv;
  //float satclip = val-(1.-exp(-val));
  //rgbcol = mix(rgbcol,vec3(1),1.-exp(-satclip));
  //rgbcol/=mv;
  rgbin=rgbcol*val;
  return rgbin;
}

vec3 tonemap (vec3 rgb) {
  //rgb = tonemap_spectraldesat(rgb);
  //mv*=10.;
  rgb = tonemap_spectraldesat4(rgb);
  rgb = tonemap_saturate(rgb);
  return rgb;
}

out vec4 ImgO;

int bufbaserd;
int bufbasewr;

float colpackx=0.;
int colpack(vec3 c) {
  c*=vec3(64,64,32);
  colpackx=fract(colpackx*140.124+.30411);
  c+=colpackx-.5;
  //c+=hash11(colpackx)-.5;
  //colpackx++;
  ivec3 C=ivec3(round(c)); // 7 7 6
  // 11 11 10
  return C.x+0x800*(C.y+0x800*C.z);
}

vec3 colunpack(int d){
  uint u=uint(d+colpack(vec3(16.)));
  uvec3 C=(uvec3(u)>>uvec3(0,11,22))&uvec3(0x7FF,0x7FF,0x3FF);
  return vec3(C)/vec3(64,64,32)-16.;
}

void wrx(vec2 x, vec3 d) {
  x*=.5;
  vec2 k=fract(114.212312*x)-.5;
  //x+=(k-.5)/(.001+dot(k,k));
  //float a=2.*acos(-1.)*k.x;
  //x+=vec2(cos(a),sin(a))/k.y;
  //float l=dot(k,k)*4.;
  //if(l>1.)return;
  x+=k*exp(dot(k,k)*40.);
  x+=res*.5;
  ivec2 X=ivec2(x);
  if(X==clamp(X,ivec2(0),ivec2(res)-1))
    imageAtomicAdd(computeTex[0],X,colpack(d));
  //atomicAdd(BUFINT[bufbasewr+(X.x+X.y*1920)],colpack(d));
  //for (int c=0;c<3;c++)
  //  atomicAdd(BUFINT[bufbasewr+c+3*(X.x+X.y*1920)],int(400000.*d[c]));
}

void main()
{
    
    vec2 FragCoord = gl_FragCoord.xy;
    ivec2 I=ivec2(FragCoord);
    vec2 uv=FragCoord/res;
    float T=mod(fGlobalTime,600.);
    colpackx = .1281*FragCoord.x+.5521*FragCoord.y+T;
  
    vec3 col;
      //float b=.1*T,c=.36*T,a=(b+exp(-b)-1.);
    int M=10;
    for (int dx=0;dx<M;dx++)
    {
      //vec2 x = FragCoord-res*.5;
      //x.y*=sin(T);
      vec2 x=vec2(0);
      x.x=(float(I.x+1920*I.y+float(dx)/M)-1e6)/1e3*3.;
      //col=rgb_wavelength(500.+.1*x.y+100.);
      float lam=500.+mix(.1,.15,fract(T/10.)<.1)*x.x;
      col=rgb_wavelength(lam);
      {float x=(lam-500.)*.01;col*=exp(-x*x);}
      
      int N=60;
      for (int i=0;i<N;i++) {
        float D=fract(T*40);
        //float a=mod(T,;
        float a=0.4*(T*40)*.04;
        float T2=T+fract(T*40);
        vec2 A=vec2(cos(a),sin(a));
        x=mat2(A.x,-A.y,A.y,A.x)*x;
        //x=mat2(A.x,-A.y,A.y,A.x)*.1*sin(x);
        //if(fract(x.x*x.y)>.29)
        if(fract(x.x*x.y)>.5+.5*sin(T/10.))
        x+=(cos((x/1e3*x.yx*.01-x.x*.004+a))*400.)*(1.+.1*sin(.4*T2))+1.+40*D;
        x*=.9;
        /*
        if(fract(x.x*x.y)>.29)
        x+=(cos((x/1e3*x.yx*.01-x.x*.004+a))*400.)*(1.-exp(-.01*T*T))*(1.+.1*sin(.4*T))+10.;
        x*=.94;
        */
        
        //x+=sin(x*fract(T*0.));
        wrx(x*1.2,col*exp(-float(i)/50.)/N/M);
      }
      //wrx(x,1.);
      //x*=6.;
      //x+=res*.5;
      //ivec2 X=clamp(ivec2(x),ivec2(0),ivec2(1920,1080));
      //atomicAdd(BUFINT[bufbasewr+X.x+X.y*1920],100000);
    }

    //for (int c=0;c<3;c++)
    //  ImgO[c]=atomicExchange(BUFINT[bufbaserd+c+3*(I.x+I.y*1920)],0)/1e6;
    //vec3 ImgO=colunpack(atomicExchange(BUFINT[bufbaserd+(I.x+I.y*1920)],0));
    vec3 ImgO=vec3(0);
    {
      int N=1;for(int dy=-N;dy<=N;dy++)for(int dx=-N;dx<=N;dx++)
        ImgO+=colunpack(int(imageLoad(computeTexBack[0],I+ivec2(dx,dy)).x))/(N*2+1)/(N*2+1)*5;
    }
    ImgO+=.001;
    ImgO.rgb=tonemap(ImgO.rgb);
    out_color.rgb=pow(ImgO,vec3(1/2.2));
    //#define c ImgO
    //ImgO=min(12.9*c,abs(1.054*pow(c,c-c+.4166)-.095)+.04);
    //if(FragCoord.x<100.)ImgO.xyz=vec3(UFRAME%2);
}
