local M=math
local S,C,ATAN,R=M.sin,M.cos,M.atan2,M.random
local PI=M.pi
local TAU=PI*2
local T=0

local MSTEPS=8

local XD=240+10
local YD=136+10
local BGR,BGG,BGB=0

local CONFS={
 {
 	dr=8,
  step=12,
  xsteps=nil,
  ysteps=nil,
		bs={},
		lineo='v',
		lined=0,
		linei=0,
		linew=0,
	},{
 	dr=10,
  step=14,
  xsteps=nil,
  ysteps=nil,
		bs={},
		lineo='v',
		lined=0,
		linei=0,
		linew=0,
	}
}

function BDR(y)
	vbank(0)
	poke(0x3ffa,S(y*.07+T*.014)*10)
	poke(0x3ffb,S(y*.045+T*.01)*10)

	vbank(1)
	poke(0x3ff9,S(y*.06+T*.009)*10)
	poke(0x3ffa,S(y*.08+T*.012)*10)
end

function shuffle()
	shuffleValues(CONFS[1])
	shuffleValues(CONFS[2])
	shuffleBG()
	shuffleColours(0)
	shuffleColours(1)
end

function	shuffleValues(c)
	c.dr=R(4,30)
	c.step=c.dr+R(3,5)
	c.bs={}
	initConf(c)
end

function shuffleBG()
	BGR,BGG,BGB=getRGBTriplet()
	vbank(0)
	rgb(0,0,0,0)
	rgb(1,BGR,BGG,BGB)
end

function getRGBTriplet()
	local vs={1,.6,.2}
	local ri=R(1,#vs)
	local rv=vs[ri]
	table.remove(vs, ri)
	local gi=R(1,#vs)
	local gv=vs[gi]
	table.remove(vs, gi)
	local bi=R(1,#vs)
	local bv=vs[bi]
	table.remove(vs, bi)
	return rv,gv,bv
end

function shuffleColours(vb)
	vbank(vb)
	local rv,gv,bv=getRGBTriplet()

	for i=1,14 do
		local v=i/14
		local nv=1-v
		rgb(i+1,
			(nv*BGR+v*rv)*255,
			(nv*BGG+v*gv)*255,
			(nv*BGB+v*bv)*255
		)
		trace((nv*BGR+v*rv))
	end
end

function initConf(c)
 c.xsteps=XD//c.step
 c.ysteps=YD//c.step
 local bs={}
	for y=0,c.ysteps do
		for x=0,c.xsteps do
		 local i=1+(x+y)%15
			local ox=x-c.xsteps/2
			local oy=y-c.ysteps/2
			bs[#bs+1]={
			 ox=ox,oy=oy,
				c=i,x=ox,y=oy
			}
		end
	end
	c.bs=bs
end

function TIC()
	if T%200==0 then
		shuffle()
	end

	local v=S(T*.007)

	vbank(0)
 cls(1)
	drawBlocks(CONFS[1],T*.00004,1.5+v)
 moveBlocks(CONFS[1])
	print("jtruk",210,130,2)

	vbank(1)
 cls()
	drawBlocks(CONFS[2],T*.00007,1.5-v)
 moveBlocks(CONFS[2])

	print("jtruk",209,129,8)

	T=T+1
end

function drawBlocks(c,t,bz)
	local hx,hy=c.xsteps/2,c.ysteps/2
	for _,b in ipairs(c.bs) do
	 local dx,dy=b.ox-hx,b.oy-hy
	 local a=ATAN(dy,dx)
		local d=(dx^2+dy^2)^.5
		b.c=8+S(d+2*a+T*.01)*7
	end

	rotA=S(t)*TAU*2.5
	for _,b in ipairs(c.bs) do
	 local z=S(b.ox+b.oy+T*.01)*bz
		local x=(b.x*c.step)*z
		local y=(b.y*c.step)*z
		x,y=rot(x,y,rotA+x*.01+y*.01)
		x,y=(120+x)%XD-c.step,(68+y)%YD-c.step
		circb(x+1,y+1,
			c.dr*z,
			15-b.c
		)		
		circb(x-1,y-1,
			c.dr*z,
			1+b.c*.8
		)		
	end
end

function rot(a,b,r)
	return S(r)*a-C(r)*b,C(r)*a+S(r)*b
end

function moveBlocks(c)
	for _,b in ipairs(c.bs) do
	 if c.lineo=='v' then
			if b.x>=c.linei and b.x<c.linei+c.linew then
				b.y=b.y+c.lined/MSTEPS
			end
		elseif c.lineo=='h' then
			if b.y>=c.linei and b.y<c.linei+c.linew then
				b.x=b.x+c.lined/MSTEPS
			end
		end
	end
	
	if T%MSTEPS==0 then -- choose
	 if R(0,2)==0 then
		 c.lineo=R(0,1)==0 and 'v' or 'h'
			c.lined=R(0,1)==0 and -1 or 1
			if c.lineo=='h' then
			 c.linei=R(0,c.ysteps)
			else
			 c.linei=R(0,c.xsteps)
			end
			c.linew=R(3,10)
		end
	end
end

function rgb(i,r,g,b)
 local a=16320+i*3
 poke(a,r) poke(a+1,g) poke(a+2,b)
end