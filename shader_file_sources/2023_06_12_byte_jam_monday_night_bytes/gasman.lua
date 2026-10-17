-- hello from gasman!
--                              ^
-- greetings to alia, visy and tobach
-- and jam-master aldroid!

-- right, going to have a go at a
-- voxel landscape
-- which i did recently, but this one
-- is going to be... different. I
-- guess.


noise={}
for y=0,512 do
 noise[y]={}
 for x=0,512 do
  noise[y][x]=math.random(0,16)
 end
end

land={}
for y=0,255 do
 land[y]={}
 for x=0,255 do
  land[y][x]=0
 end
end

for oct=1,6 do
 k=2^oct
 s=2^(7-oct)
 for y=0,255 do
  for x=0,255 do
   vy=y//k
   vx=x//k
   fy=(y%k)/k
   fx=(x%k)/k
   x0=noise[vy][vx]*(1-fy)+noise[vy+1][vx]*fy
   x1=noise[vy][vx+1]*(1-fy)+noise[vy+1][vx+1]*fy
   v=x0*(1-fx)+x1*fx
   land[y][x]=land[y][x]+v/s
  end
 end
end

function SCN(y)
 -- gasman patented gradient background
 poke(16320,y)
 poke(16321,y)
 poke(16322,y)
end

function TIC()
 cls()
 t=time()
 a=t/1234
 sa=math.pi/4
 for y=-40,40 do
  for x=-40,40,.5 do
   vrx=x*math.cos(a)+y*math.sin(a)
   vry=y*math.cos(a)-x*math.sin(a)+100*math.sin(t/1000)

   cx1=vrx+5*math.sin(t/123)
   cy1=vry+5*math.sin(t/232)
   c1=math.sqrt(cx1*cx1+cy1*cy1)

   cx2=vrx-5*math.sin(t/123)
   cy2=vry-5*math.sin(t/232)
   c2=math.sqrt(cx2*cx2+cy2*cy2)

   --v=(
   -- math.sin(vrx*.12)+math.sin(vrx*.23)
   -- +math.sin(vry*.34)+math.sin(vry*.15)
   --)*2+8
   v=land[vry%256//1][vrx%256//1]-2
   v=v+math.sin(c1/4)
   v=v+math.sin(c2/4)
   v=v*(1+fft(1)*2)
   rx=x*math.cos(sa)+y*math.sin(sa)
   ry=y*math.cos(sa)-x*math.sin(sa)
   sy=88+(ry*2)/2
   sx=120+(rx*2)
   line(sx,sy,sx,sy-v*4,v)
  end
 end
end
