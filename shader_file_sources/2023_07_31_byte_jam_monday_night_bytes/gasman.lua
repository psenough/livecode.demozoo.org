-- gasman here!!!!!!

-- greetings to aldroid, aldroid's dog,
-- alia, jtruk, mrsynackster + psenough

-- thanks to everyone who sent get-well
-- wishes during evoke :-)

-- fuckings to covid

-- ok, I haven't done a good old
-- 3D doughnut before (I think)

function TIC()
 t1=time()/1355
 t2=math.sin(time()/245)*32
 t3=math.sin(time()/356)*32
 t4=0.4+0.4*(1+math.sin(time()/68))
 for y=0,135 do
  for x=0,239 do
   tx=(x+t2)%32-16
   ty=(y+t3)%32-16
   a=math.atan2(tx,ty)+t1
   r=math.sqrt(tx*tx+ty*ty)/16
   if r*(1+math.sin(a*5))<t4 then
    pix(x,y,1)
   else
    pix(x,y,4)
   end
  end
 end
 r1=time()/345
 r2=time()/456
 r3=time()/567
 smallr=0.3+fft(0)*3
 bigr=1

 for b=0,math.pi*2,0.1 do
 for a=0,math.pi*2,0.2 do
  x0=math.cos(a)*smallr+bigr
  y0=math.sin(a)*smallr
  z0=0
  
  -- create torus by sweeping around
  -- y axis
  x1=x0*math.cos(b)+z0*math.sin(b)
  y1=y0
  z1=z0*math.cos(b)-x0*math.sin(b)
  
  x2=x1
  y2=y1*math.cos(r1)+z1*math.sin(r1)
  z2=z1*math.cos(r1)-y1*math.sin(r1)

  x3=x2*math.cos(r2)+y2*math.sin(r2)
  y3=y2*math.cos(r2)-x2*math.sin(r2)
  z3=z2

  x4=x3*math.cos(r3)+z3*math.sin(r3)
  y4=y3
  z4=z3*math.cos(r3)-x3*math.sin(r3)

  sx=120+x4*40
  sy=68+y4*40
  clr=(a//0.4)~(b//0.1)
  circ(sx,sy,2,clr%16)
 end
 end
end
