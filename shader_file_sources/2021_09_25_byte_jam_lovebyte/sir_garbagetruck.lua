function TIC()t=time()//32
 chk=chk+1
 tq=mf(t/16)
 if (chk==100) then
  gr(tq)
  chk=0
 end

 fkc(1)

 for i=15,75,5 do
  dhex(xc,yc,i,i/5)
 end
 
 ht(-10,t/100)
 ht(110,t/100)
 
-- if (m.abs(chk/8)==chk/8 ) then
--  fkc(3)
-- end

 yo=ms(t/102)*25
 print('HACK THE PLANET',30,100+yo,4,false,2,false) 
 
 hackface()
 
end
-- pos: 0,0
m=math
ms=m.sin
mc=m.cos
mf=m.floor
pi=m.pi
xc=240/2
yc=136/2

dots = {
 {3,1},{6,1},
 {4,2},{5,2},
 {1,4},{8,4},
 {2,5},{7,5},
 {4,7},{5,7},
 {3,8},{6,8}
 }

lines={
 {3,1},{3,3},
 {3,3},{4,3},
 {4,2},{4,7},
 {5,2},{5,7},
 {5,3},{6,3},
 {6,3},{6,1},
 {1,4},{8,4},
 {2,5},{7,5},
 {3,8},{3,6},
 {3,6},{4,6},
 {5,6},{6,6},
 {6,6},{6,8}
 }

hofs=(2*pi)/12

function hackface()
 circ(xc,yc,12,4)
 circb(xc,yc,8,0)
 rect(xc-8,yc-8,20,8,4)
 circ(xc-4,yc-3,2,0)
 line(xc-8,yc-8,xc+12,yc-4,0)
 elli(xc+4,yc-4,4,3,0)
 
end

-- let's learn to spell
function mkhex(r)
 hext={}
 for i=1,6 do
  ang=(2*pi)/6 * i
  x=(mc(ang+hofs)*r)
  y=(ms(ang+hofs)*r)
  xy={x,y}
  hext[i]=xy
 end
 return hext
end

function dhex(xo,yo,r,c)
 hex=mkhex(r)
 x2=hex[6][1]+xo
 y2=hex[6][2]+yo
 for i=1,6 do
  x1=hex[i][1]+xo
  y1=hex[i][2]+yo
  line(x1,y1,x2,y2,c)
  x2=x1
  y2=y1
 end
end 


function fkc(b)
 for x=2,240,2 do
  for y=2,136,2 do
   c=pix(x,y)
   cc=pix(x-b,y)
   ccc=pix(x,y-b)
   ts=ms(t)
   tc=mc(t)
   c1=c+ts
   c2=c+tc
   pix(x+ts,y+tc,c1)
   pix(x,y,c2)
   pix(x-1,y-1,ccc)
   pix(x,y,cc)
  
  end
 end
end
 
off=25
scl=10

function gr(tr)
 for x1 = 1,240,8 do
  for y1 = 1,136,8 do
   circ (x1+4+tq,y1+4+tq,3,x1*y1>>2)
   circb (x1+3,y1+3,3,3)
   p = ms(x1*y1)
   circb(x1+tq,y1+tq,3,p)
  end
 end
end

function ht(xo,r)
 xr = ms(r)*50
 yr = mc(r)*50
 for i=1,24,2 do
  x1=lines[i][1]*scl+off+xo
  y1=lines[i][2]*scl+off
  x2=lines[i+1][1]*scl+off+xo
  y2=lines[i+1][2]*scl+off
  x1r=x1+xr
  y1r=y1+yr
  x2r=x2+xr
  y2r=y2+yr
  -- freaking editor missing
  -- emacs keys
  line(x1,y1,x1r,y1r,8)
  line(x1r,y1r,x2r,y2r,2)
  line(x1,y1,x2,y2,6)
  x1=x2
  y1=y2
 end
 
 for i=1,12 do
  x=dots[i][1]*scl+off+xo
  y=dots[i][2]*scl+off
  circ(x,y,scl/2,5)
  circb(x,y,scl/2,6)
 end
end

-- dammit I just want to have
-- this reset ever so often and
-- I forgot how to do that with
-- binary operators

chk = 0