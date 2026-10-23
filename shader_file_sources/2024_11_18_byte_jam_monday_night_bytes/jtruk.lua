-- bytejam-20241118-jtruk
-- Thx: Reality / Pixel
-- Greetz: Enfys, Pumpuli, Aldroid!
-- AAAAAAAnd YOU

local M=math
local PI,S,C,ATAN=M.pi,M.sin,M.cos,M.atan2
local MIN,MAX=M.min,M.max
local TAU=PI*2
local T=0

function BOOT()
	cls()
end

function BDR(y)
	vbank(0)
--	poke(0x3ff9,S(y*.04)*20)
--	poke(0x3ffa,S(y*.03)*20)
	rgb(0,0,0,0)

	for i=0,14 do
		local r=127+S(i/15+y*.03)*127
		local b=127+S(i/15+y*.02)*127
		rgb(1+((14-i)%14),r,0,b)
	end
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end


function TIC()
 vbank(0)
	memcpy(0x8000,0,16320)

	vbank(1)
	memcpy(0,0x8000,16320)

	vbank(0)
 cls()
	feedback()
 local c=1+(T%15)
 local a=0--T*.02
-- box(120,68,10,5,c,a)
	circb(120,68,3,c)
	if T%100<30 then
		print("JAM",105,68,0,true,2)
	end

	vbank(1)
	cls()

	T=T+1
end


function box(xc,yc,w,h,c,a)
 local cr=getCorners(xc,yc,w,h,a)
 line(cr.x1,cr.y1,cr.x2,cr.y2,c)
 line(cr.x2,cr.y2,cr.x3,cr.y3,c)
 line(cr.x3,cr.y3,cr.x4,cr.y4,c)
 line(cr.x4,cr.y4,cr.x1,cr.y1,c)
end

function getCorners(xc,yc,w,h,a)
	local a1=ATAN(-w,-h)+a
	local a2=ATAN(w,-h)+a
	local a3=ATAN(w,h)+a
	local	a4=ATAN(-w,h)+a
	return {
  x1=xc+C(a1)*w,
  y1=yc+S(a1)*w,
  x2=xc+C(a2)*w,
  y2=yc+S(a2)*w,
  x3=xc+C(a3)*w,
  y3=yc+S(a3)*w,
  x4=xc+C(a4)*w,
 	y4=yc+S(a4)*w,
	}
end

function feedback()
	local a=S(T*.01)*TAU
	local sz=1+S(T*.02)*0.01
	local w,h=68*sz,68*sz
--	local cr=getCorners(120+S(T*.11)*4,68+S(T*.09)*4,w,h,a)
	local cr=getCorners(120,68,w,h,a)
	ttri(
	 120-68,68-68,120+68,68-68,120+68,68+68,
 	cr.x1,cr.y1,cr.x2,cr.y2,cr.x3,cr.y3,
		2
	)
 ttri(
	 120+68,68+68,120-68,68+68,120-68,68-68,
	 cr.x3,cr.y3,cr.x4,cr.y4,cr.x1,cr.y1,
		2
	)
end