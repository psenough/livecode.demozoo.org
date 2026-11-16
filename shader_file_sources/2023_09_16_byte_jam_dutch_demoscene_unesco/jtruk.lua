-- Congratulations Dutch Demo Scene!
--
-- Greetz to all
-- Esp: Havoc, (M)Antratronic
-- Aldroid, and Suule

local T=0
local VOL=0
local bobSeeds={}

function clamp(v,low,high)
	return math.min(high,math.max(v,low))
end

function BDR(y)
	vbank(0)
 local addr=0x3fc0
	poke(addr,y/2)

 local sl=y-4
 for i=1,15 do
  local addr=0x3fc0+i*3
		local rd=1-clamp(math.abs((10-sl)/150),0,1)
		local gd=1-clamp(math.abs((68-sl)/50),0,1)
		local bd=1-clamp(math.abs((126-sl)/150),0,1)

  local str=i/15
  local r=str*rd
  local g=str*gd
  local b=str*bd
		poke(addr,(r*255)//1)
		poke(addr+1,(g*255)//1)
		poke(addr+2,(b*255)//1)
	end
	
	vbank(1)
	for i=1,6 do
	 local addr=0x3fc0+i*3
	 local r=.5+math.sin(i*2+y*.025+T*.010)*.5
	 local g=.5+math.sin(i*3+y*.02+T*.012)*.5
	 local b=.5+math.sin(i*4+y*.03-T*.008)*.5
		poke(addr,(r*255)//1)
		poke(addr+1,(g*255)//1)
		poke(addr+2,(b*255)//1)
	end
end

function drawUNESCO(x0,y0)
	-- U
	local x=x0+math.sin(T*.09)*10
 local y=y0+math.sin(T*.1)*10
	clip(x,y,32,32)
 circ(x+16,y+16,15,1)
	elli(x+16,y,3,20,0)

	-- N
 x=x0+32+math.sin(T*.076)*10
 y=y0+math.sin(T*.07)*10
	clip(x,y,32,32)
 circ(x+16,y+16,15,2)
	elli(x+16,y+32,3,20,0)

	-- E
 x=x0+64+math.sin(T*.05)*10
 y=y0+math.sin(T*.1)*10
	clip(x,y,32,32)
 circ(x+16,y+16,15,3)
	elli(x+32,y+10,20,3,0)
	elli(x+32,y+22,20,3,0)

	-- S
 x=x0+96+math.sin(T*.09)*10
 y=y0+math.sin(T*.08)*10
	clip(x,y,32,32)
 circ(x+16,y+16,15,4)
	elli(x+32,y+10,20,3,0)
	elli(x,y+22,20,3,0)

	-- C
 x=x0+128+math.sin(T*.12)*10
 y=y0+math.sin(T*.13)*10
	clip(x,y,32,32)
 circ(x+16,y+16,15,5)
	elli(x+32,y+16,20,3,0)

	-- O
 x=x0+160+math.sin(T*.08)*10
 y=y0+math.sin(T*.12)*10
	clip(x,y,32,32)
 circ(x+16,y+16,15,6)
	elli(x+16,y+16,4,8,0)

	clip()
end

function BOOT()
	for i=1,300 do
		table.insert(bobSeeds,math.random())
	end

	vbank(1)
 local addr=0x3fc0+15*3
	poke(addr,255)
	poke(addr+1,255)
	poke(addr+2,0)

 local addr=0x3fc0+14*3
	poke(addr,255)
	poke(addr+1,120)
	poke(addr+2,0)
end

function TIC()
	VOL=.5+math.sin(T*.1)*.25
		+math.sin(T*.14)*.25
	vbank(0)
	cls()
	bobs={}
	for i=1,#bobSeeds do
		table.insert(bobs,makeBob(i,bobSeeds[i]))
	end

	table.sort(bobs, function(a,b)
		return a.z>b.z
	end)

	for i=1,#bobs do
		drawBob(bobs[i])
	end
		
	vbank(1)
	cls()
 drawUNESCO(20,50)

	for i=1,#bobSeeds do
		local s=bobSeeds[i]
		local x=120+math.sin(s*54)*120+math.sin(s*32+T*.1)*3
		local y=(s*32+(s+.2)*T*.6)%140-5
		local c=i%2==0 and 14 or 15		
		tri(x,y,x+3,y+3,x-3,y+4,c)
		rect(x-2,y+3,5,2,c)
	end

	T=T+1
end

function makeBob(i,bseed)
	local x=math.sin(i+bseed*20+T*.01)*150
	local y=math.sin(i+bseed*28+T*.012)*100
	local z=6+math.sin(i+bseed*32+T*.013)*5

	x=x/z
	y=y/z
	local scale=clamp(1/z,.1,1)
	local size=10*scale
	local c=1+scale*15
	return {
	 x=120+x,
		y=68+y*(.5+VOL*.5),
		z=z,
		size=10*scale,
		c=1+scale*15,
	}
end

function drawBob(b)
	circ(b.x,b.y,b.size,b.c)
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

