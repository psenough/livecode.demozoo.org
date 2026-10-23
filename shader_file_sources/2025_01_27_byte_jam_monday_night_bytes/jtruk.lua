-- Bytejam 20250127 / jtruk
-- Greetz: Reality & Polynomial
--  Pumpuli g33kou weatherman115
--   AND YOU =)

local M=math
local S,C,PI=M.sin,M.cos,M.pi
local TAU,R=PI*2,M.random
local T=0

local RINGS={}
local FFTX=1

function shuffle()
	RINGS={}
	r=.2
	for i=0,10 do
	 local rd=.02+R()*.3
		RINGS[#RINGS+1]={
		 r=R()*TAU,
		 ro=r,
			rd=rd,
			rs=(2*R(0,1)-.5)*(.01+R()*.06),
			c=R(1,15),
			ao=R()*TAU,
			al=(.1+R()*.9)*PI,
			am=R(1,10),
		}
		r=r+rd+.05
		if r>3 then
			break
		end
	end

 local rm=R(0,3)*20
 local gm=R(0,3)*20
 local bm=R(0,3)*20
 rgb(0,rm,gm,bm)
	for io=0,2 do
	 local rm=R(0,3)*64
	 local gm=R(0,3)*64
	 local bm=R(0,3)*64
	 for ii=0,4 do
			local r=rm*(1+ii)/5
			local g=gm*(1+ii)/5
			local b=bm*(1+ii)/5
		 rgb(1+io*5+ii,r,g,b)
		end
	end
end

function shuffle2()
	for _,r in ipairs(RINGS) do
	 if R(10)<2 then
			r.rs=-r.rs
		end
	end
end

function TIC()
	if T%200==0 then
		shuffle()
	end
	
	if T%10==0 then
		shuffle2()
	end

 cls()
 poke(0x3ffb,0)

	local ar=(.5+FFTX*.5)*1
 for i,r in ipairs(RINGS) do
		r.ao=r.ao+r.rs
	 arc(
			0,0,
			ar,
			r.ro,r.rd,
			r.ao,r.al,
			r.am,
			r.c
		)
	end

--[[
 local fftv=ffts(5)
	if fftv>FFTX then
		FFTX=fftv
	else
	 FFTX=FFTX*.995
	end
--]]
  
 print("jtruk",210,129,11)
 print("jtruk",209,128,13)
 T=T+1
end

function arc(xc,yc,r,ro,rl,ao,al,m,ci)
	local nSpokes=(ro^.5)*20
	local ri=ro*r
	local ro=(ro+rl)*r
	local lxi,lyi,lxo,lyo
	local am=al/m
	local as=am+.1
	local rz=T*.01
	for s=1,m do
		for i=0,nSpokes-1 do
			local z=((T*.04+i*.03)*5)%10-10
			local a=ao+(am*i/nSpokes)+as*s
			local s,c=S(a),C(a)
			local xi=xc+s*ri
			local yi=yc+c*ri
			local xo=xc+s*ro
			local yo=yc+c*ro
			local xi,yi=rot(xi,yi,rz)
			local xo,yo=rot(xo,yo,rz)
			local xi,yi=proj(xi,yi,z)
			local xo,yo=proj(xo,yo,z)
			if i>0 then
				tri(lxi,lyi,xi,yi,lxo,lyo,ci)
				tri(lxo,lyo,xo,yo,xi,yi,ci)
	  end
			lxi,lyi,lxo,lyo=xi,yi,xo,yo
		end 
	end
end

function rot(a,b,r)
	local s,c=S(r),C(r)
	return a*c-b*s,a*s+b*c
end

function proj(x,y,z)
 local zd=10/(z-10)
	return 120+x*60*zd,68+y*60*zd
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end