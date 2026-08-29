-- gasman is here!
-- have a good jam everybody :-D

 poke(16320,0)
 poke(16321,0)
 poke(16322,0)


buf={}
for y=0,136 do
 buf[y]={}
 for x=0,240 do
  buf[y][x]=0
 end
end

dither={
 {0,8,2,10},
 {13,4,12,6},
 {3,11,1,9},
 {14,7,15,5},
} 

function TIC()t=time()
for i=1,15 do
 k=math.sin(i*math.pi/8)
 h=(k/1.5+t/2345)%3
 if h<1 then
  r=h
  g=0
  b=1-h
 elseif h<2 then
  r=1-(h-1)
  g=h-1
  b=0
 else
  r=0
  g=1-(h-2)
  b=h-2
 end
 v=128+127*k
 poke(16320+i*3,v*r)
 poke(16321+i*3,v*g)
 poke(16322+i*3,v*b)
end

 fx1=20*math.sin(t/800)
 fy1=20*math.sin(t/812)

 for y=0,136 do
  for x=0,240 do
   cx=x-120-fx1
   cy=y-68-fy1
   r=math.sqrt(cx*cx+cy*cy)
   v1=math.sin((r-t/100)/10)
   cx=x-120+fx1
   cy=y-68+fy1
   r=math.sqrt(cx*cx+cy*cy)
   v2=math.sin((r-t/100)/10)
   buf[y][x]=128+127*(v1+v2)/2
  end
 end
 lx=120+120*math.sin(t/1000)
 ly=68+68*math.sin(t/1212)
 for y=0,135 do
  for x=0,239 do

   cx=x-120
   cy=y-68
   a=math.atan(cx,cy)
   rr=math.sqrt(cx*cx+cy*cy)+20*math.sin(a*6+t/456)
   
   if rr<120 then
   
    ldx=x-lx
    ldy=y-ly
    a=math.atan2(ldx,ldy)
    nx=buf[y][x]-buf[y][x+1]
    ny=buf[y][x]-buf[y+1][x]
    v=nx*math.sin(a)+ny*math.cos(a)

    v=v+dither[y%4+1][x%4+1]/16

    pix(x,y,v)
   else
    pix(x,y,0)
   end
  end
 end
 circ(lx,ly,3,4)
end
