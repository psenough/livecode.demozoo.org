-- hello from gasman!
-- a merry new year to all

-- too much typing.
cos=math.cos
sin=math.sin

poke(16320,0)
poke(16321,0)
poke(16322,0)
poke(16323,48)
poke(16324,0)
poke(16325,56)

 for i=2,9 do
  poke(16320+i*3,48+i*4)
  poke(16321+i*3,32+i*2)
  poke(16322+i*3,128+i*8)
 end
 for i=10,15 do
  poke(16321+i*3,32+i*4)
  poke(16322+i*3,0+i*2)
  poke(16320+i*3,32+i*8)
 end

function TIC()
 t=time()

 rx=.6*math.sin(t/1234)
 crx=cos(rx)
 srx=sin(rx)
 rz=.4*math.sin(t/2345)
 crz=cos(rz)
 srz=sin(rz)
 ry=.3*math.sin(t/1357)
 cry=cos(ry) -- don't cry pretty little sky
 sry=sin(ry)
 dz=t/350
 dx=6*math.sin(t/3456)
 
 rf=5*math.sin(t/2357)
 
 amp=1+.5*math.sin(t/4333)

 for sy=0,136 do
  for sx=0,240 do
   cx0=(sx-119.5)/120
   cy0=(sy-67.5)/120
   cz0=1
   cx1=cx0
   cy1=crx*cy0+srx*cz0
   cz1=crx*cz0-srx*cy0
   cx2=crz*cx1+srz*cy1
   cy2=crz*cy1-srz*cx1
   cz2=cz1
   cx=cry*cx2+sry*cz2
   cy=cy2
   cz=cry*cz2-sry*cx2
   tx=cx/cy
   y=1
   tz=cz/cy
   if tz<0 then
    tz=-tz
    tx=-tx
   end
   if tz>20 then
    pix(sx,sy,0)
   else
    tx=(tx/3)+dx
    tz=(tz/3)+dz
    tzi=tz//1
    if tzi&1 then
     tx=tx+0.5
    end
    fg=(((tx//1*9)~(tzi*7))%14)+2
    l=fg%5+3
    txf=((tx+100)%1)-0.5
    tzf=((tz+100)%1)-0.5
    a=math.atan2(txf,tzf)+(rf*l/4)
    r=math.sqrt(txf*txf+tzf*tzf)
    if r>(0.45*math.abs(sin(a*l/2))) then
     v=((tx*8+sin(tz*8*amp))//1)&1
    else
     v=fg
    end
    pix(sx,sy,v)
   end
  end
 end
end
