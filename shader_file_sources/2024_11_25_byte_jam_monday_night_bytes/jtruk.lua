-- Bytejam 20241125-jtruk
-- Thanks Reality & Polynomial
-- Greetz: Catnip, Pumpuli, HeNeArXn
-- And you :)

local M=math
local S,C,A,PI=M.sin,M.cos,M.abs,M.pi
local R=M.random
local TAU=PI*2
local T=0
local STEPS=nil
local STEPM=nil
local D1,D2=nil,nil
local SPIN=nil
local IMULT=nil
local TZMULT=nil

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function shuffle()
	vbank(0)
	local s=R()*TAU
	local s2=R()*TAU
	for i=1,15 do
	 local r=i/15*(127+S(s)*127)
		local g=i/15*(127+S(s+TAU*.33)*127)
		local b=i/15*(127+S(s+TAU*.67)*127)
		rgb(i,r,g,b)
	end
	STEPS=8+R(0,4)*4
	STEPM=1+R()*8
	D1=R()*2
	D2=R()*2
	SPIN=(R()-.5)*.1
	IMULT=(R()-.5)*.4
	TZMULT=(R()-.5)*.2
end

function TIC()
	if T%120==0 then
		shuffle()
	end
	
	vbank(1)
	cls()
	makeTexs()

	vbank(0)
	cls()
	local lastPP1,lastPP2=nil,nil
	for i=0,STEPS do
	 local a=i/STEPS*TAU*STEPM+T*SPIN
		local ca,sa=C(a),S(a)
		local x=ca*D1
		local y=sa*D1
		local z=(T*TZMULT+i*IMULT)%6-4
		local p1={x=x-ca*D2,y=y-sa*D2,z=z}
		local p2={x=x+ca*D2,y=y+sa*D2,z=z}
		if i>0 then
		 local t=i%4
			local pp1=proj(p1)
			local pp2=proj(p2)
			local lastPP1=proj(lastP1)
			local lastPP2=proj(lastP2)
			if pp1.z<0 and pp2.z<0 and lastPP1.z<0 and lastPP2.z<0 then
				drawQuad(pp1,lastPP1,pp2,lastPP2,t)
			end
		end
		
		lastP1,lastP2=p1,p2
	end

	vbank(1)
	poke(0x3ffb,0)
	cls()
	local txt="jtruk"
	print(txt,210,129,1)
	print(txt,209,128,12)
	
	T=T+1
end

function drawQuad(p1,p2,p3,p4,t)
	drawTri(p1,p2,p4,t,false)
	drawTri(p3,p4,p1,t,true)
end

function drawTri(p1,p2,p3,t,flip)
	local os1={x=t*32,y=0}
	local os2={x=os1.x+32,y=0}
	local os3={x=os1.x+32,y=32}
	local os4={x=os1.x,y=32}
	if not flip then
		s1,s2,s3=os1,os2,os4
	else
		s1,s2,s3=os3,os4,os1
	end

	ttri(
		p1.x,p1.y,
		p2.x,p2.y,
		p3.x,p3.y,
		s1.x,s1.y,
		s2.x,s2.y,
		s3.x,s3.y,
		2,
		0,
		p1.z,p2.z,p3.z
	)
end

function makeTexs()
 for y=0,32 do
	 for x=0,127 do
		 local c=1+(7+S(y/8+x/4+T*.1)*7)
			pix(x,y,c)
		end
	end
end

function proj(p)
	local pz=(p.z-4)
	local zD=3/pz
	return {
		x=120+p.x*zD*80,
		y=68+p.y*zD*80,
		z=pz,
	}
end