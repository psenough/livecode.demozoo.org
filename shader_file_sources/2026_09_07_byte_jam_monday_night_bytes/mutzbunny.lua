-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

z=50
H=0
col=1
cx=120
hy=40
f=80
scroll=0
bassavg=0
flash=0

function clamp(x,a,b)
return math.max(a,math.min(b,x))
end

function lerp(a,b,t)
return a+(b-a)*t
end

function rgbcol(i,r,g,b)
local adr=0x3FC0+i*3
poke(adr,r)
poke(adr+1,g)
poke(adr+2,b)
end

function mixcol(i,r1,g1,b1,r2,g2,b2,t)
rgbcol(i,lerp(r1,r2,t),lerp(g1,g2,t),lerp(b1,b2,t))
end

function quad(x1,y1,x2,y2,x3,y3,x4,y4,c)
tri(x1,y1,x2,y2,x3,y3,c)
tri(x1,y1,x3,y3,x4,y4,c)
end

function building(side,z,h,w,d)
local inner=1.6*side
local outer=(1.6+w)*side
local znear=z
local zfar=z+d
local sn=f/znear
local sf=f/zfar
local yn=hy+sn
local yf=hy+sf
local ytn=hy+(1-h)*sn
local ytf=hy+(1-h)*sf
local xin=cx+inner*sn
local xout=cx+outer*sn
local xinf=cx+inner*sf
local xoutf=cx+outer*sf

quad(xin,yn,xout,yn,xout,ytn,xin,ytn,2)
quad(xin,yn,xinf,yf,xinf,ytf,xin,ytn,1)
quad(xin,ytn,xout,ytn,xoutf,ytf,xinf,ytf,3)
end

function TIC()

	local t=time()/1000
	local bass=fft(1,5)
	bassavg=bassavg*0.94+bass*0.06
	local hit=math.max(0,bass-bassavg)
	local kick=clamp(hit*35,0,1)
	flash=math.max(kick,flash*0.82)
	local cycle=(math.sin(t*0.25)+1)/2
	local heat=clamp(cycle*0.25+flash*0.9,0,1)
	rgbcol(0,0,0,0)
	mixcol(1,3,8,25,35,2,20,heat)
	mixcol(2,8,25,60,100,5,40,heat)
	mixcol(3,15,60,120,210,25,45,heat)
	mixcol(4,30,130,190,255,100,20,heat)
	mixcol(12,30,170,255,255,120,20,heat)
	mixcol(13,1,3,15,18,1,15,heat)
	mixcol(14,5,12,45,80,4,40,heat)
	mixcol(15,20,70,160,255,40,30,heat)
	cls(0)
	rect(0,0,240,hy,13)
	rect(0,hy-22,240,22,14)
	local glow=2+flash*18
	rect(0,hy-glow,240,glow*2,15)
	rect(0,hy-1-flash*2,240,2+flash*4,12)
	scroll=scroll+0.1+bass*-0.015
	if(col<16) then
	col=col+0.1
	else
	col=1
	end
	for i=1,100 do
	z=((i-scroll)%100)+0.5
	wide=1.2
	s=f/z
	y=hy+s
	xl=cx-wide*s
	xr=cx+wide*s
	line(xl,y,xr,y,12)
	end
	for i=20,1,-1 do
	local z=((i*4-scroll)%60)+1
	local h=1.2+((i*17)%8)/5
	local w=0.5+((i*11)%5)/5
	local d=1.5+((i*7)%4)/2
	building(-1,z,h,w,d)
	building(1,z,h,w,d)
	end
	for x=-1,1,.25 do
	line(cx,hy,cx+x*wide*95,136,12)
	end
end
