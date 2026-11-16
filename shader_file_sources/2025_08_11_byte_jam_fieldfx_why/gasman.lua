-- hello from gasman!!!!
-- greetings to everyone at WHY :-)

sin=math.sin
cos=math.cos
pi=math.pi

vertices={}

for i=0,200 do
 a=(i%20)/20.0
 b=(i//20)/10.0
 x0=sin(a*pi*2)
 y0=cos(a*pi*2)
 vertices[i]={
  x0*cos(b*pi),
  y0,
  x0*sin(b*pi),
 }
end


function TIC()

 hue=time()/1357
 for i=0,8 do
  poke(16320+i*3,i*24*(0.5+0.5*sin(hue)))
  poke(16321+i*3,i*24*(0.5+0.5*sin(hue+1)))
  poke(16322+i*3,i*24*(0.5+0.5*sin(hue+2)))
 end

 cls()
 a=time()/1234
 scl=10+5*sin(time()/545)
 xoroff=time()//180
 for y=0,135 do
  for x=0,239 do
   x0=x-120
   y0=y-68
   tx=(x0*cos(a)+y0*sin(a))/scl
   ty=(y0*cos(a)-x0*sin(a))/scl
   pix(x,y,((((tx//1)~(ty//1))+xoroff)%16)/2)
  end
 end
 
 t=time()
 fftscl=fft(0)
 for i=0,6 do
  ra=(t+50*i)/1357
  rb=(t+50*i)/2468
  rc=(t+50*i)/2579
  sph(ra,rb,rc,i+8,30+i*5+fftscl*30,6-i)
 end
end

function sph(ra,rb,rc,clr,scl,dia)
 for i=0,#vertices-1 do
  v0=vertices[i]
  v1={
   v0[1]*cos(ra)+v0[3]*sin(ra),
   v0[2],
   v0[3]*cos(ra)-v0[1]*sin(ra)
  }
  v2={
   v1[1],
   v1[2]*cos(rb)+v1[3]*sin(rb),
   v1[3]*cos(rb)-v1[2]*sin(rb)
  }
  v3={
   v2[1]*cos(rc)+v2[2]*sin(rc),
   v2[2]*cos(rc)-v2[1]*sin(rc),
   v2[3],
  }
  circ(
   120+v3[1]*scl,
   68+v3[2]*scl,
   dia,clr
  )
 end
end
