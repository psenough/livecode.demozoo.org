-- Bytejam 2025/06/02
-- Looking forward to NOVA 2025!
-- Thanks Reality (Host) and RaccoonViolet (Mix)
-- Greetz: Lex, Canmon, Weatherman115, Aatch-you!

local T=0
local M=math
local Msin,Mcos=M.sin,M.cos
local Matan2=M.atan2
local Mtau=M.pi*2

function rgb(i,r,g,b)
 local a=16320+i*3
 poke(a,r) poke(a+1,g) poke(a+2,b)
end

function TIC()
 local sz=(.1+ffts(0)*.75)*6

	vbank(0)
	cls()
	for i=1,15 do
		local r=(i/15)*64
		local g=(1-(i/15))*120
		local b=(i/15)*255
		rgb(i,r,g,b)
	end
	local shx=Msin(T*.01)*20
	local shy=Msin(T*.004)*20
	for y=-68,68 do
		for x=-120,120 do
		 local d=(T*20+x^2+y^2)^.5
			local d=.5+Msin(d/2)*.5
		 local c=T*.02-d+(Matan2(x,y+120))/(Mtau)
			c=8+Msin(c)*7
		 pix(120+x,68+y,c)
		end
	end

	vbank(1)
	cls()
	for i=1,15 do
		local r=(i/15)*255
		local g=(i/15)*32
		local b=(i/15)*64
		rgb(i,r,g,b)
	end

	circ(120,68,26,12)
	circ(120,68,24,15)
	circ(120,68,22,12)
	circ(120,68,20,0)

	for i=1,15 do
	 local sh=i*.01
	 local rx=T*.01+Msin(sh+T*.003)
	 local ry=T*.01+Msin(sh+T*.004)
	 local rz=T*.01+Msin(sh+T*.005)
	 local sz=.8+Msin(i*.1+T*.01)*.4
		local c=15-(i/5)*3
		doLines(0,0,0,sz,rx,ry,rz,c)
	end

	T=T+1
end

function doLines(x1,y1,z1,sz,rx,ry,rz,c)
	for _,l in ipairs(getLines()) do
  local dx,dy,dz=l.l*l.dx*sz,l.l*l.dy*sz,0
		local x2,y2,z2=x1+dx,y1+dy,z1+dz

		if not l.h then
		 xr1,yr1,zr1=rot3(x1,y1,z1,rx,ry,rz)
		 xr2,yr2,zr2=rot3(x2,y2,z2,rx,ry,rz)
		 xd1,yd1,zd1=proj(xr1,yr1,zr1)
		 xd2,yd2,zd2=proj(xr2,yr2,zr2)
		 line(xd1,yd1,xd2,yd2,c)
		end
		x1,y1,z1=x2,y2,z2
	end
end

function rot3(x,y,z,rx,ry,rz)
	y,z=rot(y,z,rx)
	x,z=rot(x,z,ry)
	x,y=rot(x,y,rz)
	return x,y,z
end


function rot(a,b,r)
 local s,c=Msin(r),Mcos(r)
	return a*c+b*s,a*s-b*c
end

function proj(x,y,z)
	local zD=80/(z-100)
	return 120+x/zD,68+y/zD,zD
end

function getLines()
	return {
		{h=true,dx=-1,dy=0,l=80},
		{h=true,dx=0,dy=1,l=20},
		{dx=0,dy=-1,l=40},
		{dx=1,dy=0,l=48},
		{dx=0,dy=1,l=32},
		{dx=1,dy=0,l=8},
		{dx=0,dy=1,l=8},
		{dx=-1,dy=0,l=16},
		{dx=0,dy=-1,l=32},
		{dx=-1,dy=0,l=32},
		{dx=0,dy=1,l=32},
		{dx=-1,dy=0,l=8},
		{h=true,dx=1,dy=0,l=100},
		{h=true,dx=0,dy=-1,l=40},
		{dx=1,dy=0,l=16},
		{dx=.5,dy=1,l=32},
		{dx=.5,dy=-1,l=32},
		{dx=1,dy=0,l=8},
		{dx=.5,dy=1,l=32},
		{dx=1,dy=0,l=8},
		{dx=.5,dy=1,l=8},
		{dx=-1,dy=0,l=16},
		{dx=-.5,dy=-1,l=32},
		{dx=-.5,dy=1,l=32},
		{dx=-1,dy=0,l=8},
		{dx=-.5,dy=-1,l=32},
		{dx=-1,dy=0,l=8},
		{dx=-.5,dy=-1,l=8},
	}
end