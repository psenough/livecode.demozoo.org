-- Hello MNB!
-- Greetz:
-- Aldroid
-- Roeltje Muffintrap g33kou Reaby
-- &U!
local M=math
local S,C,PI,R=M.sin,M.cos,M.pi,M.random
local MIN,MAX=M.min,M.max
local TAU=2*PI
local T=0

local KSEGS=4
local KROT=0
local R0,G0,B0=0,0,0
local R1,G1,B1=0,0,0
local PLASMAM1=0
local PLASMAM2=0
local PLASMAM3=0
local PLASMAM4=0
local BDROFS=0
local SHAPESIDES=4
local SHAPEROT=0
local SHAPED=10

function lerp(a,b,l)
	return a*(1-l)+b*l
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BDR(y)
	vbank(0)
	rgb(0,0,0,0)
	for i=0,14 do
	 local m1=.5+S(y*.02+BDROFS)*.5
		local m2=1-m1
		local r=lerp(R0*m1,R1*m2,i/14)
		local g=lerp(G0*m1,G1*m2,i/14)
		local b=lerp(B0*m1,B1*m2,i/14)
		rgb(i+1,r,g,b)
	end
	
	vbank(1)
	for i=0,14 do
		local r=lerp(G1,G0*.5,i/14)
		local g=lerp(B1,B0*.5,i/14)
		local b=lerp(R1,R0*.5,i/14)
		rgb(i+1,r,g,b)
	end
	rgb(15,25,25,25)
end

function TIC()
poke(0x3ffb,0)
	if T%200==0 then
		shuffle()
	end
	
 vbank(1)
	drawSrc(T*.01)
	vbank(0)
	drawKaleido(KSEGS,T*KROT)
	vbank(1)
	cls()
	local d=(2.2+S(T*.03)+S(T*.018))*SHAPED
	drawShapes(SHAPESIDES,d,T*SHAPEROT)
 print("jtruk",204,127,15)
 
	T=T+1
end

function drawShapes(sides,d,a)
	local xc=120
	local yc=68
 local steps=150/d
	for r=1,steps do
	 local r0=r*d
	 local r1=r*d+MIN(d/4,5)
		for i=1,sides do
		 local a0=(i-1)/sides*TAU
		 local a1=i/sides*TAU
			local Sa0,Ca0=S(a0+a),C(a0+a)
			local Sa1,Ca1=S(a1+a),C(a1+a)
			local x00=xc+Sa0*r0
			local y00=yc+Ca0*r0
			local x01=xc+Sa1*r0
			local y01=yc+Ca1*r0
			local x10=xc+Sa0*r1
			local y10=yc+Ca0*r1
			local x11=xc+Sa1*r1
			local y11=yc+Ca1*r1
			local c=8+S(r*.4)*7
			tri(x00,y00,x01,y01,x10,y10,c)
			tri(x10,y10,x11,y11,x01,y01,c)
		end
	end
end

function shuffle()
 KSEGS=6+R(0,10)*2
 KROT=((R(0,200)/100)-1)*.02
	R0,G0,B0=R(0,255),R(0,255),R(0,255)
	R1,G1,B1=255-R0,255-G0,255-B0
	PLASMAM1=1/(R(1,100)/3)
	PLASMAM2=1/(R(1,100)/3)
	PLASMAM3=1/(R(1,100)/3)
	PLASMAM4=1/(R(1,100)/3)
	BDROFS=R(0,2000)/100
	SHAPESIDES=4+R(0,10)
	SHAPEROT=((R(0,200)/100)-1)*.02
	SHAPED=10+R(0,30)
end

function drawSrc(t)
	for y=0,127 do
		for x=0,127 do
		 local c=8+
				S(
				 S(x*PLASMAM1+y*PLASMAM2)
					+S(x*PLASMAM3-y*PLASMAM4)
					+t
				)*7
			pix(x,y,c)
		end
	end
end

function drawKaleido(nSegs,a)
	local dxc=120
	local dyc=68
	local d=160
	local sx0=40+S(T*.015)*40
	local sy0=40+S(T*.028)*40
	local sx1=40+S(T*.018)*40
	local sy1=80+S(T*.022)*40
	local sx2=80+S(T*.024)*40
	local sy2=80+S(T*.032)*40
	for i=1,nSegs do
		local da0=(i-1)/nSegs*TAU+a
		local da1=(i)/nSegs*TAU+a
		local dx0=dxc+C(da0)*d
		local dy0=dyc+S(da0)*d
		local dx1=dxc+C(da1)*d
		local dy1=dyc+S(da1)*d
		
		if i%2==0 then
		 local tx,ty=dx0,dy0
		 dx0,dy0=dx1,dy1
			dx1,dy1=tx,ty
		end
		
		ttri(
			dxc,dyc,dx0,dy0,dx1,dy1,
			sx0,sy0,sx1,sy1,sy2,sy2,
			2
		)
	end
end