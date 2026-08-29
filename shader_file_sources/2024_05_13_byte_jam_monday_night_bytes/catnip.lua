sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi

t=0

cls()
vbank(1)
poke(16320+15+0,180)
poke(16320+15+1,30)
poke(16320+15+2,30)
p={x=120,y=68,dx=2,dy=0}
scroll={x=0,y=0}

function rot(p,a)
	--p=cos(a)*p+sin(a)*{-p.y,p.x}
	local c=cos(a)
	local s=sin(a)
	return {
		x=(c*p.x) + (s*-p.y),
		y=(c*p.y) + (s*p.x)
	}
end

function rcirc() 
 local r=2+ffts(5,10)*5
 circ(p.x+2,p.y+2,r,0)
 circ(p.x,p.y,r,t)
 if p.x<r then 
 	circ(p.x+242,p.y+2,r,0) 
 	circ(p.x+240,p.y,r,t) 
 end
 if 240-p.x<r then 
  circ(p.x-242,p.y-2,r,0)
  circ(p.x-240,p.y,r,t)
 end 
 if p.y<r then 
  circ(p.x-2,p.y+134,r,0) 
 	circ(p.x,p.y+136,r,t)
 end 
 if 136-p.y<r then 
  circ(p.x+2,p.y-134,r,0)
  circ(p.x,p.y-136,r,t)
 end 
end

function catface(x,y,s,f)
	tri(
		x-s/2,y-s,
		x-s/5,y-s*.5,
		x-s/1.3,y-s*.5,
		3)
	tri(
		x+s/2,y-s,
		x+s/5,y-s*.5,
		x+s/1.3,y-s*.5,
		3)
	tri(
		x-s/2,y-s*.9,
		x-s/5,y-s*.5,
		x-s/1.3,y-s*.5,
		4)
	tri(
		x+s/2,y-s*.9,
		x+s/5,y-s*.5,
		x+s/1.3,y-s*.5,
		4)
	elli(x,y,s,s*.8,2)
	elli(x,y-2,s-2,s*.8-4,3)
	
	-- mouth
	elli(x,y,s/2,s/3,2)
	elli(x-s/3,y,s/50,s/10,12)
	elli(x+s/3,y,s/47,s/8,12)
	rect(x-s/2,y-s/3,s+1,s/3,3)
	
	-- tonge
	local tp={x=x,y=y+s/3}
	local xd=-cos(t/5)
	for i=0,8 do
		circ(tp.x,tp.y,s/8,5)
		tp.x=tp.x+xd
		xd=xd*1.2
		tp.y=tp.y+2
	end
	--eyse
	elli(x-s/3,y-s/3,s/6,s/4,12)
	elli(x+s/3,y-s/3,s/6,s/4,12)
	
	local r={x=5,y=0}
	r=rot(r,ffts(f,f+10)*3)
	elli(x-s/3+r.x,y-s/3+r.y,s/12,s/12,15)
	elli(x+s/3-r.x,y-s/3-r.y,s/12,s/12,15)
	
end

function cat(x,y,s,f)
	y=y-abs(sin(t/5+f)*s/2)
	elli(x,y+s*2,s*1.5,s*2,2)
	elli(x,y+s*2.1,s*1.4,s*2,3)
	local s=fft(f+10,f+20)*10+s
	catface(x+sin(t/5)^3*20,y,s,f)
end

rd=0.05

function TIC()
	vbank(0)
	rcirc()
	p.x=(p.x+p.dx)%240
	p.y=(p.y+p.dy)%136
	local tmp=rot({x=p.dx,y=p.dy}, rd)
	p.dx=tmp.x p.dy=tmp.y
	if ffts(0,10)>0.5 then rd=-rd end
	vbank(1)
	cls()
	--y=ffts(10,15)
	local by=136-44+sin(t/10)*24
	cat(120-80,by+10,30,25)
	cat(120+80,by+10,30,35)
	cat(120,by,40,5)
	vbank(0)
	
	scroll.x=(sin(t/100+sin(t/90))*200)%240-120
	scroll.y=(sin(t/87+sin(t/96))*200)%240-120
	
	t=t+.3
end

function SCN(y)
	poke(0x3FF9,(scroll.x+ffts(y,y+10)*15//1))
	poke(0x3FFa,(scroll.y+ffts(y,y+10)*5//1))
end