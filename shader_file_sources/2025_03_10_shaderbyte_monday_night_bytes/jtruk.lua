-- Bytejam 20250310 jtruk
-- Thanks4hosting: Aldroid
-- Greetz:
--  Catnip, Littletheremin,
--  Weatherman115, YOUUOUU
local M=math
local S,C,PI=M.sin,M.cos,M.pi
local TAU=PI*2
local ABS=M.abs

local T=0

function BOOT()
 for vb=0,1 do
		vbank(vb)
		local m=1-(1-vb)*.6
		rgb(0,0,0,0,m)
		rgb(1,255,200,150,m)
		rgb(2,50,50,200,m)
		rgb(3,255,255,255,m)
		rgb(4,185,54,25,m)
		rgb(5,125,34,15,m)
		rgb(6,100,24,10,m)
		rgb(9,128,100,75,m)
		rgb(10,25,25,100,m)
		rgb(11,128,128,128,m)
		rgb(12,90,26,12,m)
		rgb(13,60,15,8,m)
		rgb(14,50,12,4,m)
	end
end

function TIC()
 poke(0x3ffb,0)
	vbank(1)
	cls()
	
	local n=50
	local ps={}
	local z=.9+ffts(3)*.2
	for h=-1,1,.1 do
		for i=1,n do
			local a=i/n*TAU
			local l=1*z
			local c=1
			local s=1
			
			local h3=(1-ABS(h))^.28
			l=l*h3
			
			-- nose
			if h>-.2 and h<.4 then
			 if a<.2 or a>TAU-.2 then
					f=((h+.3)/.7)
					l=l+(1-f)*.4
				end
			end

			-- eyes
			if h>=.2 and h<=.5 then
				if (a>=.2 and a<=.7) or (a>=TAU-.7 and a<=TAU-.2) then
					l=l-.2
					c=3
				end
			end

			-- teeth
			local mh=(.5+S(T*.2)*.5)*.2
			local mw=(.5+S(T*.3)*.5)*.7
			if h>-.45-mh and h<-.45+mh then
				if a<=mw or a>=TAU-mw then
					l=l-.2
					c=3
				end
			end

			-- hair
			local hc=4+((h+i+1)^5.2)%3
			if h>.75 then
				c=hc
			elseif h>-.4 then
			 if a>1.2 and a<TAU-1.2 then
				 c=hc
				end
			end

			ps[#ps+1]={
				x=S(a)*l,
				y=h,
				z=C(a)*l,
				c=c,
				s=s,
			}
		end
	end

	local yturn=S(T*.01)
	local rx=S(T*.06)*.2
	local ry=PI+yturn*.4
	local rz=S(T*.03)*.1

	local eyeX=yturn--S(T*.06)
	local eyeY=0--S(T*.04)
	ps[#ps+1]={x=S(.35+eyeX*.15)*.8,y=.35+eyeY*.1,z=C(.35+eyeX*.15)*.8,c=2,s=2}
	ps[#ps+1]={x=S(TAU-.3+eyeX*.15)*.8,y=.35+eyeY*.1,z=C(TAU-.3+eyeX*.15)*.8,c=2,s=2}

	for i,p in ipairs(ps) do
		p.y,p.z=rot(p.y,p.z,rx)
		p.x,p.z=rot(p.x,p.z,ry)
		p.x,p.y=rot(p.x,p.y,rz)
		newP=trans(p,{x=S(f+T*.01),y=S(T*.02)*.3-.65,z=S(T*.03)*2})
		newP=proj(newP)
		newP.c=p.c
		newP.s=p.s
		ps[i]=newP
	end

	table.sort(ps,function(a,b)return a.z<b.z end)
	
	for _,p in ipairs(ps) do
		circ(p.x+1,p.y+1,2*p.s,p.c+8)
		circ(p.x,p.y,2*p.s,p.c)
	end

	vbank(0)
	cls()
	local ofs=80
	ttri(
		0,0+ofs,240,0+ofs,0,136+ofs,
		0,136,240,136,0,0,
		2
	)
	ttri(
		240,0+ofs,240,136+ofs,0,136+ofs,
		240,136,240,0,0,0,
		2
	)

	print("jtruk",210,127,12)
	print("jtruk",209,126,1)

	T=T+1
end

function trans(a,b)
	return {
		x=a.x+b.x,
		y=a.y+b.y,
		z=a.z+b.z,
	}
end

function rot(a,b,r)
	local c,s=C(r),S(r)
	return c*a+s*b,s*a-c*b
end

function proj(p)
	local zD=10/(p.z-8)
	return {
		x=120+p.x/zD*60,
		y=68-p.y/zD*60,
		z=zD,
	}
end

function rgb(i,r,g,b,m)
	local a=16320+i*3
	poke(a,r*m) poke(a+1,g*m) poke(a+2,b*m)
end