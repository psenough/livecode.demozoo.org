-- pos: 0,0
local M=math
local S,C,A,R=M.sin,M.cos,M.abs,M.random
local MIN,MAX,PI=M.min,M.max,M.pi
local TAU=2*PI
local CAMX,CAMY,CAMZ=0,0,0

local GRAB={}

function BOOT()
 vbank(1)
	rgb(0,0,0,0)
	rgb(1,255,0,0)
	rgb(2,0,255,255)	
	rgb(3,255,255,255)	
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

T=0
function TIC()
	local ofs1=TAU*.33
	local ofs2=TAU*.67
	local objs={{
		m="heart",
		x=S(T*.01)*5,y=0,z=4+C(T*.01)*2,
		rx=T*.04,ry=T*.05,rz=T*.03,
	},{
		m="heart",
		x=S(ofs1+T*.01)*5,y=0,z=4+C(ofs1+T*.01)*2,
		rx=T*.04,ry=T*.05,rz=-T*.03,
	},{
		m="heart",
		x=S(ofs2+T*.01)*5,y=0,z=4+C(ofs2+T*.01)*2,
		rx=T*.04,ry=T*.05,rz=-T*.03,
	},{
		m="two-rings",
		x=0,y=0,z=2,
		rx=0,ry=T*.02,rz=T*.03,
	}}

	local txt1="jtruk"
	local txt2="Put your 3D glasses on now"		

 for e=0,1 do
  vbank(e)
  cls()
	 local c=1+e
		local xsh=e*8
		for i=1,#objs do
			local o=objs[i]
			local prims=nil
			if o.m=="heart" then
				prims=getPrimsHeart()
			elseif o.m=="two-rings" then
				prims=getPrimsTwoRings()
			end
	
			local tr={x=0,y=0,z=2}
			prims=movePrims(prims,
				o.rx,o.ry,o.rz,{
				x=o.x,y=o.y,z=o.z,
			})
			drawPrims(prims,c,xsh)
		end
		
		local sep=S(T*.08)*2
		if e==0 then
		 print(txt1,202+sep,128,1)
		 print(txt2,5-sep,128,1)
			grab()
			cls()
		else
		 print(txt1,202-sep,128,2)
		 print(txt2,5+sep,128,2)
			mix()
		end
	end
		
	T=T+1
end

function grab()
	for i=0,16319 do
		GRAB[i]=peek(i)
	end
--	for i=0,32639 do
--		GRAB[i]=peek4(i)
--	end
end

function mix()
	for i=0,16319 do
		poke(i,GRAB[i]|peek(i))
	end
--	for i=0,32639 do
--		poke4(i,GRAB[i]|peek4(i))
--	end
end

function getPrimsRing()
	local prims={}
	local steps=50
	for i=1,steps do
	 local a=i/steps*TAU
		prims[#prims+1]={
		 x=S(a),
			y=C(a),
			z=0,
			r=3,
		}
	end
	return prims
end

function getPrimsTwoRings()
	local prims={}
	local steps=100
	for i=1,steps do
	 local a=i/steps*TAU
		prims[#prims+1]={
		 x=S(a),
			y=C(a)+.5,
			z=0,
			r=3,
		}

		prims[#prims+1]={
		 x=0,
			y=C(a)-.5,
			z=S(a),
			r=3,
		}
	end
	return prims
end

function getPrimsHeart()
	local prims={}
	local steps=100
	local sc=.07
	for i=1,steps do
	 local a=i/steps*TAU
		prims[#prims+1]={
		 x=sc*(16*S(a)^3),
			y=sc*(13*C(a)-5*C(2*a)-2*C(3*a)-C(4*a)),
			z=0,
			r=5,
		}
	end
	return prims
end


function drawPrims(prims,c,xsh)
	for i=1,#prims do
		local prim=prims[i]
		local p=proj(prim,xsh)
		if p.z>0 then
			local r=MIN(80,p.r*p.z)
			circ(p.x,p.y,r,c)
		end
	end
end

function movePrims(prims,rx,ry,rz,tr)
	for i=1,#prims do
	 local p=prims[i]
  local x,y=r(p.x,p.y,rz)
  local x,z=r(x,p.z,ry)
  local y,z=r(y,z,rx)
	 prims[i]=trans({x=x,y=y,z=z,r=p.r},tr)
	end
	return prims
end

function r(a,b,r)
	return a*C(r)-b*S(r),a*S(r)+b*C(r)
end

function trans(p,t)
	return {
		x=p.x+t.x,
		y=p.y+t.y,
		z=p.z+t.z,
		r=p.r
	}
end

function proj(p,xsh)
 local zD=2/(p.z-CAMZ)
 return {
  x=120+(p.x-CAMX)*zD*30+xsh*zD,
  y=68+(p.y-CAMY)*zD*30,
  z=zD,
  r=p.r,
 }
end