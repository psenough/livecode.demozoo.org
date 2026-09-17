sin=math.sin
cos=math.cos
abs=math.abs
rand=math.random
pi=math.pi
max=math.max
min=math.min

t=0

function rotpt(p,a)
 local c=cos(a)
 local s=sin(a)
 return {
  x=c*p.x-s*p.y,
  y=c*p.y+s*p.x
 }
end

function scalept(p,sc)
	return {x=p.x*sc.x,y=p.y*sc.y}
end

function transpt(p,s)
	return {x=p.x+s.x,y=p.y+s.y}
end

function box(origin,scale,angle,col)
 local pts={
 	{x=-1,y=-1},
 	{x=1,y=-1},
 	{x=-1,y=1},
 	{x=1,y=1}
 }
 for i=1,4 do
  pts[i]=scalept(pts[i],scale)
 	pts[i]=rotpt(pts[i],angle)
  pts[i]=transpt(pts[i],origin)
 end
 
 tri(
  pts[1].x,pts[1].y,
  pts[2].x,pts[2].y,
  pts[3].x,pts[3].y,
  col
 )
 tri(
  pts[2].x,pts[2].y,
  pts[3].x,pts[3].y,
  pts[4].x,pts[4].y,
  col
 )
end

xo=0
yo=0
dx=1
dy=0
pic=0
lastpic=-1
lastbump=0
maxbass=0

function bkg()
	xo=xo+dx
	yo=yo+dy
	
	bass=fft(10,15)
	maxbass=max(bass,maxbass*.98)
	if 
	 bass>maxbass*.95
	 and t-lastbump>40
	then
		local d=rotpt({x=dx,y=dy},rand()*pi*2)
		lastbump=t
		dx=d.x dy=d.y
		pic=pic+1
	end
	bass=bass+2
	circb(xo%240,yo%136,bass*4,bass+t/30)
	circb(xo%240-240,yo%136,bass*4,bass+t/30)
	circb(xo%240+240,yo%136,bass*4,bass+t/30)
	circb(xo%240,yo%136-136,bass*4,bass+t/30)
	circb(xo%240,yo%136+136,bass*4,bass+t/30)
end

function fuck()
 for i=0,1000 do
  local x=rand()*240
  local y=rand()*136
  local v=pix(x+1%240,y)+
  pix(x-1%240,y)+
  pix(x,y-1%136)+
  pix(x,y+1%136)
  pix(x,y,(pix(x,y)+v)/5)
 end
end

function draw()
 local pic=pic//1%3
 if pic~=lastPic then
		cls()
		lastPic=pic
		
	 --pic=2
	 local s=fft(0,10)/10+1
		local y=0
		local c=15
		for i=0,1 do
		 if pic==0 then
		  circ(120,68+y,50*s,c)
		  circ(120,68+y,40*s,0)
		  --o, s, a, c
		  box({x=120,y=68+y},{x=65*s,y=5*s},fft(0,10)/10,c)
		  box({x=100,y=68+y},{x=65*s,y=5*s},-1.2,c)
		  box({x=140,y=68+y},{x=65*s,y=5*s},1.2,c)
		 elseif pic==1 then
		  circ(120,68+y,30*s,c)
		  circ(120,68+y,20*s,0)
		  box({x=120,y=68+50+y},{x=25*s,y=5*s},0,c)
		  box({x=120,y=68+50+y},{x=5*s,y=25*s},0,c)
		  box({x=120+35,y=68-35+y},{x=25*s,y=5*s},-pi/4,c)
		  box({x=120+25,y=68-52+y},{x=25*s,y=5*s},0,c)
		  box({x=120+50,y=68-27+y},{x=5*s,y=25*s},0,c)
		  
		  box({x=120-35,y=68-35+y},{x=25*s,y=5*s},pi/4,c)
		  box({x=120-30,y=68-30+y},{x=17*s,y=5*s},-pi/4,c)
		  box({x=120-55,y=68-42+y},{x=5*s,y=15*s},0,c)
		  box({x=120-40,y=68-57+y},{x=15*s,y=5*s},0,c)
		 elseif pic==2 then
		  circ(120,68+y,60*s,c)
		  circ(120,68+y,50*s,0)
		  circ(120,68+y,25*s,c)
		  circ(120,68+y,15*s,0)
		  box({x=100,y=68+y},{x=65*s,y=5*s},-1.2,c)
		  box({x=140,y=68+y},{x=65*s,y=5*s},1.2,c)
		  box({x=110,y=95+y},{x=32*s,y=5*s},1.2,c)
		  box({x=130,y=95+y},{x=32*s,y=5*s},-1.2,c)
		  box({x=120,y=45+y},{x=32*s,y=5*s},0,c)
			end
			c=12
			y=-4
		end
	else
	 if t-lastbump>30 then
			for y=0,135 do
				local o=rand()*5//1
				local ls=y*120
				memcpy(ls+o,ls,120-o)
			end
		end
	end
end

cls()

function TIC()
	vbank(0)
	fuck()
	bkg()
	
	vbank(1)
	draw()
	--local y=abs(sin(t/12))*20
	--print("=^^=",5,42-y,15,0,10)
	--print("=^^=",5,40-y,12,0,10)
	
	--box({x=120,y=100},{x=50,y=10},sin(t/20),12)
	
	t=t+1
	vbank(0)
end

function SCN(y)
	vbank(0)
 local xp=xo%240-120-fft((y-t)%136)*80
 local yp=yo%136-68
	poke(0x3FF9,xp)
	poke(0x3FFa,yp)
	poke(0x3ff8,pix(xp%240,(y+yp)%136))
	vbank(1)
	local c=fft((y-t)%136,(y-t)%136+5)*100+50
	poke(16320+12*3+0,c)
	poke(16320+12*3+1,c)
	poke(16320+12*3+2,c)
end
