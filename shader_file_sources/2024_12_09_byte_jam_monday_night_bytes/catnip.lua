sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs
min=math.min
max=math.max
rand=math.random

t=0

memcpy(0x4000,0,16320)

function r(p,a)
 local c=cos(a)
 local s=sin(a)
 return {
  x=c*p.x-s*p.y,
  y=c*p.y+s*p.x
 }
end

function screen(rot,zoom,off)
	local pts={
	 {x=-1,y=-1},
		{x=1,y=-1},
		{x=-1,y=1},
		{x=1,y=1}
	}
	
	for i=1,#pts do
	 pts[i]=r(pts[i],rot)
		pts[i]={
		 x=pts[i].x*zoom+off.x,
			y=pts[i].y*zoom+off.y}
	end
	
	ttri(
	 pts[1].x*120+120,pts[1].y*68+68,
	 pts[2].x*120+120,pts[2].y*68+68,
	 pts[3].x*120+120,pts[3].y*68+68,
		0,0,
		240,0,
		0,136,
		2)
	
	ttri(
	 pts[2].x*120+120,pts[2].y*68+68,
	 pts[3].x*120+120,pts[3].y*68+68,
	 pts[4].x*120+120,pts[4].y*68+68,
		240,0,
		0,136,
		240,136,
		2)
end

bt=0

function TIC()
 bt=bt+fft(0,10)*1
 vbank(1)
 local add local rot local zoom 
 local off={x=sin(bt/17)^7*.05,y=cos(bt/13)^7*.05}
 local speck=false
 
 if t%480<60 then
  add=0x4000
  rot=sin(t/20)/4
		zoom=fft(0,10)/4+1
 else
  add=0x8000
  rot=sin(bt/33)^3*0.04
  zoom=sin(bt/37)^3*0.05+1.02
  speck=true
 end
 
 trace(add)
 memcpy(0,add,16320)
	vbank(0)
	
	cls()
	
	
	screen(rot,zoom,off)
	if speck then
	 for i=0,200 do
		 local x=rand()*240
			local y=rand()*136
   pix(x,y,pix(x,y)+1)
  end
  for i=0,20 do
   circ(
    sin(t/45+i/17+cos(t/34+i/19)^5)^3*80+120,
    cos(t/49+i/17+sin(t/37+i/19)^5)^3*80+68,
    4,
    (i%2)*12
   )
  end
 end
	
	if t%480<60 then
		vbank(rand()<0.01 and 0 or 1)
		cls()
		local y=abs(sin(t/12))*40
		print("=^^=",5,72-y/2,15,0,10)
		print("=^^=",5,70-y,12,0,10)
	end
		
	vbank(0)
	memcpy(0x8000,0,16320)
	
	t=t+1
end

function SCN(y)
 local v=(y-t)%136
 v=(fft(v,v+5)*10)//1
 memset(y*120+120-v,0,v)
 vbank(0)
	poke(0x3FF9,-v)
 vbank(1)
	poke(0x3FF9,v)
end