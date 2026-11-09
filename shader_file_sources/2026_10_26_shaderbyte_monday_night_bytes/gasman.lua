-- hello from gasman!!!

sin=math.sin
cos=math.cos

cx=200
cy=40

maxr=64

spokecount=12
spokeangles={}
spokerads={}

spiderspoke=9

function makespokes()
 for i=0,spokecount-1 do
  ang=(
   i/spokecount*2*math.pi
   +math.random()*.3
  )
  spokeangles[i]=ang
  -- distance to right wall
  rdist=240-cx
  xlen=sin(ang)*maxr
  r=maxr
  if xlen>rdist then
   r=r*rdist/xlen
  end
  ylen=-cos(ang)*r
  if ylen>cy then
   r=r*cy/ylen
  end
  spokerads[i]=r
  ylen=cos(ang)*maxr
 end
end

spircount=100
rads={}

function makespir()
 dr=.1
 r=0
 for i=0,spircount-1 do
  dr=math.min(math.max(
   dr+(math.random()-.5)*.8,
  0),1)
  r=math.min(r+dr,56)
  rads[i]=r/maxr
 end
end

function makeweb()
 makespokes()
 makespir()
end
makeweb()

faket=0

blink=0
lightning=0

function TIC()
 faket=faket+1
 --t=time()//1
 if faket%12==0 then
  makeweb()
 end
 cls(0)
 
 if math.random()<.008 then
  blink=10
 elseif blink>0 then
  blink=blink-1
 end

 if math.random()<.008 then
  lightning=10
 elseif lightning>0 then
  lightning=lightning-1
 end

 for i=0,9 do
  poke(16320+i*3,(40+lightning*3)*(i/9))
  poke(16321+i*3,(40+lightning*3)*(i/9))
  poke(16322+i*3,(80+lightning*3)*(i/9))
 end

 for sy=0,135 do
  y=(sy-67.5)/120
  for sx=0,239 do
   x=(sx-119.5)/240
   z1=math.abs(1/y)
   z2=math.abs(1/x)
   z=math.min(z1,z2)
   if z<10 then
    pix(sx,sy,9-z)
   end
  end
 end

 for i=0,spokecount-1 do
  ang=spokeangles[i]
  xend=64*sin(ang)
  yend=64*cos(ang)
  line(cx,cy,cx+xend,cy+yend,12)
 end
 rad=0
 lastx=cx
 lasty=cy
 for i=0,spircount-1 do
  ang=spokeangles[i%spokecount]
  r=rads[i]*spokerads[i%spokecount]
  x=cx+r*sin(ang)
  y=cy+r*cos(ang)
  line(lastx,lasty,x,y,12)
  lastx=x
  lasty=y
 end

 ang=spokeangles[spiderspoke]
 xend=cx+64*sin(ang)
 yend=cy+64*cos(ang)
 spida=sin(time()/1000)
 spidx=140+20*sin(spida)
 spidy=90+20*cos(spida)
 spidv=cos(spida)*1.3
 line(xend,yend,spidx,spidy,12)
 elli(spidx,spidy,4,3,13)

 line(spidx,spidy,spidx+6,spidy-3,13)
 line(spidx+6,spidy-3,spidx+6+4*spidv,spidy+2,13)

 line(spidx,spidy,spidx+6,spidy,13)
 line(spidx+6,spidy,spidx+6+4*spidv,spidy+5,13)

 line(spidx,spidy,spidx-6,spidy-3,13)
 line(spidx-6,spidy-3,spidx-6-4*spidv,spidy+2,13)

 line(spidx,spidy,spidx-6,spidy,13)
 line(spidx-6,spidy,spidx-6-4*spidv,spidy+5,13)
 
 if blink>0 then
  line(spidx-3,spidy-1,spidx-1,spidy-1,0)
  line(spidx+3,spidy-1,spidx+1,spidy-1,0)
 else
  circ(spidx-2,spidy-1,1,12)
  pix(spidx-2,spidy-1,0)
  circ(spidx+2,spidy-1,1,12)
  pix(spidx+2,spidy-1,0)
 end

end
