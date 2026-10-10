-- Thanks reality404 + polynomial
-- Nods: weatherman115 g33kou
-- littletheremin catnip Gasman
-- zool suule and youle.

local T=0
local M=math
local S,C,PI=M.sin,M.cos,M.pi
local TAU=PI*2
local R=M.random

local O={}

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end

function TIC()
 poke(0x3ffb,0)
	if T==0 then
		O=make()
	end
	
	if T%100==0 then
		vbank(1)
		cls()
	end

	if T%160==0 then
		vbank(0)
		local r0=64+R(0,191)
		local g0=64+R(0,191)
		local b0=64+R(0,191)
		local r1=64+R(0,191)
		local g1=64+R(0,191)
		local b1=64+R(0,191)
		rgb(0,0,0)
		for i=1,15 do
		 local v=i/15
			rgb(i,r0*v,g0*v,b0*v)
		end
		vbank(1)
		for i=1,15 do
		 local v=i/15
			rgb(i,r1*v,g1*v,b1*v)
		end
	end
	
	vbank(0)
	cls()
	for i=0,14 do
	 local shI=i*TAU/15
		drawSeg(T,O,S(T*.03)*1,S(T*.05)*1,shI,i+1,0)
	end
	
	vbank(1)
	cls()
	local x1,y1=0+S(T*.012)*20,0+S(T*.014)*20
	local x2,y2=240+S(T*.010)*20,136+S(T*.017)*20
	local x1,x2=240-x1,240-x2
	local y1,y2=240-y1,240-y2
	ttri(
		0,0,240,0,0,136,
		x1,y1,x2,y1,x1,y2,
		2,
		0
	)
			
	ttri(
		240,0,240,136,0,136,
		x2,y1,x2,y2,x1,y2,
		2,
		0
	)

	vbank(1)
	print("JTRUK",209,131,5)
	print("JTRUK",208,130,11)

	T=T+1
end

function make()
	o=newSeg(function(t,a)
		return t,0
		end
	)
	local lastSeg=o

	for i=0,5 do
	 local shI=i*TAU
		for j=0,5 do
		 seg=newSeg(function(t,a)
		 	return a+shI+j+t*.003,1
		 	end
		 )
			addChild(lastSeg,seg)
			lastSeg=seg
		end
	end
	return o
end

function newSeg(fn)
	return {fn=fn,c={}}
end

function addChild(p,seg)
 p.c[#p.c+1]=seg
end

function drawSeg(t,p,ox,oy,oa,rgb,i)
 local x,y=proj(ox,oy,i)
	circ(x,y,1,7.5+S(rgb)*7.5)
	for _,c in ipairs(p.c) do
  local a,l=c.fn(t,oa)
	 x=ox+S(a)*l
	 y=oy+C(a)*l
		drawSeg(t,c,x,y,a,rgb,i+1)
	end
end

function proj(x,y,z)
 local dZ=5/(5-z)
	return	120+x/dZ*10,68+y/dZ*10
end
