-- ByteJam 20241021 (jtruk)
-- Greets: Violet,P3RC!
-- Aldroid,Pumpuli,Catnip,Totetmatt

local S=math.sin
local C=math.cos
local R=math.random
local MIN=math.min
local A=math.atan2
local PI=math.pi
local TAU=math.pi*2

local NX=50
local NY=50
local MINN=MIN(NX,NY)/4
local V={}
local DRIPS={}
local MAX_LIFE=100

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BDR(y)
	local r=40+S(y*.005+T*.008)*40
	local g=40+S(y*.008-T*.009)*40
	local b=40+S(y*.009+T*.007)*40
 rgb(0,r,g,b)

	for i=1,15 do
	 local v=i/15
		local r=127+S(-i*.03+y*.005+T*.008)*128
		local g=127+S(i*.04+y*.008-T*.009)*128
		local b=127+S(i*.05-y*.009+T*.007)*128
		rgb(i,r*v,g*v,b*v)
	end
end


T=0
function TIC()
	if R(0,80)<1 then
		addDrip(R(1,NX),R(1,NY))
	end

 update()

	cls()
	draw()
	
	T=T+1
end

function addDrip(x,y)
	DRIPS[getFreeDrip()]={
	 x=x,
		y=y,
		life=0,
	}
end

function getFreeDrip()
	for i,d in ipairs(DRIPS) do
		if d.life>MAX_LIFE then
			return i
		end
	end
	
	return #DRIPS+1
end

function update()
	reset()
	local mult=3
	for _,d in ipairs(DRIPS) do
	 if d.life<=MAX_LIFE then
		 local spread=d.life//mult
			for dy=-spread,spread do
				for dx=-spread,spread do
					local ox=d.x+dx
					local oy=d.y+dy
				 local r=(dx^2+dy^2)^.5
					if r<d.life/mult then
					 local px=ox%NX
					 local py=oy%NY
					 V[py][px]=V[py][px]+S((d.life/mult-r)/MAX_LIFE)*.5
					end
				end
			end
			
			d.life=d.life+.1
		end
	end
end

function draw()
	for y=0,NY-1 do
		for x=0,NX-1 do
		 local v=V[y][x]
			if v>0 then
				local p={x=(x-NX/2)/MINN,y=.3-v*.3,z=(y-NY/2)/MINN}
				p.x,p.y=rot(p.x,p.y,S(T*.01))
--				p.y,p.z=rot(p.y,p.z,S(T*.013)-PI)
				p.x,p.z=rot(p.x,p.z,S(T*.012)-PI)
				p.z=p.z+3+S(T*.02)
				p=proj(p)
	
				circ(p.x,p.y,3,8+v*8)
			end
		end
	end
end

function proj(p)
	local scale=2/p.z*80
	return {
	 x=120+p.x*scale,
		y=68+p.y*scale,
	}
end

function rot(a,b,r)
	return	a*C(r)-b*S(r),a*S(r)+b*C(r)
end

function reset()
	for y=0,NY-1 do
	 V[y]={}
		for x=0,NX-1 do
		 local d=((y-NY/2)^2+(x-NX/2)^2)^.5
			V[y][x]=ffts(d)*2
		end
	end
end
