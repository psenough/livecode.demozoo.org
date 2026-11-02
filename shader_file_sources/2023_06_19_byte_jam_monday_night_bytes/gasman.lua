-- hello from gasman!!!
-- let's all get hyped for NOVAAAAA

-- greetings to reality404, alia  ^
--                           and tobach

function SCN(y)
 if y<100 then
  poke(16320,0)
  poke(16321,0)
  poke(16322,0)
 else
  v=(y-100)*4
  poke(16320,v)
  poke(16321,v)
  poke(16322,v)  
 end
 s=(y-30)/70
 poke(16320+27,0x3b*s)
 poke(16321+27,0x5d*s)
 poke(16322+27,0xc9*s)
end

function person(x,y,bop)
 circ(x,y+bop,2,13)
 rect(x-2,y+4,5,10,13)
 rect(x-1,y+14,3,6,13)
end

starcount=60
stars={}
for i=0,starcount do
 stars[i]={
  math.random(0,239),
  math.random(0,50),
  math.random()
 }
end

galcount=50
gal={}
for i=0,galcount do
 gal[i]={
  math.random(),
  math.random(),
 }
end

function TIC()
 t=time()
 vol=fft(0)
 -- rect(0,0,240,110,0)
 cls()
 for i=0,starcount do
  s=stars[i]
  pix(
   s[1],s[2],
   13+(1+math.sin(t/400+s[3]*8)/2*4)
  )
 end
 
 for j=0,galcount do
  -- ok, so galaxies don't actually
  -- spin on a timescale comprehensible
  -- to humans, but let's use some
  -- artistic licence here
  g=gal[j]
  i=j/50
  a=i*10+t/10000
  k=2.1
  x=i*math.sin(a)*20
  y=i*math.cos(a)*40
  x1=150+x*math.cos(k)+y*math.sin(k)
  y1=30+y*math.cos(k)-x*math.sin(k)
  circ(x1+g[1]*2,y1+g[2]*2,1,12+i*4)
  x=i*math.sin(a+math.pi)*20
  y=i*math.cos(a+math.pi)*40
  x1=150+x*math.cos(k)+y*math.sin(k)
  y1=30+y*math.cos(k)-x*math.sin(k)
  circ(x1+g[1]*2,y1+g[2]*2,1,12+i*4)
 end

 fx=160
 fy=120
 for i=0,10 do
  dx=math.random(-10,10)
  dy=math.random(0,10)
  clr=2+math.random(0,2)
  line(fx,fy,fx+dx,fy-dy,clr)
  line(fx+1,fy,fx+dx+1,fy-dy,clr)
 end

 for i=2,6 do
  pix(fx+(i-4)*4,fy-(t/50+10*math.sin(i))%20,i%3+2)
 end

 for z=1,1.7,.05 do
  for x=-1,1,.03 do
   z1=z+math.sin(z+x*8+t/400)/10
   sy=-10+100/z1
   sx=120+x*100*(3/z1)
   circ(sx,sy,2,9)
  end
 end
 rect(104,109,9,11,14)
 circ(108,115,2+vol*10,15)

 for i=0,8 do
  a=i*math.pi/4
  person(
   160+30*math.cos(a),
   110+15*math.sin(a),
   vol*10
  )
 end

end
