-- ByteJam 20250707 - jtruk
-- Greetz: Aldroid (host) Lynn (DJ)
-- Canmom,Pumpuli,Weatherman,Doooop

local T=0
local M=math
local SIN,COS=M.sin,M.cos
local MAX,MIN=M.max,M.min
local RAND=M.random
local PI=M.pi
local TAU=PI*2
local PS={}
local R_MXI,R_MYI,R_MZI=0,0,0
local R_RX,R_RY,R_RZ=0,0,0
local R_RR=0
local R_PT=0

function shuffle()
	vbank(0)
	setRGBs()
	vbank(1)
	setRGBs()
	R_MXI=RAND(100,1000)/1000
	R_MYI=RAND(100,1000)/1000
	R_MZI=RAND(100,1000)/1000
	R_RX=(50-RAND(10,100))/2000
	R_RY=(50-RAND(10,100))/2000
	R_RZ=(50-RAND(10,100))/2000
	R_RR=RAND(10,100)/10000
	R_PT=RAND(10,100)/10000
end

function setRGBs()
	local rm,gm,bm=RAND(),RAND(),RAND()
	for i=1,15 do
		local v=255*i/15
		rgb(i,v*rm,v*gm,v*bm)
	end
end

function BOOT()
	vbank(0)
	cls()
end

function TIC()
	if T%80==0 then
		shuffle()
	end
	poke(0x3ffb,0)

	for v=0,1 do
		vbank(v)
		if RAND(0,40)==0 then
		 cls()
		end
	
	 local r=.5+SIN(T*R_RR+v)*.4
	 local rX=T*R_RX
	 local rY=T*R_RY
	 local rZ=T*R_RZ
		local nDots=100
		for i=0,nDots do
		 local a=TAU*i/nDots
		 local p={
		 	x=SIN(R_MXI*i+a)*r,
		  y=COS(R_MYI*i+a)*r,
		  z=2-SIN(i*R_MZI+T*R_PT)*2,
		 }
			
			p.y,p.z=rot(p.y,p.z,rX)
			p.x,p.z=rot(p.x,p.z,rY)
			p.x,p.y=rot(p.x,p.y,rZ)
		 p=proj(p)
	
	  local zs=MAX(0,MIN(1,.01/(p.z)))
	
	  local c=1+zs*15
	  local sz=1+zs*5
	
	  circ(p.x,p.y,sz,c)
	 end
	end
	
	print("jtruk",210,130,1)
	print("jtruk",209,129,7)
	
 T=T+1
end

function proj(p)
 local dz=1/(30-p.z*20)
 return {
  x=120+p.x//dz,
  y=68+p.y//dz,
  z=dz,
 }
end

function rot(a,b,r)
	local s,c=SIN(r),COS(r)
	return s*a+c*b,c*a-s*b
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g) poke(a+2,b) 
end