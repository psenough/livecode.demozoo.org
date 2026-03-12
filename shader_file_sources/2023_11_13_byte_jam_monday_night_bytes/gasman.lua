
-- BYTE JAM IS JARIG!!!!!!!!
-- greetings to everyone....     ^
-- mantratronic * doctor soft * tobach
-- lynn * evilpaul * lex * visy
-- jtruk * raccoonviolet * aldroid

function TIC()
 t=time()
 for i=1,14 do
  poke(16320+i*3,192)
  v=128+96*math.sin(i*math.pi/8+t/100)
  poke(16321+i*3,v)
  poke(16322+i*3,0)
 end
 
 poke(16320+45,0)
 poke(16320+46,128)
 poke(16320+47,32)

 cls()

coords={}
for x=-14,14 do
 coords[x]={}
 r2=(1.1+0.3*math.sin(t/156+x))*(14-math.abs(x))/14
 for y=0,16 do
  ya=math.pi*2*y/16
  coords[x][y]={
   x/2,r2*math.cos(ya)+1.5*math.sin(t/234+x/4),r2*math.sin(ya)
  }
 end
end


ry=t/534

rcoords={}

for x=-14,14 do
 rcoords[x]={}
 for y=0,16 do
  coord=coords[x][y]
  x1=coord[1]*math.cos(ry)+coord[3]*math.sin(ry)
  y1=coord[2]
  z1=coord[3]*math.cos(ry)-coord[1]*math.sin(ry)
  zscale=1+5/(10+z1)
  rcoords[x][y]={
   120+10*zscale*(x1),
   68+10*zscale*(coord[2])
  }
 end
end

for x=-14,13 do
 for y=0,16 do
  c0=rcoords[x][y]
  c1=rcoords[x][(y+1)%16]
  c2=rcoords[x+1][y]
  tri(
   c0[1],c0[2],
   c1[1],c1[2],
   c2[1],c2[2],
   (x//2)+8
  )
 end
end

for x=-10,10 do
 for z=-10,10 do
  x1=x*math.cos(ry)+z*math.sin(ry)
  z1=5+z*math.cos(ry)-x*math.sin(ry)
  y1=(
   8+math.sin(x+t/234)/2
   +math.sin(z/4+t/2345)/2
  )
  zscale=1+5/(20+z1)
  circ(120+6*x1*zscale,68+6*y1*zscale,2,15)
 end
end

--for x=-14,14 do
-- for y=0,16 do
--  coord=rcoords[x][y]
--  circ(
--   coord[1],
--   coord[2],
--   1,(x//2)+8
--  )
-- end
-- end
 
end
