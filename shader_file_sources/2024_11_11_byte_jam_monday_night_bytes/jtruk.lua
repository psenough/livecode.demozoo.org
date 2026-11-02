-- Bytejam 2024-11-11
-- JTRUK
-- Thanks: Reality + Guy With Dog
-- Greetz: Catnip + Suule + Aldroid &U

local M=math
local C,S=M.cos,M.sin
local R,PI=M.random,M.pi
local TAU=PI*2
local T=0

local SPARKS={}

function BDR(y)
 vbank(0)
	rgb(0,y/6,0,20+y/2)

 vbank(1)
	rgb(1,0,0,0)
end

function BOOT()
 local h1,l1=255,120
 local h2,l2=150,60
 local h3,l3=80,30

	rgb(1,h1,l1,l1)
	rgb(2,h2,l2,l2)

	rgb(3,l1,h1,l1)
	rgb(4,l2,h2,l2)

	rgb(5,l1,l1,h1)
	rgb(6,l2,l2,h2)

	rgb(7,l1,h1,h1)
	rgb(8,l2,h2,h2)

	rgb(9,h1,l1,h1)
	rgb(10,h2,l2,h2)

	rgb(11,h1,h1,l1)
	rgb(12,h2,h2,l2)

	rgb(15,255,255,255)
end

function getFreeSparkN()
	for i,s in ipairs(SPARKS) do
		if s.l<0 then
			return i
		end
	end
	return #SPARKS+1
end

function launchFirework()
 if getFreeSparkN()>600 then
 	return -- ABORT!
 end
 
	local c=R(6)-1
	local x=(R()-.5)*4
	local y=-2.3
	local mx=(R()-.5)*.04
	local my=.04+R()*.02
	for i=0,100 do
	 p={x=x,y=y,z=0}
	 m={x=mx,y=my,z=0}
		local n=getFreeSparkN()
		SPARKS[n]={
			p=p,
			m=m,
			l=100+R()*100,
			fly=40+R(30),
			c=c,
		}
		end	
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function TIC()
 vbank(0)
	cls()
	
	if R()<.02 then
		launchFirework()
	end
		
	for i,s in ipairs(SPARKS) do
	 if s.l>0 then
			local p=s.p
			local m=s.m

			if s.fly==0 then
			 m={x=.02+R()*.02,y=0,z=0}

			 if i%2==0 then
				 m={x=m.x/3,y=m.y/3,z=m.z/3}
				end
			 m.x,m.y=rot(m.x,m.y,R()*TAU)
			 m.x,m.z=rot(m.x,m.z,R()*TAU)
			 m.y,m.z=rot(m.y,m.z,R()*TAU)
				trans(m,s.m)
				s.m=m
			end
			s.fly=s.fly-1

		 trans(p,m)
		 local p={x=p.x,y=p.y,z=p.z}
			local p=proj(p)
			
			local c=1+s.c*2
			if (s.l+i)%15<1 then
				c=15
			else if (s.l+i)%3<1 then
				c=c+1
			end
			end
			circ(p.x,p.y,R(2)-1,c)
			s.l=s.l-1
			m.y=m.y-.00045
		end
	end
	
	vbank(1)
	print("jtruk",209,129,15)
	print("jtruk",208,128,14)
	poke(0x3ffb,0)
		
	T=T+1
end

function trans(p,t)
	p.x,p.y,p.z=p.x+t.x,p.y+t.y,p.z+t.z
end

function rot(a,b,r)
	return a*C(r)-b*S(r),a*S(r)+b*C(r)
end

function proj(p)
	local CAMZ=8
	local zD=20/(p.z-CAMZ)
	return {
		x=120+p.x/zD*60,
		y=68+p.y/zD*60,
		z=z,
	}
end