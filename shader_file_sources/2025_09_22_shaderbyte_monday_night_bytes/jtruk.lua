-- Bytejam 2025-09-22
-- Thanks: Havoc (host)
--         Pumpuli (live modular synth!)
-- Greetz: Canmom,Boris,Weatherman,&U

local M=math
local S,C,MIN,MAX=M.sin,M.cos,M.min,M.max
local PI=M.pi
local TAU=PI*2
local R=M.random
local T=0
local CAM={x=0,y=0,z=0}

function BOOT()
	for i=0,1 do
		vbank(i)
		local mul=.5+(1-i)*.5
		rgb(0,0,0,0)
	 local ms={{1,0,0},{0,1,0},{0,0,1}}
		for cs=0,2 do
		 local m=ms[cs+1]
			for ci=0,4 do
	   local c=1+cs*5+ci
				local v=mul*255*(1+ci)/5
			 rgb(c,v*m[1],v*m[2],v*m[3])
			end
		end
	end
end

function TIC()
	vbank(0)
	cls()

	CAM.x=S(T*.02)*.8
	CAM.y=-.8+S(T*.015)*.5
	CAM.z=20+S(T*.03)*10

	for y=-1,1,.3 do
		for x=-1,1,.3 do
			local t={x=x,y=y,z=0}

			local ps={
				{x=0,y=0,z=0},
			}
			
			local xRot=T*.007+x*3+y*9
			local yRot=T*.015+x*8+y*4
			local zRot=T*.01+y*10
			local sides=5
			local d=.12
			for i=0,sides do
			 local a=i/sides*TAU
				local p={
				 x=S(a)*d,
				 y=C(a)*d,
				 z=0,
				}
				p.y,p.z=rot(p.y,p.z,xRot)
				p.x,p.z=rot(p.x,p.z,yRot)
				p.x,p.y=rot(p.x,p.y,zRot)
				ps[#ps+1]=p
			end

			local tris={}
			for i=0,sides-1 do
			 tris[#tris+1]={1,2+i,2+(i+1)%(sides)}
			end

			for i,p in ipairs(ps) do
				ps[i]=trans(p,t)
			end

			for i,p in ipairs(ps) do
				ps[i]=p
			end

   local tps={}
			for i,p in ipairs(ps) do
				p.y,p.z=rot(p.y,p.z,xRot)
				p.x,p.z=rot(p.x,p.z,yRot)
				p.x,p.y=rot(p.x,p.y,zRot)
				tps[#tps+1]=proj(p,1000)
			end

			draw(tps,tris,xRot,yRot,zRot)
		end
	end

 local y1,y2=100,136
	vbank(1)
	cls(0)
	rect(0,y1,240,y2-y1,11)
	ttri(
	 0,y2,240,y2,0,y1,
	 0,0,240,0,0,y1,
		2,0
	)
	ttri(
	 240,y2,240,y1,0,y1,
	 240,0,240,y1,0,y1,
		2,0
	)
	
	text="jtruk"
	print(text,209,129,12)
	print(text,208,128,14)
	
	T=T+1
end

function draw(ps,tris,xRot,yRot,zRot)
	local c=1+4*(xRot+yRot+zRot)/3
	for i,t in ipairs(tris) do
		local p1,p2,p3=ps[t[1]],ps[t[2]],ps[t[3]]
		tri(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,c)
	end
end

function proj(p,mul)
	local zD=mul/(p.z-CAM.z)
	local x=120+(p.x-CAM.x)*zD
	local y=68+(p.y-CAM.y)*zD
 p.x,p.y,p.z=x,y,zD
	return p
end

function trans(p,t)
	local x,y,z=p.x+t.x,p.y+t.y,p.z+t.z
	p.x,p.y,p.z=x,y,z
	return p
end

function rot(a,b,r)
	return
	a*C(r)-b*S(r),
	a*S(r)+b*C(r)
end

function rgb(i,r,g,b)
 local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end
