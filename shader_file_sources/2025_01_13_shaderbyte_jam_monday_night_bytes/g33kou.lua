-- hello everyone :)

sin=math.sin
cos=math.cos
pi=math.pi
rnd=math.random

function col(i,r,g,b)
   poke(0x03FC0+3*i,r)
   poke(0x03FC0+3*i+1,g)
   poke(0x03FC0+3*i+2,b)
end

function don(x,y,d,nb,c,a)
   rx,ry=rot(x,y,a)
   for i=0,nb do
      a=i*2*pi/nb
      pix(120+rx+cos(a)*(rnd(d)+d/2), 68+ry+sin(a)*(rnd(d)+d/2), c)
   end
end

function rot(x,y,a)
   xr=x*cos(a)-y*sin(a)
   yr=x*sin(a)+y*cos(a)
   return xr,yr
end

b=0
function TIC()
   b=b+.01
   cls()
   ff1=fft(0,100)*200
   ff2=fft(100,500)*200
   ff3=fft(500,1000)*200
   col(1,ff1,ff2,ff3)
   col(2,ff2,ff3,ff1)
   col(3,ff3,ff1,ff2)
   don(0,0,30,300,1,0)
   don(40,40,15,80,2,b)
   don(40,40,15,80,3,b+pi/2)
   don(40,40,15,80,2,b+2*pi/2)
   don(40,40,15,80,3,b+3*pi/2)
end
