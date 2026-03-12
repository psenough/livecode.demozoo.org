-- hello from gasman
-- and happy lovebyte everyone!

-- I have no idea what I'm doing.

tex={}
for y=0,127 do
 tex[y]={}
 for x=0,127 do
  tex[y][x]=math.random(0,2)
 end
end

sprites={}
for i=0,63 do
 sprites[i]={math.random(),math.random(),math.random(8,15)}
end

function iter()
 -- so there's a funky cellular
 -- automation I saw the other day
 -- based on rock paper scissors.
 -- each cell changes to the 'winner'
 -- state if there are at least THREE
 -- neighbours that beat it
 -- I'm not sure how neighbours are
 -- defined though. Let's find out...
 -- okay, maybe diagonals count too
 tex1={}
 for y=0,127 do
  tex1[y]={}
  for x=0,127 do
   me=tex[y][x]
   y0=(y+127)%128
   y2=(y+1)%128
   x0=(x+127)%128
   x2=(x+1)%128
   winner=(me+1)%3
   wc=0
   if tex[y0][x0]==winner then wc=wc+1 end
   if tex[y0][x]==winner then wc=wc+1 end
   if tex[y0][x2]==winner then wc=wc+1 end
   if tex[y][x0]==winner then wc=wc+1 end
   if tex[y][x2]==winner then wc=wc+1 end
   if tex[y2][x0]==winner then wc=wc+1 end
   if tex[y2][x]==winner then wc=wc+1 end
   if tex[y2][x2]==winner then wc=wc+1 end
   -- eek
   if wc>=3 then
    tex1[y][x]=winner
   else
    tex1[y][x]=me
   end
  end
 end
 tex=tex1
end

pal1=peek(16323)
pal2=peek(16324)
pal3=peek(16325)

maxf=0
function TIC()
t=time()
dx=math.sin(t/1234)
dy=math.sin(t/2345)
-- maybe some sphere mapping
-- rather than the weird fisheye thing?
f=fft(0)
if f>maxf then maxf=f end
f=f/maxf
poke(16323,255*f+pal1*(1-f))
poke(16324,255*f+pal2*(1-f))
poke(16325,255*f+pal3*(1-f))
poke(16326,128+127*math.sin(t*math.pi/3000))
poke(16327,128+127*math.sin((t+1000)*math.pi/3000))
poke(16328,128+127*math.sin((t+2000)*math.pi/3000))
for y=0,136 do
 sy=(y-68)/68
 for x=0,240 do
  sx=(x-120)/68
  r2=sx*sx+sy*sy
  if r2>1 then r2=1/r2 end
  g=math.atan2(sx,sy)
  tx=((r2*math.cos(g)+dx)*32//1)%128
  ty=((r2*math.sin(g)+dy)*32//1)%128
  pix(x,y,tex[ty][tx])
 end
end
for i=0,63 do
 sprite=sprites[i]
 a=2*math.pi*(sprite[1]+t/13570)
 b=2*math.pi*(sprite[2]+t/24680)
 x0=1
 y0=0
 z0=0
 x1=x0*math.cos(a)+z0*math.sin(a)
 y1=y0
 z1=z0*math.cos(a)-x0*math.sin(a)
 x2=x1
 y2=y1*math.cos(b)+z1*math.sin(b)
 z2=z1*math.cos(b)-y1*math.sin(b)
 if z2>0 then
  circ(128+x2*68,68+y2*68,1,sprite[3])
 end
end
for i=0,128 do
 tex[math.random(0,127)][math.random(0,127)] = math.random(0,2)
end
iter()
end
