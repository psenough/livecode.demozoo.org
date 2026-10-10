-- aldroid here!
-- happy holidays everyone, not plannin
-- anything festive visually but <3
-- hope you are all feeling good
-- love to my fellow coders, to violet
-- for hosting, and YOU

-- let's start with tcc extra day 8

n,m,r = 40,200,0.3
x,v,t=0,0,0,0
S,C=math.sin,math.cos
vbank(0)
for i=0,15 do
poke(0x3fc0+i*3,i*255/15)
poke(0x3fc1+i*3,i*255/15)
poke(0x3fc2+i*3,math.max(0,i-6)*255/10)
end
poke(0x03FF8,0)
vbank(1)
poke(0x3fC0,0)
poke(0x3fC1,0)
poke(0x3fC2,0)
cls()

snoz={}

for i=1,30 do
 snoz[i]={math.random(0,240),math.random(0,136)}
end

function TIC()
 vbank(1)
 cls(0)
 
 
 
 for i=1,#snoz do
  circ(snoz[i][1],snoz[i][2],1,12)
  snoz[i][2]=(snoz[i][2]+2)
  snoz[i][1]=snoz[i][1]+math.sin(i/2+t)
  if snoz[i][2] > 136 then
   snoz[i] = {math.random(0,240),-2}
   end
 end
 
 circ(120,50,11,13)
 circ(120,50,10,12)
 elli(120,80,18,21,13)
 elli(120,80,17,20,12)
 circ(120,56,1,15)
 circ(117,55,1,15)
 circ(123,55,1,15)
 
 circ(120,70,1,15)
 circ(120,75,1,15)
 circ(120,80,1,15)
 
 tri(118,50,122,50,120,54,3)
 
 circ(117,48,1,15)
 circ(123,48,1,15)
 
 rect(113,40,14,2,15)
 rect(116,32,8,8,15)
 
 arof=time()//200 % 2 == 0 and 10 or -10
 line(110,71,100,71+arof,1)
 line(110,70,100,70+arof,1)
 line(130,71,140,71-arof,1)
 line(130,70,140,70-arof,1)
 
 vbank(0)
 for x1=2,238 do for y1=2,133 do
 dx,dy=x1-120,y1-68
 mg=math.abs(dx)+math.abs(dy)
 dx=dx/mg
 dy=dy/mg
 x,y=x1-2*dx,y1-2*dy
 pix(x1,y1,(
  pix(x-1,y-1) + pix(x,y-1) + pix(x+1,y-1) +
  pix(x-1,y) + pix(x,y) + pix(x+1,y) +
  pix(x-1,y+1) + pix(x,y+1) + pix(x+1,y+1)
 )/9)
 end end

 for i=0,n do for j=0,m do
  a,b=i+v,r*i+x
  u=S(a)+S(b)
  v=C(a)+C(b)
  x=u+t
  fp = math.atan2(u,v)
  rd=35 +fft(10*fp)*50
  pix(120+u*rd,68+v*rd,1+i%15+j/36+fft(10*fp)*10)
 end end
 t = t+.025
end
