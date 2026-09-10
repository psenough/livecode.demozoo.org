-- ByteJam jtruk 20251020
-- Thanks: VioletRaccoon (host), P3RC (mix)
-- JamGreetz:  aldroid canmom immibis
--  littletheremin marex weatherman115
-- OtherGreetz: You!

local T=0
local PI,C,S=math.pi,math.cos,math.sin
local R=math.random
local TAU=PI*2
local NSLABS=6
local SPLIT1,SPLIT2

function BOOT()
	cls()
end

function shuffle()
	NSLABS=R(3,8)
	SPLIT1=R()*.2
	SPLIT2=R()*.2
end

function BDR(y)
 vbank(0)
	poke(0x3FF9,S(y*.1+T*.04)*5)
end

function colours(csh)
	rgb(0,0,0,0)
	local ofs1=T*.01
	local ofs2=T*.007
	local ofs3=T*.004
	local spread=50
	for c=0,14 do
		local r=180+75*S(TAU*c/spread)
		local g=180+75*S(TAU*c/spread+TAU*SPLIT1*ofs2)
		local b=180+75*S(TAU*c/spread+TAU*SPLIT2*ofs3)
		local i=1+(c+csh)%15
		rgb(i,r,g,b)
	end
end


function TIC()
	if T%200==0 then
	 shuffle()
	end

	vbank(0)
	colours(T)
 draw(T,T)
 draw(T-4,T-3)

	vbank(1)
	local txt="JTRUK"
	print(txt,210,130,10)
	print(txt,209,129,14)

	T=T+1
end

function draw(t,csh)
	local xc=S(t*.025)*.4
	local yc=S(t*.015)*.4
	for i=0,NSLABS do
		local shi1=S(t*.02+i*.1)
		local shi2=S(t*.03+i*.2)
		local sho1=S(t*.025+i*.3)
		local sho2=S(t*.015+i*.2)

		local ia1=TAU*i/NSLABS+t*.01+shi1
		local ia2=TAU*i/NSLABS+t*.01+shi2
		local oa1=ia1+sho1
		local oa2=ia2+sho2
		local id=.2+S(t*.02)
		local od=.9+S(t*.02)
		local xi1,yi1=proj(
			xc+C(ia1)*id,
			yc+S(ia1)*id
		)
		local xi2,yi2=proj(
			xc+C(ia2)*id,
			yc+S(ia2)*id
		)
		local xo1,yo1=proj(
			xc+C(oa1)*od,
			yc+S(oa1)*od
		)
		local xo2,yo2=proj(
			xc+C(oa2)*od,
			yc+S(oa2)*od
		)

		local c=1+(i*2+csh)%14
		tri(xi1,yi1,xo1,yo1,xo2,yo2,c)
		tri(xo2,yo2,xi2,yi2,xi1,yi1,c)
	end
end

function proj(x,y)
	local sc=80
	return
		120+x*sc,
		68+y*sc
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r) poke(a+1,g) poke(a+2,b)
end