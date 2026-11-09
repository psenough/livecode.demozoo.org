-- Bytejam 20261102 (jtruk)
-- Thanks: Host(Reality) Donks(Chaos)

local M=math
local S,C,MIN,MAX=M.sin,M.cos,M.min,M.max
local PI,R=M.pi,M.random
local TAU=PI*2
local TEXTPIXELS={}
local SPARKS={}
local T=0
local CAM={x=0,y=0,z=-1.5}
local SCRX,SCRY=120,100
local spin=0
local spind=0
local MAX_SPARKS=100
local PS,PS_SH

function shuffle()
	spin,spind=0,0
	SPARKS={}
	
	vs={}
	local r0,g0,b0=R(100),R(100),R(100)
	local r1,g1,b1=150+R(100),150+R(100),150+R(100)
	rgbSpread(vs,1,15,r0,g0,b0,r1,g1,b1)

	vbank(0)
	rgb(0,0,0,0)
	for i,v in pairs(vs) do
		rgb(i,v[1],v[2],v[3])
	end

	local sc=.4
	vbank(1)
	for i,v in pairs(vs) do
		rgb(i,v[1]*sc,v[2]*sc,v[3]*sc)
	end
end

function BOOT()
	cls()
	local w=print("JTRUK",0,0,1)
	local h=5
	local wh,hh=w/2,h/2
	local dh=MAX(wh,hh)
	for y=0,h do
		for x=0,w do
			if pix(x,y)>0 then
				TEXTPIXELS[#TEXTPIXELS+1]={x=(x-wh)/dh,y=(y-hh)/dh}
			end
		end	
	end
end

function TIC()
	if T%400==0 then
		shuffle()
	end

	PS={}
	PS_SH={}
	CAM.z=-1.8
	
	spin=spin+spind
	spind=MIN(spind+.0005,.2)

	moveSparks()
	
	psWheel={}
	local sparkm=.02
	local d=.25
	for i=0,5 do
		local r0=spin+i*TAU/6
		local s0,c0=S(r0),C(r0)
		for p=-2,2 do
			local pd=.03*p
			local pw={
				x=s0*d+c0*pd,
				y=-.5+c0*d-s0*pd,
				z=0,
			}
			
			psWheel[#psWheel+1]=pw
			
			if p==-2 and R()<.1 then
				addSpark({
					x=pw.x,y=pw.y,z=pw.z,
					dx=-c0*sparkm,dy=s0*sparkm,dz=0,
					alive=true,
					life=100
				})
			end
		end
	end
		
	points={}
	addPoints(points,psWheel)
	renderSparks()
	
	for i,p in pairs(points) do
		local x,y,z=p.x,p.y,0

	 pointToRender(x,y,z)
	end
			
	table.sort(PS,function(a,b)
		return a.z<b.z
	end)

	table.sort(PS_SH,function(a,b)
		return a.z<b.z
	end)

	vbank(0)	
	cls()
	for _,p in pairs(PS) do
		circ(p.x,p.y,p.sz,p.c)
		circ(p.x-1,p.y-1,p.sz*.5,MIN(p.c+1,15))
	end
	print("JTRUK",211,129,1)
	print("JTRUK",210,128,5)
			
	vbank(1)
	cls()
	for _,p in pairs(PS_SH) do
		circ(p.x,p.y,p.sz,p.c)
		circ(p.x-1,p.y-1,p.sz*.5,MIN(p.c+1,15))
	end

	T=T+1
end

function pointToRender(x,y,z)
	x,z=rot(x,z,S(T*.01)*1)
--	y,z=rot(y,z,T*.015)
 if y<=0 then
		PS[#PS+1]=prepPoint(x,y,z)
		PS_SH[#PS_SH+1]=prepPoint(x,-y,z)
	end
end


function addPoints(out,add)
	for i,p in ipairs(add) do
		out[#out+1]=p
	end
end

function addSpark(sp)
	local n=getNextSparkN()
	if n>MAX_SPARKS then
		return
	end
	SPARKS[n]=sp
end

function getNextSparkN()
	for i,sp in ipairs(SPARKS) do
		if not sp.alive then
			return i
		end
	end
	
	return #SPARKS+1
end

function moveSparks()
	for i,sp in ipairs(SPARKS) do
		if sp.alive then
			sp.life=sp.life-1
			if sp.life>0 then
				local y=sp.y+sp.dy+.01
				if y>0 then
					y=0
					sp.dy=-sp.dy
				end
				
				sp.x,sp.y,sp.z=
					sp.x+sp.dx,
					y,
					sp.z+sp.dz
			else
				sp.alive=false
			end
		end
	end	
end

function renderSparks()
	for i,sp in ipairs(SPARKS) do
		if sp.alive then
			pointToRender(sp.x,sp.y,sp.z)
		end
	end	
end

function prepPoint(x,y,z)
	local x,y,z=proj(x,y,z)
	local sc=MIN(1,MAX(.02,z/250))
	local sz=MIN(20,MAX(2,sc*6))
	local c=sc*15
	return {x=x,y=y,z=z,sz=sz,c=c}
end


function rot(a,b,r)
	local sr,cr=S(r),C(r)
	return a*sr-b*cr,b*sr+a*cr
end

function proj(x,y,z)
 local zD=160/(z-CAM.z)
 return SCRX+(x-CAM.x)*zD,SCRY+(y-CAM.y)*zD,zD
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end

function rgbSpread(out,i0,i1,r0,g0,b0,r1,g1,b1)
	for i=i0,i1 do
		local im=(i-i0)/(i1-i0)
		local r=r0+(r1-r0)*im
		local g=g0+(g1-g0)*im
		local b=b0+(b1-b0)*im
		out[i]={r,g,b}
	end
end