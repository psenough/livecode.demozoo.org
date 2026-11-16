sin=math.sin
cos=math.cos
abs=math.abs
rand=math.random
pi=math.pi

t=0

function r(p,a)
 local c=cos(a) local s=sin(a)
 return {
  x=c*p.x-s*p.y,
  y=c*p.y+s*p.x
 }
end

function rot(pts)
 for i=1,#pts do
  local p=pts[i]
  local tmp=r({x=p.x,y=p.z},bt/19)
  p.x=tmp.x 
  p.z=tmp.y
  tmp=r({x=p.x,y=p.y},bt/17)
  p.x=tmp.x 
  p.y=tmp.y
 end
end

function scale(pts,s)
 for i=1,#pts do
  local z=pts[i].z*.5+1
  pts[i]={
   x=pts[i].x*s*68/z+120,
   y=pts[i].y*s*68/z+68,
   z=z
  }
 end
end

function cube()
 local pts={
  {x=-1,y=-1,z=-1},
  {x=1,y=-1,z=-1},
  {x=-1,y=1,z=-1},
  {x=1,y=1,z=-1},
  {x=-1,y=-1,z=1},
  {x=1,y=-1,z=1},
  {x=-1,y=1,z=1},
  {x=1,y=1,z=1}
 }
 rot(pts)
 scale(pts,.5+sin(bt/4)^5*.1)
 
 local idxs={
  {1,2,3,4},
  {5,6,7,8},
  {1,2,5,6},
  {3,4,7,8},
  {1,3,5,7},
  {2,4,6,8}
 }
 for i=1,6 do
  local l=idxs[i]
  local p0=pts[l[1]]
  local p1=pts[l[2]]
  local p2=pts[l[3]]
  local p3=pts[l[4]]
  --trace--(120+68)
  ttri(
   p0.x,p0.y,
   p1.x,p1.y,
   p2.x,p2.y,
   52,0,
   188,0,
   52,136,
   2,-1,
   p0.z,p1.z,p2.z)
  ttri(
   p1.x,p1.y,
   p2.x,p2.y,
   p3.x,p3.y,
   188,0,
   52,136,
   188,136,
   2,-1,
   p1.z,p2.z,p3.z)
 end
 
 for i=1,6 do
  local l=idxs[i]
  local p0=pts[l[1]]
  local p1=pts[l[2]]
  local p2=pts[l[3]]
  local p3=pts[l[4]]
  line(p0.x,p0.y,p1.x,p1.y,12)
  line(p1.x,p1.y,p3.x,p3.y,12)
  line(p2.x,p2.y,p3.x,p3.y,12)
  line(p2.x,p2.y,p0.x,p0.y,12)
 end
end

function fire()
 for y=t%2,135,2 do
  circb(
   sin(y*48933+t/157)*120+120,
   sin(y*45377+t/141)*68+68,
   sin(y*24783+t/37)*5+2,
   --rand()*240,
   --rand()*136,
   --rand()*5,
   10)
  for x=0,240 do
   pix(x,y,
    (
     pix(x,y)+
     pix(x+rand()*3-1,y+rand()*3)
    )/2
   )
  end
 end
end

cls()
bt=0

function TIC()
 bt=bt+fft(0,5)/1
 
 vbank(1)
 memcpy(0,0x4000,16320)
 vbank(0)
 for i=0,47 do
  poke(16320+i,sin(i+bt/60)^2*i*6)
 end
	fire()
	cube()
	
	memcpy(0x4000,0,16320)
	vbank(1)
 memcpy(0,0x4000,16320)
	print("=^^=",60,62,1,0,5) 
	print("=^^=",60,60,15,0,5) 
	memcpy(0x4000,0,16320)
	cls()
	--y=fft(0,5)*20
	--print("=^^=",5,42-y,0,0,10)
	--trace(w)
	t=t+1
end
