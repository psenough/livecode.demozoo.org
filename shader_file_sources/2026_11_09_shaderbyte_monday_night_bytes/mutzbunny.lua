-- title:   Silly bytejam 2026-11-9
-- author:  MutzBunny
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

local sin=math.sin
local floor=math.floor
local W,H=240,136
local frame=0
local bass=0
local bassGain=4
local mountains={}

local palette={
"080b18","17152f","29284e","493b70",
 "24405e","365c77","56829a","88adbf",
 "182a3a","294858","426478","6c91a0",
 "00ff44","ff9900","0088ff","aaff00"}

function BOOT()
 for i=1,16 do
  local s=palette[i]
  for c=0,2 do
   poke(0x3FC0+(i-1)*3+c,
   	tonumber(s:sub(c*2+1,c*2+2),16))
  end
 end
	for layer=1,3 do
		mountains[layer]={}
		for x=0,W-1 do
			mountains[layer][x]=mountain(x,layer)
		end
	end
end

function hash(x)
	local n=sin(x*127.1+78.233)*43758.5453
	return n-floor(n)
end

function noise(x)
	local i=floor(x)
	local f=x-i
	local a=hash(i)
	local b=hash(i+1)
	f=f*f*(3-2*f)
	return a+(b-a)*f
end

function terrain(x,seed)
	return(noise(x*.025+seed)-.5)*2+(noise(x*.065+seed)-.5)*.7+(noise(x*.17+seed)-.5)*.18
end

function mountain(x,layer)
	local base={66,88,110}
	local height={31,25,18}
	return floor(base[layer]-terrain(x,layer*37)*height[layer])
end

function sky()
 cls(0)
 rect(0,22,W,30,1)
 rect(0,52,W,25,2)
 rect(0,77,W,20,3)
 
 for i=1,95 do
  local x=floor(hash(i*7)*W)
  local y=floor(hash(i*11)*73)
  local brightness=hash(i*19)
  local col=brightness>.88 and 15 or 6
  pix(x,y,col)
 end
end

function drawMountain(layer,col,edge)
	local m=mountains[layer]
	for x=0,W-1 do
	 local y=m[x]
		rect(x,y,1,H-y,col)
		pix(x,y,edge)
	end
end

function updateSky()
	local raw=fft(4)*bassGain
	raw=math.min(1,raw)
	local speed=0.08
	if raw>bass then speed=0.35 end
	bass=bass+(raw-bass)*speed
	poke(0x3FC0+0,8+bass*12)
	poke(0x3FC0+1,11)
	poke(0x3FC0+2,24+bass*16)
	poke(0x3FC0+3,23+bass*28)
	poke(0x3FC0+4,21)
	poke(0x3FC0+5,47+bass*24)
	poke(0x3FC0+6,41+bass*38)
	poke(0x3FC0+7,40+bass*5)
	poke(0x3FC0+8,78+bass*20)
	poke(0x3FC0+9,73+bass*30)
	poke(0x3FC0+10,59+bass*8)
	poke(0x3FC0+11,112+bass*20)
end

function drawLasers()
	local cx=120
	local cy=125
	local power=math.min(1,fft(1,4))
	local colors={12,13,14,15}
	local sweep=math.sin(frame*0.025)*65
	for i=1,7 do
		local offset=(i-4)*23
		local wobble=math.sin(frame*0.04+i*1.7)*18
		local ex=cx+sweep+offset+wobble
		local ey=5
		local col=colors[(i+math.floor(frame/12))%4+1]
	 local flicker=math.sin(frame*0.16+i*2)
		if power>0.35 or flicker>0.45 then
			line(cx,cy,ex,ey,col)
			if power>0.65 then
				line(cx+1,cy,ex+1,ey,col)
			end
		end
	end
end


function TIC()
 frame=frame+1
 updateSky()
 sky()
 drawMountain(1,4,6)
 drawLasers()
 drawMountain(2,5,7)
 drawMountain(3,8,9)
end
