-- Bytejam 2025-08-18 (jtruk)
-- Thx: Aldroid (host) Lotek Style (DJ)
-- Greets: G33kou Weatherman115
--   Fulesnabel Pumpuli anchoo!

local M=math
local S,C,PI=M.sin,M.cos,M.pi
local TAU=PI*2
local R=M.random
local T=0
local N_ANTS=5
local ANTSTEP=4

TILES={}
ANTS={}

function BOOT()
	for y=0,15 do
		local row={}
		for x=0,15 do
			row[x]={
				c=R(0,1),
				f=R(0,1),
			}
		end
		TILES[y]=row
	end
	
	for i=1,N_ANTS do
		addAnt()
	end
end

function TIC()
	if T%200==0 then
	 cls()
	end

	moveAnts()
	drawTiles()
--	drawAnts()

	doRGB()
	
	print("JTRUK",209+1,128+1,1)
	print("JTRUK",209,128,4)

	T=T+1
end

function drawTiles()
	for y=0,15 do
 	for x=0,15 do
   local co=getCoords(x,y)
   local tile=TILES[y][x]
   local c=1+(tile.c%15)
			if tile.f==0 then
	   tri(co.x1,co.y1,co.x2,co.y2,co.x3,co.y3,c)
			else
			 tri(co.x4,co.y4,co.x2,co.y2,co.x3,co.y3,c)
			end
		end
	end
end

function getCoords(x,y)
	local ux=TAU*x/16+S(T*.004)*TAU*2
	local dx=TAU/32+S(T*.004)
	local uy=y/16
	local dy=1/32
	local a1=ux-dx
	local a2=ux+dx
	local d1=uy-dy
	local d2=uy+dy
	local sa1,ca1=S(a1),C(a1)
	local sa2,ca2=S(a2),C(a2)
	local zm=(.5-S(T*.01))*5
	local z1=(uy-dy)*zm
	local z2=(uy+dy)*zm
 x1,y1,z1=proj(sa1*d1,ca1*d1,z1)
 x2,y2,z2=proj(sa2*d1,ca2*d1,z2)
 x3,y3,z3=proj(sa1*d2,ca1*d2,z1)
 x4,y4,z4=proj(sa2*d2,ca2*d2,z2)
 
 return{
  x1=x1,y1=y1,
  x2=x2,y2=y2,
  x3=x3,y3=y3,
  x4=x4,y4=y4,
 }
end

function proj(x,y,z)
	local zD=10/(10-z)
	x,y,z=120+100*x/zD,68+100*y/zD,zD

	local a=T*.01
	rx=x
	ry=y
	rz=z
--	ry=S(a)*z+C(a)*y
--	rz=C(a)*y-S(a)*z

	return rx,ry,rz
end

function chooseAntDir()
	local mx,my=0,0
	if R(0,1)==0 then
	 mx=R(0,1)*2-1
	else
	 my=R(0,1)*2-1
	end
	return mx,my
end

function addAnt()
	local mx,my=chooseAntDir()
	ANTS[#ANTS+1]={
		x=R(0,15),
		y=R(0,15),
		mx=mx,
		my=my,
		mc=R(0,ANTSTEP),
	}
end

function moveAnts()
	for _,ant in ipairs(ANTS) do
	 ant.mc=ant.mc-1
		if ant.mc<=0 then
			ant.mc=ANTSTEP
			ant.x=(ant.x+ant.mx)%16
			ant.y=(ant.y+ant.my)%16
			
			local tile=TILES[ant.y][ant.x]
			tile.c=tile.c+1
			tile.f=1-tile.f
			
			if R(0,10)==0 then
				local mx,my=chooseAntDir()
				ant.mx,ant.my=mx,my
			end
		end
	end
end

function drawAnts()
	for _,ant in ipairs(ANTS) do
	 circ(ant.x*8+4,ant.y*8+4,3,15)
	end
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end

function doRGB()
	for i=1,15 do
		local r=i/15*(.5+S(T*.005))*255
		local g=i/15*(.5+S(1*T*.007))*255
		local b=i/15*(.5+S(2*T*.009))*255
		rgb(i,r,g,b)
	end
end