-- pos: 0,0
local M=math
local mSin,mCos,mPi=M.sin,M.cos,M.pi
local mMax,mMin=M.max,M.min
local mTau=mPi*2
local LINES={}
local T=0
local PALS={
	{r=255,g=0,b=0},
	{r=0,g=255,b=0},
	{r=0,g=0,b=255},
}

function BDR(y)
	local bR=100+mSin(y*.03+T*.01)*100
	local bG=100+mSin(y*.02+T*.014)*100
	local bB=100+mSin(y*.026+T*.017)*100

	local v=LINES[y]
	if v then
	 local rgb=v.rgb
		local p=rgb.r/255
		local np=1-p
		setRgb(
			0,
			(rgb.r+bR)/2,
			(rgb.g+bG)/2,
			(rgb.b+bB)/2
		)
	else
		setRgb(0,bR,bG,bB)
	end
end


function TIC()
	cls(0)
	poke(0x3ffb,0)
	LINES={}

--[[
 local pal={r=100,g=100,b=60}
	local y0=(-T*.1)%20-10
	for i=0,10 do
		local wz=i/5-2
	 local wy=y0
		local y,h=proj(wy,wz)
		bar(y,wz,h/2,pal)
	end
--]]
	local nBigs=10
	for i=1,nBigs do
		local a=mTau*i/nBigs
		local y=mSin(a)*5
		local z=1+mSin(a)
		drawBars(y,z)
	end

	print("jtruk",209,129,15)
			
	T=T+1
end

function drawBars(y0,z0)
 local nBars=3
 local ym=y0+mSin(T*.01)*1
	for i=1,nBars do
	 local pal=PALS[1+i%#PALS]
	 local a=i*mTau/nBars+T*.03
		local wy=ym+mSin(a)
		local wz=z0+mCos(a)
		local y,h=proj(wy,wz)
		
	 bar(y,wz,h/2,pal)
	end
--	local y,_=proj(ym,0)
--	print("COPPERBAR",100,y,1)

	for y,l in pairs(LINES) do
		if l.z>z0 then
		 line(0,y,239,y,0)
		end
	end
end

function bar(y,z,h,pal)
	local h=h/2
	for i=-h,h do
	 local a=mPi*i/h
	 local v=.5+mCos(a)*.5
		setLine((y+i)//1,z,{
		 r=v*pal.r,g=v*pal.g,b=v*pal.b
		})
	end
end

function setLine(y,z,rgb)
	local l=LINES[y]
	if l and z<l.z then
		return
	end
	LINES[y]={z=z,rgb=rgb}
end

function setRgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r) poke(a+1,g) poke(a+2,b)
end

function proj(y,z)
 local zD=50/(3-z)
 zD=mMax(.1,mMin(zD,60))
 return 68+y*zD,zD
end