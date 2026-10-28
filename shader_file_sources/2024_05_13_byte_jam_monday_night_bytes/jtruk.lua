-- jtruk
-- Greetz:
-- ToBach, Pumpuli
-- Catnip, Vurpo,
-- Polynomial and Reality!
-- (And You) (And You)

local M=math
local S,C,A=M.sin,M.cos,M.atan2
local ABS,PI=M.abs,M.pi
local TAU,MIN,MAX=PI*2,M.min,M.max
local R=M.random

T=0

function TIC()
 local xc=120
 local yc=35+S(T*.023)*10
 local wob1=.15+S(T*.01)*.1
 local wob2=.15+S(T*.015)*.1
 local dy=30
 local dy2=dy*2
 local dx=140
 local dx2=dx*2
	vbank(0)
 cls(1)
 for y=-dy,dy do
	 for x=-dx,dx do
		 local c=2+((y+dy)/dy2)*13
			local h=y*(.6+S(x*.02+T*.005)*.5)
			local xd=xc
				+x
				+y*wob2
			local yd=yc
				+h
				+x*wob1
				+S(x*.01+T*.04)*10
				+S(x*.1+T*.2)*5
			if(R()>0.85) then
				pix(xd,yd,c)
			end
		end
	end
	setAurRGBs()
 reflect()
 
 vbank(1)
	setRGB(1,0,0,0)
 elli(20,100,80,30,1)
 elli(-20,90,90,30,1)
 elli(220,110,80,30,1)
 elli(280,80,90,30,1)
 rect(0,102,240,40,0)
 reflect()
	print("jtruk",208,128,15)
	
	T=T+1
end

function setAurRGBs()
	local cstops={
		{i=0,r=255,g=0,b=0},
		{i=5,r=0,g=255,b=0},
		{i=9,r=255,g=0,b=255},
		{i=13,r=0,g=0,b=255},
	}
	
	local int=.5+S(T*.02)*.5

	setRGB(0,0,0,0)
	local br,bg,bb=20,20,60
	setRGB(1,br,bg,bb)
 local lc=nil
	for i,c in ipairs(cstops) do
	 if i>1 then
		 for ic=lc.i,c.i do
			 local iv=i/15
				local mul=int
			 local p=1-((ic-lc.i)/(c.i-lc.i))
				local r=lerp(p,lc.r,c.r)*mul
				local g=lerp(p,lc.g,c.g)*mul
				local b=lerp(p,lc.b,c.b)*mul
				r=r+br*(1-mul)
				g=g+bg*(1-mul)
				b=b+bb*(1-mul)
				setRGB(2+ic,r,g,b)
			end
		end
		lc=c
	end
end

function reflect()
	for y=0,35 do
	 local dy=100+y
		local sy=100-y*2
		memcpy(dy*120,sy*120,120)
	end
end

function lerp(p,v0,v1)
	local sp=v1-v0
	return p*v0+(1-p)*v1
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

