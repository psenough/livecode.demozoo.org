-- Bytejam 20251215-jtruk
-- Thnx: Alrdoid (Host)
-- 		    ArchyDragon (music)
-- Grtz: DaftShader, enfys,
--       g33kou, littletheremin
--   You're all unique
--   and wonderful snowflakes <3
local T=0
local M=math
local R,S,C,PI=M.random,M.sin,M.cos,M.pi
local TAU=PI*2
local SFDEF={}
local CAMZ=0

function shuffle()
	SFDEF={}
	fracs={}
	local frs=R(1,4)
	for i=0,frs do
		fracs[#fracs+1]={
			fr=R()*.9,
			l=R()*.7,
			ad=.1+R()*.3,
	}
	end
	SFDEF.bub=R()*.2
	SFDEF.fracs=fracs
	SFDEF.drot={x=R()*2-1,y=R()*2-1,z=R()*2-1}
	SFDEF.rot={x=0,y=0,z=0}
end

function BDR(y)
	rgb(0,0,0,30+(y/140)*120)
end

function BOOT()
	rgb(0,0,0,60)
	for i=1,15 do
		local r=i/15*255
		local g=r
		local b=100+i/15*155
		rgb(i,r,g,b)
	end
end

function TIC()
	if T%80==0 then
	 shuffle()
	end
	
	cls()
	draw(SFDEF)
	local rotdiv=.02
	SFDEF.rot.x=SFDEF.rot.x+SFDEF.drot.x*rotdiv
	SFDEF.rot.y=SFDEF.rot.y+SFDEF.drot.y*rotdiv
	SFDEF.rot.z=SFDEF.rot.z+SFDEF.drot.z*rotdiv
	
	CAMZ=S(T*.01)*40
	print("JTRUK",209+1,128+1,2)
	print("JTRUK",209,128,5)
		
	T=T+1
end

function draw(def)
	for i=0,5 do
	 local a=i*TAU/6
	 spoke(0,0,a,60,2,def)
	end
end

function spoke(xo,yo,a,l,rec,def,ci,camz)
	for spl=0,l do
	 local x,y=getR(xo,yo,a,spl)
		local s=.5+S(spl*TAU)*.5
		local p={x=x,y=y,z=0}
		p.x,p.y=rot(p.x,p.y,def.rot.x)
		p.x,p.z=rot(p.x,p.z,def.rot.y)
		p.y,p.z=rot(p.y,p.z,def.rot.z)
		p.z=p.z+CAMZ
		p=proj(p)
		if p.z>0 then
			local ci=8+S(spl*.05)*7
			local cr=(.5+S(spl*def.bub)*.5)*(1+rec)
			circ(p.x,p.y,cr,ci)
		end
	end
	if rec>0 then
		for _,frac in pairs(def.fracs) do
			local spl=l*frac.fr
		 local x,y=getR(xo,yo,a,spl)
	 	local lSide=l*frac.l
			local aDiff=PI/2-frac.ad
			spoke(x,y,a+aDiff,lSide,rec-1,def)
			spoke(x,y,a-aDiff,lSide,rec-1,def)
		end
	end
end

function getR(xo,yo,a,d)
	return xo+S(a)*d,yo+C(a)*d
end

function proj(p)
	local dZ=100/(100-p.z)
	return {
		x=120+p.x*dZ,
		y=68+p.y*dZ,
		z=dZ,
	}
end

function rot(a,b,r)
	local s,c=S(r),C(r)
	return c*a+s*b,s*a-c*b
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end