-- ByteJam 20241015 / jtruk
-- Greetz:
-- Vurpo, Stormcaller (thx!)
-- Muffintrap, Aldroid, g33kou,
-- Catnip, Pumpuli
-- And eveyone watching!

local S,C,PI=math.sin,math.cos,math.pi
local TAU,MIN,MAX=PI*2,math.min,math.max
local R=math.random
local T=0
local RB,GB,BB=0,0,0
local R1,G1,B1=0,0,0
local R2,G2,B2=0,0,0

local DECAY=0.9

local arms={}
local buff={}

function SCN(y)
 vbank(0)
	poke(0x3FF9,S(y*.014+T*.02)*30)
	local m=127+S(y*.025+T*.01)*127
	for i=0,14 do
	 local v=i/14
	 local iv=1-v
		rgb(i+1,
			(RB*iv+v*R1)*m,
			(GB*iv+v*G1)*m,
			(BB*iv+v*B1)*m
		)
	end

	vbank(1)
	poke(0x3FF9,S(y*.019+T*.014)*30)
	rgb(0,0,0,0)

	local m=127-S(y*.019-T*.014)*127
	for i=0,14 do
	 local v=i/14
	 local iv=1-v
		rgb(i,
			(RB*iv+v*R2)*m,
			(GB*iv+v*G2)*m,
			(BB*iv+v*B2)*m
		)
	end
end

function rand()
	ADD=.8--.5+R()*.4
	DECAY=.96--.4+R()*.9
	XM1=.004+R()*.003
	XM2=.004+R()*.003
	YM1=.004+R()*.003
	YM2=.004+R()*.003

	RB,GB,BB=R()*.3,R()*.3,R()*.3
	R1,G1,B1=.5+R()*.5,.5+R()*.5,.5+R()*.5
	R2,G2,B2=.5+R()*.5,.5+R()*.5,.5+R()*.5

	arms={}
	local nArms=R(2,5)
	for i=1,nArms do
		arms[#arms+1]={d=R(0,60)-40,a=R(3,5),s=R(2,5),sp=(R()-.5)*.1}
	end
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BOOT()
	cls()

	for i=0,32640 do
		buff[i]=0
	end
end

function buffToScreen()
	for i=0,32639 do
		poke4(i,1+buff[i])
	end
end

function buffToScreenRev()
	for i=0,32639 do
		poke4(i,buff[32639-i])
	end
end

function decayBuff()
	for i=0,32640 do
		buff[i]=buff[i]*DECAY
	end
end

function TIC()
	poke(0x3ffB,0) -- mouse begone!

	if T%200==0 then
		rand()
	end

	decayBuff()
	local x=120+S(T*XM1)*200+S(T*XM1)*200
	local y=68+S(T*YM1)*150+S(T*YM1)*150
	drawLevel(x,y,arms,1,T*.01)

	vbank(0)
	buffToScreen()
	
	vbank(1)
	buffToScreenRev()

	local txt="jtruk"
	local x=170
	local y=128
	print(txt,x+1,y+1,4)
	print(txt,x,y,15)

	T=T+1
end

function drawLevel(ox,oy,arms,iLevel,sp)
	local arm=arms[iLevel]
 for i=1,arm.a do
 	local a=i/arm.a*TAU+sp+arm.sp*T
  local px=ox+C(a)*arm.d
  local py=oy+S(a)*arm.d
		drawCirc(px,py,arm.s)
		
		if iLevel<#arms then
		 drawLevel(px,py,arms,iLevel+1,a+sp)
		end
 end
end

function drawCirc(ox,oy,r)
 local d2=r^2
	for y=-r,r do
	 local y2=y^2
		for x=-r,r do
	  local x2=x^2
			if x2+y2<d2 then
			 local p=(ox+x)//1%240+((oy+y)//1%136)*240
				buff[p]=MIN(buff[p]+ADD,13)
			end
		end
	end
end