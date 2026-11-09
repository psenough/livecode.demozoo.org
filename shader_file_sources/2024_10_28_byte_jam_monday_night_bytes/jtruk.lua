-- Bytejam 2024-10-28 (Hallowe'en)
-- Thanks: Havoc, Alkama
-- Greetz: Enfys, Suule, Pumpuli
-- And you-ooo-woo-oo

local M=math
local S,C=M.sin,M.cos
local PI,R=M.pi,M.random
local MIN,MAX=M.min,M.max

local SRCW=64
local SRCH=64
local T=0

function colour()
	vbank(1)
	local int=.8+S(T*.03)*.2
	for i=1,15 do
		local v=(i/15)*int
		rgb(i,127+v*127,0,32+v*32)
	end

	vbank(0)
	local int=.6+S(T*.03+PI)*.4
	rgb(0,0,0,0)
	for i=1,15 do
		local v=(1-i/15)*int
		rgb(i,127+v*127,0,0)
	end
end

function drawGhostie(xc,yc,w,h)
	local ew=w*.3
	local eh=h*.4
	local exc=xc
	local eyc=eh
	elli(exc,eyc,ew,eh,1)
	circ(exc-ew*.5,eyc,4,0)
	circ(exc+ew*.5,eyc,4,0)

	local w=(.4+S(T*.028)*.15)*ew
	local h=(.2+S(T*.05)*.25)*eh
	elli(exc,eyc+eh*.5,w,h,0)
end

function TIC()
	poke(0x3ffb,0)
	colour()

	cls()
	vbank(0)
	drawGhostie(32,32,SRCW,SRCH)
	
	vbank(1)
	cls()
	local s1={x=0,y=0}
	local s2={x=SRCW,y=0}
	local s3={x=SRCW,y=SRCH}
	local s4={x=0,y=SRCH}

	for i=0,10 do
		local m=1+(i%10)/10
		local tr={
			x=i^5,
			y=i^7+i^3,
			z=i^9,
		}
		
		tr.x=tr.x+S(i+(i+3)*T*.001)*200
		tr.y=tr.y-m*T*.6
		tr.z=tr.z+(i+T*.05)
	
		tr.x=tr.x%300-30
		tr.y=tr.y%200-40
		tr.z=30+S(tr.z)*16

		local dp=tr.z
		local d1={x=-dp,y=-dp}
		local d2={x=dp,y=-dp}
		local d3={x=dp,y=dp}
		local d4={x=-dp,y=dp}
		local r=S(i+T*.02)
		local r1=r+S(T*.1)*.3
		local r2=r+S(T*.08)*.3
		local r3=r+S(T*.12)*.3
		local r4=r+S(T*.07)*.3
		d1=trans(rotZ(d1,r1),tr)
		d2=trans(rotZ(d2,r2),tr)
		d3=trans(rotZ(d3,r3),tr)
		d4=trans(rotZ(d4,r4),tr)

		local c=1+i%15
		poke4(0x3ff0*2+1,c)
		blitQuad(s1,s2,s3,s4,d1,d2,d3,d4,0)
	end

	print("jtruk",210,129,2)
	print("jtruk",209,128,5)

	vbank(0)
	cls()
	
	local z=1.5+S(T*.04)*.5
	local s1={x=240,y=0}
	local s2={x=0,y=0}
	local s3={x=0,y=136}
	local s4={x=240,y=136}
	local d1={x=120-120*z,y=68-68*z}
	local d2={x=120+120*z,y=68-68*z}
	local d3={x=120+120*z,y=68+68*z}
	local d4={x=120-120*z,y=68+68*z}
	blitQuad(s1,s2,s3,s4,d1,d2,d3,d4,0)
		
	T=T+(.7+S(T*.06)*.3)
end

function blitQuad(s1,s2,s3,s4,d1,d2,d3,d4,chroma)
	blitTri(s1,s2,s3,d1,d2,d3,chroma)
	blitTri(s3,s4,s1,d3,d4,d1,chroma)
end

function blitTri(s1,s2,s3,d1,d2,d3,chroma)
	ttri(
		d1.x,d1.y,
		d2.x,d2.y,
		d3.x,d3.y,
		s1.x,s1.y,
		s2.x,s2.y,
		s3.x,s3.y,
		2,
		chroma
	)
end

function rotZ(p,a)
	p.x,p.y=rot(p.x,p.y,a)
	return p
end

function rot(a,b,r)
	return a*C(r)-b*S(r),
		a*S(r)+b*C(r)
end

function trans(p,t)
	p.x=p.x+t.x
	p.y=p.y+t.y
	return p
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end