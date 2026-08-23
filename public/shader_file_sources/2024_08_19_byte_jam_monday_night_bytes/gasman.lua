-- hello, we are the gasmen

hr=0
hg=0
hb=0

function BDR(y)
 if y<80 then
  y1=80-y
  poke(16320,y1)
  poke(16321,y1)
  poke(16322,y1)
 else
  y1=y-80
  poke(16320,hr*(88+y1))
  poke(16321,hg*(88+y1))
  poke(16322,hb*(88+y1))

  poke(16320+45,hr*(44+y1))
  poke(16321+45,hg*(44+y1))
  poke(16322+45,hb*(44+y1))
 end
end

function TIC()
 cls()
 t=time()
 coords={}

 ht=t/4000
 hr=math.sin(ht)
 if hr<0 then hr=0 end
 hg=math.sin(ht+math.pi*2/3)
 if hg<0 then hg=0 end
 hb=math.sin(ht+math.pi*4/3)
 if hb<0 then hb=0 end
 
 
 scl=math.abs(math.cos(t*math.pi/400))
 offset=60*math.sin(t/1689)

 for x=-5,5 do
  for y=-5,5 do
   t1=t+(x*50)+(y*50)
   rx=t1/1234
   ry=t1/1345
   rz=t1/1456
   for z=-5,5 do
    x1=x
    y1=y*math.cos(rx)+z*math.sin(rx)
    z1=z*math.cos(rx)-y*math.sin(rx)

    x2=x1*math.cos(ry)+z1*math.sin(ry)
    y2=y1
    z2=z1*math.cos(ry)-x1*math.sin(ry)
    
    x3=x2*math.cos(rz)+y2*math.sin(rz)
    y3=y2*math.cos(rz)-x2*math.sin(rz)
    z3=z2

    sx=x3*(7+scl)+120+offset
    sy=y3*(7+scl)
    
    v=6*(math.sin(x/3+t/345)+math.sin(y/3+t/456)+math.sin(z/3+t/567))
    if v>0 then
     v=v%15
     table.insert(coords,{sx,sy,v//1,z3})
    end
   end
  end
 end

 for i=1,#coords do
  c=coords[i]
   if c[4]>-3 then r=2 else r=1 end
   circ(c[1],120-c[2]/2,r,15)
 end

 for z=-10,10 do
  if z>-3 then
   r=2
  else
   r=1
  end
  for i=1,#coords do
   c=coords[i]
   if c[4]>=z and c[4]<z+1 then
    circ(c[1],c[2]+50,r,c[3])
   end
  end
 end

end
