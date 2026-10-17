-- hello from gasman!
-- while doing the firework effect
-- for The One That Got Away,
-- I found a neat algorithm for equal
-- distribution of points on a sphere
-- which I happily stole. So tonight
-- I feel like playing around with
-- that some more...

sin=math.sin
cos=math.cos

phi=math.pi*(math.sqrt(5)-1)

-- OK, so it's kind of hard to make
-- this into a mesh that isn't just
-- a spirograph splurge

-- while I ponder that, let's add
-- some motion blur

 for i=0,15 do
  poke(16320+i*3,i*4)
  poke(16321+i*3,i*17)
  poke(16322+i*3,i*8)
 end

cls()
function TIC()

 t=time()

 cs=t/5656
 r=sin(cs)/2+.5
 g=sin(cs+1)/2+.5
 b=sin(cs+2)/2+.5
 for i=0,15 do
  poke(16320+i*3,r*i*17)
  poke(16321+i*3,g*i*17)
  poke(16322+i*3,b*i*17)
 end
 
 for y=0,135 do
  for x=0,239 do
   c=pix(x,y)
   if c>0 then
    pix(x,y,c-1)
   end
  end
 end

 rx=t/2345
 ry=t/1234
 
 tx=sin(t/434)
 ty=sin(t/535)
 tz=sin(t/3636)

 pcount=30+29*sin(t/1234)
 
 points={}

 -- https://stackoverflow.com/questions/9600801/evenly-distributing-n-points-on-a-sphere
 for i=0,pcount-1 do
  y0=1-i/(pcount-1)*2
  r=math.sqrt(1-y0*y0)
  theta=phi*i
  x0=cos(theta)*r
  z0=sin(theta)*r
 
  x1=x0
  y1=y0*cos(rx)+z0*sin(rx)
  z1=z0*cos(rx)-y0*sin(rx)
  x2=x1*cos(ry)+z1*sin(ry)
  y2=y1
  z2=z1*cos(ry)-x1*sin(ry)
  x3=x2+tx
  y3=y2+ty
  z3=z2+tz+2.5
  
  sx=120+x3*120/z3
  sy=67+y3*120/z3
  points[i]={x0,y0,z0,sx,sy,z3}
 end
 
 maxd=(100-pcount)/60

 for i=0,pcount-1 do
  p0=points[i]
  sx=p0[4]
  sy=p0[5]
  z3=p0[6]

  circ(sx,sy,5-z3,15)
  
  for j=i+1,pcount-1 do
   p1=points[j]
   dx=p1[1]-p0[1]
   dy=p1[2]-p0[2]
   dz=p1[3]-p0[3]
   d=math.sqrt(dx*dx+dy*dy+dz*dz)
   if d<maxd then
    line(sx,sy,p1[4],p1[5],15)
   end
  end
 end
end
