-- Outline ByteJam (jtruk)
-- 2024-05-10
-- Greetz to Jammers:
-- Alice, Aldroid, Gasman
-- Thx Zeno4ever + Havoc
-- Hope y'all have a most Outliney
-- party. I'm sending y'all flowers!
-- Prayers for the venue power+internet

local M=math
local S,C=M.sin,M.cos
local A=M.abs
local PI=M.pi
local TAU=PI*2
local T=0
local RAND=M.random
local LOOPS={}


function rollDice()
	LOOPS={}
	for i=0,15 do
		table.insert(LOOPS,{
			petals=RAND(2,6),
			mult=RAND(1,10),
			rb=RAND(20,100),
			ra=RAND(20,100),
			gb=RAND(20,100),
			ga=RAND(20,100),
			bb=RAND(20,100),
			ba=RAND(20,100),
		 aSpin=2*(RAND()-.5),
		})
	end
	BG1R=RAND(255)
	BG1B=RAND(255)
	BG1G=RAND(255)
	BG2R=RAND(255)
	BG2B=RAND(255)
	BG2G=RAND(255)
	OFS=RAND()*10000
end


function BDR(y)
 vbank(0)
	if y<4 or y>139 then
	 setRGB(0,0,0,0)
	else
	 local linem=.5+S(y*.03+T*.02)*.5
	 local line1m=1-linem
	 local r=linem*BG1R+line1m*BG2R
	 local g=linem*BG1G+line1m*BG2G
	 local b=linem*BG1B+line1m*BG2B
	 setRGB(0,r,g,b)
	end
	
	vbank(1)
	for c=1,14 do
	 local loop=LOOPS[c]
		local r=loop.rb+(.5+.5*S(y*.012+c*.2+T*.05))*loop.ra
		local g=loop.gb+(.5+.5*S(y*.02+c*.3+T*.03))*loop.ga
		local b=loop.bb+(.5+.5*S(y*.017+c*.5-T*.04))*loop.ba
		setRGB(c,r,g,b)
	end
	setRGB(15,60,60,60)
end

function TIC()
	cls()

	if T%100==0 then
		rollDice()
	end

 local xc0,yc0=nil,nil
	local dSize=.8+S(T*.08)*.4
	for i=15,1,-1 do
		local def=LOOPS[i]
		local rz=.5+ffts(i*10)*.5
		local r=(10+i*dSize*10)*rz
		local c=(i*def.mult)%14+1
		local a=T*(.02*def.aSpin)
		local xc=120+S(T*.04+i*.1+OFS)*20
		local yc=68+S(T*.03+i*.08+OFS)*20
		drawLoop(xc,yc,r,c,def.petals,a)
		if xc0==nil then
			xc0,yc0=xc,yc
		end
	end

	vbank(0)
	cls()
	local nRings=15
	local nDots=10
	for ring=1,nRings do
		local r=10+ring*10
		local ad=T*S(OFS)*.03+ring+(OFS*ring)
		for i=1,nDots do
		 local a=i/nDots*TAU+ad
			local x=xc0+S(a)*r
			local y=yc0+C(a)*r
			local fftL=ring*8
			local fftH=ring*8+7
			local r=4+ffts(fftL,fftH)*8
			circ(x,y,r,ring)
		end
		local r=((15-ring)/nRings)*S(OFS)
		local g=((15-ring)/nRings)*S(OFS*2)
		local b=((15-ring)/nRings)*S(OFS*3)
		setRGB(ring,r*255,g*255,b*255)
	end

	print("jtruk",209,129,12)
	print("jtruk",208,128,1)
	print("<3 Outline",3,129,12)
	print("<3 Outline",2,128,1)
		
	vbank(1)
	T=T+1
end

function drawLoop(xc,yc,r,c,steps,dr)
	for i=0,steps do
		local a=TAU/steps*i+dr
		local da=.4
		drawPetal(xc,yc,r,a,da,10,c)
	end
end

function drawPetal(xc,yc,r,ca,da,steps,c)
 local xl,yl=nil,nil
 local xl2,yl2=nil,nil
 local i=0
	for s=-steps,steps do
	 local dstep=s/steps
	 local a=ca+da*dstep
		local sr=C(dstep)*r
  local x=xc+S(a)*sr
  local y=yc+C(a)*sr
  local x2=xc+S(a)*sr*.97
  local y2=yc+C(a)*sr*.97
		if xl~=nil then
	  tri(xc,yc,xl,yl,x,y,15)
	  tri(xc,yc,xl2,yl2,x2,y2,c)
		end
	 xl,yl=x,y
	 xl2,yl2=x2,y2
		i=i+1
	end
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end