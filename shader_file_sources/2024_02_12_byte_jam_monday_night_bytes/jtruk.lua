-- Greetz: Vurpo, Lynn
-- HeNeArXn, Catnip, ToeBath
-- AND YOUUUUU

local T=0
local M=math
local S,C=M.sin,M.cos
local CAM_Z=-1

function BDR(y)
 vbank(0)
	local r=0
	local g=127+S(y*.01+T*.05)*40
		+((y//4%2)==0 and 20 or 0)
	local b=y
	setRGB(1,r,g,b)
	for i=2,15 do
		local r=127+S(i*.3+y*.02-T*.1)*127
		local g=0
		local b=127+S(i*.2+y*.05+T*.08)*127
 	setRGB(i,r,g,b)
	end
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function TIC()
	vbank(1)
	for y=0,63 do
		for x=0,63 do
--		 local c=1+((x+y)>>3)%15
   local dx,dy=x-32,y-32
   local d=(dx^2+dy^2)^.5
		 local c=d*.1+T*.07
			pix(x,y,2+(c%14))
		end
	end
	
	vbank(0)	
 cls(1)

 -- cube
	local ps={
	 {x=-1,y=-1,z=1},
	 {x=1,y=-1,z=1},
	 {x=-1,y=1,z=1},
	 {x=1,y=1,z=1},
	 {x=-1,y=-1,z=-1},
	 {x=1,y=-1,z=-1},
	 {x=-1,y=1,z=-1},
	 {x=1,y=1,z=-1},
	}

 faces={
 	{1,2,3,4},
 	{5,6,7,8},
		{1,3,5,7},
		{2,4,6,8},
		{1,2,5,6},
		{3,4,7,8},
 }

	CAM_Z=-2.5+S(T*.006)*1

	for ic=0,10 do 
		tps={}
	 for i,p in ipairs(ps) do
		 p=add(p,
				S(ic*.1+T*.06)*5,
				S(ic*.1+T*.1)*2,
				S(ic*.1+T*.08)
			)
	  p=rotX(p,ic+T*.01)
	  p=rotY(p,ic+T*.017)
	  p=rotZ(p,T*.03)
			p=proj(p)
			tps[i]=p
		end
	
	 for i,p in ipairs(tps) do
			circ(p.x,p.y,2,15)
		end
	
	 for _,f in ipairs(faces) do
			drawTri(tps[f[1]],tps[f[2]],tps[f[3]],false)
			drawTri(tps[f[3]],tps[f[2]],tps[f[4]],true)
		end
	end
		
	vbank(1)
	cls()
	print("jtruk",200,124,12)

	T=T+1
end

function proj(p)
	local zF=CAM_Z-p.z*.2
	local sc=20
 return {
  x=120+sc*p.x/zF,
  y=68+sc*p.y/zF,
  z=p.z/zF,
 }
end

function add(p,x,y,z)
	return {
	 x=p.x+x,
		y=p.y+y,
		z=p.z+z,
	}
end

function rotX(p,a)
	return {
	 x=p.x,
		y=p.y*C(a)-p.z*S(a),
		z=p.y*S(a)+p.z*C(a),
	}
end

function rotY(p,a)
	return {
		x=p.x*C(a)-p.z*S(a),
	 y=p.y,
		z=p.x*S(a)+p.z*C(a),
	}
end

function rotZ(p,a)
	return {
		x=p.x*C(a)-p.y*S(a),
		y=p.x*S(a)+p.y*C(a),
	 z=p.z,
	}
end

function drawTri(p1,p2,p3,flip)
	if flip==false then 
		t1x,t1y,t2x,t2y,t3x,t3y=0,0,63,0,63,63
	else
		t1x,t1y,t2x,t2y,t3x,t3y=63,63,0,63,0,0
	end
	
	ttri(
		p1.x,p1.y,
		p2.x,p2.y,
		p3.x,p3.y,
		t1x,t1y,t2x,t2y,t3x,t3y,
		2,
		-1
--		p1.z,p2.z,p3.z
	)
end