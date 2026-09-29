-- Bytejam 20251027 (jtruk)
-- Greetz to
-- host: reality
-- players: canmom aldroid boris marex
-- And youuuuu-wooo-hooo!

local S,C=math.sin,math.cos
local A=math.abs
local PI=math.pi
local R=math.random
local TAU=PI*2
local T=0
local NSCRATCHES=1000
local ZOOM=1

local FACES={}

function newFace(x,y,z)
	return {
	 c={x=x,y=y,z=z},
		e1={x=-.3,y=-.4,z=0},
		e2={x=.3,y=-.4,z=0},
		n={x=0,y=.1,z=0},
		m={x=0,y=.5,z=0},
	}
end

function BOOT()
	rgb(0,0,0,0)
	rgb(1,0,0,0)
	rgb(2,0,0,0)
	rgb(3,50,0,0)
	rgb(12,80,50,150)
	rgb(13,30,0,0)
	rgb(14,255,255,255)
	rgb(15,80,0,0)
	
	FACES[#FACES+1]=newFace(0,0,1)
--	FACES[#FACES+1]=newFace(2,0,2)
--	FACES[#FACES+1]=newFace(-2,0,1)
--	FACES[#FACES+1]=newFace(2,0,2)
end

function rand()
--[[
 local r=R(0,1)
 if r==0 then
	 local x=.4--+.4*R()
		local y=-.4+.1*R()
  FACE.e1={x=-x,y=y,z=0}
  FACE.e2={x=x,y=y,z=0}
 elseif r==1 then
		local y=.4+.2*R()
  FACE.m={x=0,y=y,z=0}
 end
 --]]
end

function TIC()
 vbank(0)
	cls()

	if T%50==0 then
	 rand()
	end

	ZOOM=1+.25*S(T*.04)+.25*S(T*.024)	
	local r={x=0,y=0,z=0}
	for i,face in ipairs(FACES) do
--	 face.c.x=S(i+T*.02)
--	 face.c.y=S(i+T*.014)
		drawFace(face,r)
		drawEye(face,face.e1,r)
		drawEye(face,face.e2,r)
		drawNose(face,face.n,r)
		face.m.h=.2+.8*A(S(T*.1))
		face.m.w=.3+.7*A(S(T*.07))
		drawMouth(face,face.m,r)
	end

	local sx,sy
	for i=0,NSCRATCHES do
	 local x=R(0,239)
	 local y=R(0,135)
		
		local c=15
		local p=pix(x,y)
		if p==1 then
		 c=14
			sx,sy=R(1,3),3
		elseif p==2 then
		 c=13
			sx,sy=R(1,3),3
		elseif p==3 then
		 c=12
			sx,sy=R(1,3),1
		else
			sx,sy=-R(1,3),3
		end
		
		line(x+sx,y-sy,x-sx,y+sy,c)
	end
	vbank(1)
	print("JTRUK",209,129,1)

 T=T+1
end

function drawFace(f,p,r)
--	p.y,p.z=rot(r.x,p.y,p.z)
--	p.x,p.z=rot(r.y,p.x,p.z)
--	p.x,p.y=rot(r.z,p.x,p.y)
	local pp=proj({x=f.c.x+p.x,y=f.c.y+p.y,z=f.c.z+p.z})
	elli(pp.x,pp.y,60*ZOOM,80*ZOOM,1)
end	

function drawEye(f,p,r)
--	p.y,p.z=rot(r.x,p.y,p.z)
--	p.x,p.z=rot(r.y,p.x,p.z)
--	p.x,p.y=rot(r.z,p.x,p.y)
	local pp=proj({x=f.c.x+p.x,y=f.c.y+p.y,z=f.c.z+p.z})
	elli(pp.x,pp.y,20*ZOOM,16*ZOOM,2)
	local ox=0--(S(T*.015)+S(T*.04))*.06
	local oy=0--(S(T*.01)+S(T*.022))*.03
	local pp=proj({x=f.c.x+p.x+ox,y=f.c.y+p.y+oy,z=f.c.z+p.z})
	elli(pp.x,pp.y,8*ZOOM,8*ZOOM,3)
	elli(pp.x,pp.y,3*ZOOM,3*ZOOM,0)
	elli(pp.x,pp.y,1*ZOOM,1*ZOOM,4)
end	

function drawNose(f,p,r)
--	p.y,p.z=rot(r.x,p.y,p.z)
--	p.x,p.z=rot(r.y,p.x,p.z)
--	p.x,p.y=rot(r.z,p.x,p.y)
 local w,h=10,7

	local np={x=p.x-.1,y=p.y,z=p.z}
	local pp=proj({x=f.c.x+np.x,y=f.c.y+np.y,z=f.c.z+np.z})
	elli(pp.x,pp.y,w*ZOOM,h*ZOOM,2)
	elli(pp.x,pp.y,w*ZOOM*.5,h*ZOOM*.2,3)
	local np={x=p.x+.1,y=p.y,z=p.z}
	local pp=proj({x=f.c.x+np.x,y=f.c.y+np.y,z=f.c.z+np.z})
	elli(pp.x,pp.y,w*ZOOM,h*ZOOM,2)
	elli(pp.x,pp.y,w*ZOOM*.5,h*ZOOM*.2,3)
end	

function drawMouth(f,p,r)
--	p.y,p.z=rot(r.x,p.y,p.z)
--	p.x,p.z=rot(r.y,p.x,p.z)
--	p.x,p.y=rot(r.z,p.x,p.y)
	local pp=proj({x=f.c.x+p.x,y=f.c.y+p.y,z=f.c.z+p.z})
	elli(pp.x,pp.y,p.w*40*ZOOM,p.h*10*ZOOM,2)
end	

function rot(r,a,b)
	local s,c=S(r),C(r)
	return a*c-b*s,a*s-b*c
end

function proj(p)
 local zD=1/p.z
	return {
		x=120+p.x*80*ZOOM*zD,
		y=68+p.y*80*ZOOM*zD,
		z=zD,
	}
end

function rgb(i,r,g,b)
 local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end