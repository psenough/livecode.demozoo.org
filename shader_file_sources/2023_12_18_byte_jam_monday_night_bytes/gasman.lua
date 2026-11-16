-- gasman is cooking some pasta because
-- he didn't time this very well

-- greetings to my fellow bytejammers
-- suule, aldroid, jtruk, nico and^
--                               tobach
-- and of course raccoonviolet!

for i=1,8 do
 poke(16320+i*3,128+16*i)
 poke(16321+i*3,32+16*i)
 poke(16322+i*3,32+16*i)
end
i=9
 poke(16320+i*3,244)
 poke(16321+i*3,244)
 poke(16322+i*3,124)
i=10
 poke(16320+i*3,0)
 poke(16321+i*3,184)
 poke(16322+i*3,24)

function BDR(y)
 poke(16320,y*0.5)
 poke(16321,y*0.7)
 poke(16322,y)
end

zoom=70

snow={}
for i=0,100 do
 snow[i]={
  math.random(),math.random(),
  math.random()
 }
end

function TIC()
 cls()
 t=time()
 rx=0.3
 rz=0.7
 for f=0,2 do
  tr=t/2678+f*math.pi*2/3
  for k=0,1,0.05 do
   for i=0,2*math.pi,0.02 do
    r=math.sin(i*6)*k
    a=i
    x0=r*math.sin(a)
    z0=r*math.cos(a)
    y0=-math.sin(a/10+0.2+math.abs(r)*2)*0.7
    x1=x0*math.cos(rz)+y0*math.sin(rz)-1
    y1=y0*math.cos(rz)-x0*math.sin(rz)
    
    x=x1*math.cos(tr)+z0*math.sin(tr)
    z=z0*math.cos(tr)-x1*math.sin(tr)
    y=y1*math.cos(rx)+z*math.sin(rx)
    pix(120+zoom*x,100+zoom*y,k*7+1)
    
   end
  end

  for k=0,1,0.1 do
   for i=0,2*math.pi,0.2 do

    r=k*0.3
    a=i
    x0=r*math.sin(a)
    z0=r*math.cos(a)
    y0=-0.6-math.cos(k*math.pi/2)/5
    x1=x0*math.cos(rz)+y0*math.sin(rz)-1
    y1=y0*math.cos(rz)-x0*math.sin(rz)

    x=x1*math.cos(tr)+z0*math.sin(tr)
    z=z0*math.cos(tr)-x1*math.sin(tr)
    y=y1*math.cos(rx)+z*math.sin(rx)
    pix(120+zoom*x,100+zoom*y,9)
   end
  end

  for k=0,1,0.04 do
    r=0
    a=0
    x0=0
    z0=0
    y0=-math.sin(0.2)*0.7
    x1=(x0*math.cos(rz)+y0*math.sin(rz)-1)*k
    y1=y0*math.cos(rz)-x0*math.sin(rz)+(1-math.sqrt(k))/2

    x=x1*math.cos(tr)+z0*math.sin(tr)
    z=z0*math.cos(tr)-x1*math.sin(tr)
    y=y1*math.cos(rx)+z*math.sin(rx)
    pix(120+zoom*x,100+zoom*y,10)

  end

 end

 for i=0,100 do
  s=snow[i]
  x1=(s[1]-0.5)*5
  z0=(s[2]-0.5)*5
  y1=((s[3]+t/1234)%1)-1
  x=x1*math.cos(tr)+z0*math.sin(tr)
  z=z0*math.cos(tr)-x1*math.sin(tr)
  y=y1*math.cos(rx)+z*math.sin(rx)
  pix(120+zoom*x,100+zoom*y,13)
 end

end
