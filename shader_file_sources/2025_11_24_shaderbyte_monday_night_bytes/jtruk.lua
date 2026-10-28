-- Bytejam 20251124 - jtruk
-- Thanks: Aldroid (host)
--         i.v. (vcvrack)
-- Greets: Littletheremin, Enfys
-- 								G33kou, Boris

local T=0
local M=math
local R,S,C,PI=M.random,M.sin,M.cos,M.pi
local TAU=2*PI
local ABS=M.abs
local FFT=nil
local RB,GB,BB

function BOOT()
	resetFFT()
	colours(1,1,1)
end

function colours(r1,g1,b1)
	local c0=0
	local c1=255
	local c2=220
	local c3=180
	local c0b=60
	local c1b=255
	local c2b=220
	local c3b=170
	local rgbs={
		[1]={c1,c0,c0},
		[2]={c0,c1,c0},
		[3]={c2,c2,c0},
		[4]={c0,c0,c1},
		[5]={c2,c0,c2},
		[6]={c0,c2,c2},
		[7]={c3,c3,c3},
		[8]={c0b,c0b,c0b},
		[9]={c1b,c0b,c0b},
		[10]={c0b,c1b,c0b},
		[11]={c2b,c2b,c0b},
		[12]={c0b,c0b,c1b},
		[13]={c2b,c0b,c2b},
		[14]={c0b,c2b,c2b},
		[15]={c3b,c3b,c3b},
	}
	RB,GB,BB=r1*255,g1*255,b1*255
	for i,rgb in pairs(rgbs) do
		setRGB(i,rgb[1]*r1,rgb[2]*g1,rgb[3]*b1)
	end
end

local R1,R2,R3
local T1,T2,T3
local BOUNCE
local SP
local SPINDIR=1
local POINTS
local RDIV

function shuffle()
	R1=R(10,20)
	R2=R(10,20)
	R3=R(10,20)
	T1=R(2,15)
	T2=R(2,15)
	T3=R(2,15)
	BOUNCE=40
	SPINDIR=-SPINDIR
	SP=R(1,6)*SPINDIR
	POINTS=R(1,6)
	RDIV=R(1,5)
end

function BDR(y)
	vbank(0)
	if y>=4 and y<=139 then
		local i=ABS(y-72)/70
		setRGB(0,RB*i,GB*i,BB*i)
	else
		setRGB(0,0,0,0)
	end
end

function TIC()
	vbank(0)
	if T%100==0 then
		shuffle()
		resetFFT()
		colours(R(),R(),R())
	end

	cls()
	updateFFT()
 drawRing(60,68,1,R1,T1,BOUNCE,T*.01*SP)
 drawRing(180,68,2,R2,T2,BOUNCE,T*.012*SP)
	memcpy(0x4000,0,16320)
	cls()

	drawRing(120,68,4,R3,T3,BOUNCE,T*.008*SP)
--	print("BEEP BEEP",72,64,8,false,2)
	copyIn(0,120,60,120)
	
	vbank(1)
	print("JTRUK",208,128,15)
	T=T+1
end

function	resetFFT()
	local samples=50
 FFT={}
 for s=0,samples-1 do
		FFT[s]=1
 end
end

function updateFFT()
 for s=0,#FFT do
  local newFFT=ffts(s)
  if newFFT>FFT[s] then
			FFT[s]=newFFT
		else
		 FFT[s]=FFT[s]*.8
  end
	end
end

function drawRing(xc,yc,c,r,rthick,bounce,ao)
	local segs=#FFT
	local lastA=nil
	for s=0,segs do
		-- smoothing
		local f=(FFT[(s-1)%#FFT]+FFT[s]+FFT[(s+1)%#FFT])/3
		local sa=POINTS*s*TAU/(segs)
		local r1=r+f*bounce+S(sa)*r/RDIV
		local r2=r1+rthick

	 local a=ao+TAU*(s/segs)
		local xi,yi=xc+S(a)*r1,yc+C(a)*r1
		local xo,yo=xc+S(a)*r2,yc+C(a)*r2
		if s>0 then
		 quad(lastXi,lastYi,lastXo,lastYo,xo,yo,xi,yi,c)
		end
		lastXi,lastYi=xi,yi
		lastXo,lastYo=xo,yo
	end
end

function quad(x1,y1,x2,y2,x3,y3,x4,y4,c)
	tri(x1,y1,x2,y2,x3,y3,c)
	tri(x3,y3,x4,y4,x1,y1,c)
end

function copyIn(sx1,sx2,dx,w)
	for y=0,135 do
		for x=0,w-1 do
		 local o1=sx1+x+y*240
		 local o2=sx2+x+y*240
			local p0=pix(dx+x,y)
		 local p1=peek4(0x8000+o1)
		 local p2=peek4(0x8000+o2)
			pix(dx+x,y,p0+p1+p2)
		end
	end
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end