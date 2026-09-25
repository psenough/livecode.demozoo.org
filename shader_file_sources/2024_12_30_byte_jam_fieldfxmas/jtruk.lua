-- Bytejam 20241230-jtruk
-- ByteJamuary!
-- Thanks: Reality, Polynomial
-- Greetz: gasman doop pumpuli
--         suule superogue &you

local M=math
local S,C,PI=M.sin,M.cos,M.pi
local R=M.random
local TAU=PI*2
local T=0
local CAM={x=0,y=0,z=0}

local PAGES={}

function getNextPage()
	for i,p in ipairs(PAGES) do
		if not p.alive then
			return i
		end
	end
	
	return #PAGES+1
end

function BOOT()
	vbank(0)
	rgb(1,255,255,255)
	rgb(2,0,0,0)
end

function BDR(y)	
	vbank(0)
	for i=0,12 do
	 local v=i/12
		rgb(3+i,127+v*127,0,128)
	end
	
	vbank(1)
	rgbs={
		{215,40,120},
		{40,215,120},
		{215,120,40}
	}
	
	for i,crgb in ipairs(rgbs) do
		rgb(i,
			crgb[1]+S(y*.1+T*.1)*40,
			crgb[2]+S(y*.1-T*.1)*40,
			crgb[3]+S(y*.1+T*.1)*40
		)
	end
end

function addPage(p)
	PAGES[getNextPage()]={
		alive=true,
		p=p,
		yD=.01+R()*.01,
		n=R(30)+1
	}
end

function TIC()
	if T%30==0 then
		local z=.5+R()*2
		addPage({
			x=(R()-.5)*5,
			y=-2.5*z,
			z=z,
		})
	end
	vbank(1)
	cls(1)
	for i=0,31 do
	 local x=i%5*16
	 local y=i//5*16
		local w=print(i,0,140)
		
		print(i,x-w/2+9,y+5,2)
	end

	vbank(0)
	cls()
	local angs=64
	for i=0,angs do
		local a1=i/angs*TAU
		local a2=(i+1)/angs*TAU
		local c=20+fft((i+S(T*.1))//1)^.5*80
		local x1=120+C(a1)*c*1.4
		local y1=68+S(a1)*c
		local x2=120+C(a2)*c*1.4
		local y2=68+S(a2)*c
		tri(120,68,x1,y1,x2,y2,3+S(a1+T*.03)%12)
	end
	
	for i,page in ipairs(PAGES)do
	 local p=page.p
		if page.alive then
			drawPage(p.x,p.y,p.z,i+T*.1,page.n)
			p.y=p.y+page.yD
			if p.y>p.z*2.5 then
				page.alive=false
			end
		end
	end

	vbank(1)
	cls()	
	
	pr("#ByteJamuary",120,10,1,3)
	pr("   A month of\n\nByteJam tricks!",120,48,2,2)
	pr("bytejamuary.creativenucleus.com",120,110,4,1)

	pr("jtruk #Ad",212,128,3,1)
	
 T=T+1
end

function pr(txt,x,y,c,s)
	w=print(txt,0,140,c,false,s)
	x=x-w/2
	for dy=-1,1 do
		for dx=-1,1 do
			print(txt,x+dx,y+dy,15,false,s)
		end
	end
	print(txt,x,y,c,false,s)
	return w
end

function drawPage(xc,yc,zc,t,n)
		local sp=4
		local ps={}
		local tx={}
		local ofs=-.5
		local fr=1/sp
	 local tx0=n%5*16
	 local ty0=n//5*16
		for y=0,sp do
			ps[y]={}
		 tx[y]={}
			for x=0,sp do
			 txx=fr*x
				txy=fr*y
				ofx,ofy=rot(ofs+txx,ofs+txy,t*.1)
				z=zc+S(x+y+t)*.04
				ofx,ofz=rot(ofx,z,t*.2)
				p={
					x=xc+ofx,
					y=yc+ofy,
					z=z
				}
				ps[y][x]=proj(p)
			 tx[y][x]={x=tx0+txx*16,y=ty0+txy*16}
			end
		end

		for y=0,sp-1 do
			for x=0,sp-1 do
				drawQuad(
					ps[y][x],ps[y][x+1],
					ps[y+1][x+1],ps[y+1][x],
					tx[y][x],tx[y][x+1],
					tx[y+1][x+1],tx[y+1][x]
				)
			end
		end
end

function drawQuad(p1,p2,p3,p4,t1,t2,t3,t4)
	drawTri(p1,p2,p3,t1,t2,t3)
	drawTri(p3,p4,p1,t3,t4,t1)
end

function drawTri(p1,p2,p3,t1,t2,t3)
	ttri(
		p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
		t1.x,t1.y,t2.x,t2.y,t3.x,t3.y,
		2,0,
		1/p1.z,1/p2.z,1/p3.z
	)
end

function rot(a,b,r)
	local s,c=S(r),C(r)
	return a*c-b*s,a*s+b*c
end

function trans(p,t)
	return {x=p.x+t.x,y=p.y+t.y,z=p.z+t.z}
end

function proj(p)
	local zD=40/(p.z-CAM.z)
	return {
	 x=120+(p.x-CAM.x)*zD,
	 y=68+(p.y-CAM.y)*zD,
		z=zD,
	}
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)poke(a+1,g)poke(a+2,b)
end