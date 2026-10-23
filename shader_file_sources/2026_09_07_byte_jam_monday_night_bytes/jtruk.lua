local T=0
local M=math
local S,C,R=M.sin,M.cos,M.random
local MIN,MAX=M.min,M.max
local CAM_X,CAM_Y,CAM_Z=0,0,5

local PS={
	{x=-1,y=-1,z=-1},
	{x=1,y=-1,z=-1},
	{x=-1,y=1,z=-1},
	{x=1,y=1,z=-1},
	{x=-1,y=-1,z=1},
	{x=1,y=-1,z=1},
	{x=-1,y=1,z=1},
	{x=1,y=1,z=1},
}

function BOOT()
	vbank(0)
	rgb(0,0,0,0)
	for i=0,6 do
		rgb(1+i,0,255*i/7,0)
		rgb(8+i,0,255*i/7,255*i/7)
	end
end

function BDR(y)
	vbank(0)
	local g=128+100*S(y*.04)*.2,0
	local b=200+50*S(y*.04)*.2,0
	rgb(0,0,g,b)
end

function TIC()
	vbank(1)
	for i=0,15 do
		pix(i,0,i)
	end
	
	CAM_X=S(T*.01)*3
	CAM_Y=S(T*.02)
	
	vbank(0)
	cls(0)

	local wZ=-T*.1

	local points={}
	for gx=-15,15 do
		local pline={}
		for gz=0,30 do
			local x,y,z=gx,2,10+(gz+wZ)%30
			y=y+(gx+gz)%2.3
		 x,y=rot(x,y,S(T*.01)*.2-1.5)
			p=proj({x=x,y=y,z=z})
			p.c=1+(gz+gx*5+y)%7
			pline[gz]=p
		end
		points[gx+10]=pline
	end

 local lastLine
	for iLine,pLine in ipairs(points) do
		local lastP
		for iPoint,p in ipairs(pLine) do
			if lastLine and lastP then
				local p1=lastLine[iPoint-1]
				local p2=lastLine[iPoint]
				if p1.z-p2.z>0 then
					quad(p1,p2,lastP,p,p.c,lastP.c)
				end
			end
			
			lastP=p
		end
		lastLine=pLine
	end
	
	vbank(1)
	cls()
	
	for _,p in ipairs(PS) do
		local x,y,z=p.x,p.y,p.z
		x,y=rot(x,y,T*.01)
		x,z=rot(x,z,T*.02)
		y,z=rot(y,z,T*.015)
		p=tr({x=x,y=y,z=z},{x=0,y=0,z=-6+S(T*.03)*4})
		p=proj(p)
		sz=clamp(-20*p.z,1,40)
		circ(p.x,p.y,sz,12)
	end
	print("JTRUK",210,128,15)
	print("JTRUK",209,127,12)

	T=T+1	
end

function quad(p1,p2,p3,p4,c1,c2)
	ttri(
		p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
	 c1,0,c1,0,c1,0,
		2,0,
		p1.z,p2.z,p3.z
	)

	ttri(
		p3.x,p3.y,p4.x,p4.y,p1.x,p1.y,
	 c2,0,c2,0,c2,0,
		2,0,
		p3.z,p4.z,p1.z
	)
end


function tr(p,m)
	return {x=p.x+m.x,y=p.y+m.y,z=p.z+m.z}
end

function proj(p)
	local zD=2/(p.z-CAM_Z)
	local pScale=80
	return {
		x=120+(p.x-CAM_X)*zD*pScale,
		y=68+(p.y-CAM_Y)*zD*pScale,
		z=zD,
	}
end

function rot(a,b,r)
	return S(r)*a+C(r)*b,
		C(r)*a-S(r)*b
end

function clamp(v,min,max)
	return MIN(MAX(v,min),max)
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r) poke(a+1,g) poke(a+2,b)
end