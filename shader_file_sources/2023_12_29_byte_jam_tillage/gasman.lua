-- merry tillagemas everyone!!!!!!
-- gasman here!
-- greetings to all tillage people

poke(16323,0)
poke(16324,64)
poke(16325,0)

for i=2,5 do
 poke(16320+i*3,8*i)
 poke(16321+i*3,128+16*i)
 poke(16322+i*3,8*i)
end

for i=6,9 do
 v=i-6
 poke(16320+i*3,128+32*v)
 poke(16321+i*3,128+32*v)
 poke(16322+i*3,0+16*v)
end

for i=10,14 do
 poke(16320+i*3,128+128*math.sin(i+2))
 poke(16321+i*3,128+128*math.sin(i+3))
 poke(16322+i*3,128+128*math.sin(i+4))
end

coords={
 {0,0.4,0},
 {0,-0.4,0},
}

for i=0,4 do
 a=math.pi*2*i/5
 coords[i+3]={
  math.cos(a)*2,-0.4,math.sin(a)*2
 }
end

for i=0,4 do
 b=math.pi*2*(i/5+1/10)
 coords[i+8]={
  math.cos(b),0,math.sin(b)
 }
end

function vline(v1,v2,c)
 line(
  120+25*v1[1],68+25*v1[2],
  120+25*v2[1],68+25*v2[2],
  c
 )
end

function vcirc(v1,c)
 circ(
  120+25*v1[1],68+25*v1[2],
  3,
  c
 )
end

function vtri(v1,v2,v3,c)
 tri(
  120+25*v1[1],68+25*v1[2],
  120+25*v2[1],68+25*v2[2],
  120+25*v3[1],68+25*v3[2],
  c
 )
end

function star(a,b,c,dy,s,k)
 v={}
 for i=1,12 do
  v0=coords[i]
  x0=v0[1]*s
  y0=v0[2]*s+dy
  z0=v0[3]*s
  x1=x0*math.cos(c)+z0*math.sin(c)
  y1=y0
  z1=z0*math.cos(c)-x0*math.sin(c)
  x2=x1
  y2=y1*math.cos(a)+z1*math.sin(a)
  z2=z1*math.cos(a)-y1*math.sin(a)
  x3=x2*math.cos(b)+z2*math.sin(b)
  z3=z2*math.cos(b)-x2*math.sin(b)
  y3=y2
  p=1+z3/5
  v[i]={x3*p,y3*p}
 end
 for i=0,4 do
  vtri(v[1],v[i+3],v[i+8],2+k)
  vtri(v[2],v[i+3],v[i+8],3+k)
  vtri(v[1],v[(i+1)%5+3],v[i+8],4+k)
  vtri(v[2],v[(i+1)%5+3],v[i+8],5+k)
 end

 if k==0 then
  for i=3,12 do
   vline(v[1],v[i],1+k)
   vline(v[2],v[i],1+k)
  end
  for i=0,4 do
   vline(v[i+3],v[i+8],1)
   vline(v[i+8],v[(i+1)%5+3],1)
  end

  for i=3,7 do
   vcirc(v[i],dy+12)
  end

 end
end

function TIC()
 cls()
 t=time()
 a=t/1234
 b=t/2345
 for i=-2,2 do
  if i==2 then
   k=4
  else
   k=0
  end
  star(a,b,4*math.sin((t+i*150)/945),i,0.866-i/3,k)
 end
end

function SCN(y)
 y1=y+time()/300
 y2=y+time()/360
 poke(16320,48+32*math.sin(y1/4))
 poke(16321,0)
 poke(16322,48+32*math.sin(y2/4))
end
