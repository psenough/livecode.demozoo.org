-- Bytejam 20260511-jtruk
-- Thanks...
--  Host: RaccoonViolet DJ: Caelbun
-- Greetz...
--  Canmom borisvanschooten Lex
--  MutzBunny totetmatt ANDYOU

local T=0
local S=math.sin
local C=math.cos
local A=math.atan2
local ABS=math.abs
local R=math.random
local PI=math.pi
local MAX,MIN=math.max,math.min
local TAU=2*PI

local SH_SQUARE={
	close=true,
	ps={
		{x=-1,y=-1},
		{x=-1,y=1},
		{x=1,y=1},
		{x=1,y=-1},
	}
}

local SH_TRI={
	close=true,
	ps={
		{x=0,y=-1},
		{x=S(TAU*.33),y=-C(TAU*.33)},
		{x=S(TAU*.67),y=-C(TAU*.67)},
	}
}

function makePentaPS()
	local ps={}
	for i=0,5 do
		local a=i/5*TAU
		ps[#ps+1]={
			x=C(a),
			y=S(a),
		}
	end
	return ps
end

function makeStarPS()
	local ps={}
	for i=0,5 do
		local a=(i*2)/5*TAU
		ps[#ps+1]={
			x=C(a),
			y=S(a),
		}
	end
	return ps
end

local SH_PENTA={
	close=true,
	ps=makePentaPS()
}

local SH_STAR={
	close=true,
	ps=makeStarPS()
}

local OBJS={}

function createAll()
	OBJS={}

	math.randomseed(T)

	local count=10
	for i=0,count-1 do
		OBJS[#OBJS+1]={
			sh=getRandomShape(),
			x=R(10,230),
			y=R(10,126),
			c=1+R(0,5)*2,
			rz=R(),
			dx=R(-100,100)*0.015,
			dy=R(-100,100)*0.015,
			drz=R(-50,50)*0.001,
		}
	end
end

function getRandomShape()
	local shapes={
		SH_SQUARE,SH_TRI,
		SH_PENTA,SH_STAR,
	}
	return shapes[R(1,#shapes)]
end

function BOOT()
	setRGB(0,0,0,0)
	setRGB2(1,255,0,0)
	setRGB2(3,0,255,0)
	setRGB2(5,0,0,255)
	setRGB2(7,255,255,0)
	setRGB2(9,0,255,255)
	setRGB2(11,255,0,255)
end

function	setRGB2(i,r,g,b)
	local f=.5
	setRGB(i,r,g,b)
	setRGB(i+1,r*f,g*f,b*f)
end

function TIC()
	vbank(0)
	cls()

	if T%3000==0 then
		createAll()
	end

	math.randomseed(T//20)
	
	for i,obj in ipairs(OBJS) do
		obj.x=(obj.x+obj.dx)%240
		obj.y=(obj.y+obj.dy)%136
		obj.rz=obj.rz+obj.drz
		drawObj(obj,obj.c+1,0,0,6)
		drawObj(obj,obj.c,3,3,3)
	end
	
	vbank(1)
	cls()
	print("jtruk",206,129,15)
	print("jtruk",205,128,12)
end

function drawObj(obj,c,dx,dy,th)
	local shape,xc,yc=obj.sh,obj.x,obj.y
	local p0x,p0y
	local lpx,lpy
	local mul=20
	for i,p in ipairs(shape.ps) do
		local px,py=p.x*mul+dx,p.y*mul+dy
		px,py=rot(px,py,obj.rz)

		px=px+xc+R(-1,1)
		py=py+yc+R(-1,1)

		if lpx==nil then
			p0x,p0y=px,py
		else
			drawLine(px,py,lpx,lpy,c,th)
		end

		lpx,lpy=px,py
	end

	if shape.close then
		drawLine(lpx,lpy,p0x,p0y,c,th)			
	end
		
	T=T+1
end

function drawLine(x0,y0,x1,y1,c,th)
	local a=A(x1-x0,y1-y0)
	local al=a+PI/4
	local ah=a-PI/4
	local dlx=S(al)*th
	local dly=C(al)*th
	local dhx=S(ah)*th
	local dhy=C(ah)*th
	local sq0x,sq0y=x0-dlx,y0-dly
	local sq1x,sq1y=x0-dhx,y0-dhy
	local sq2x,sq2y=x1+dlx,y1+dly
	local sq3x,sq3y=x1+dhx,y1+dhy

	tri(sq0x,sq0y,sq1x,sq1y,sq2x,sq2y,c)
	tri(sq2x,sq2y,sq3x,sq3y,sq0x,sq0y,c)
end

function rot(a,b,r)
	return S(r)*a-C(r)*b,C(r)*a+S(r)*b
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end