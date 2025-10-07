-- Bytejam 2025-09-13 Hackfest.nl
-- Greets: Havoc (host), DaTucker(DJ) F#Ready Boris, Suule 
-- Thx: Aldroid for relaxing, and you!

local S,C=math.sin,math.cos
local R=math.random
local MIN,MAX=math.min,math.max
local T=0

local SPOTS_X=240//8
local SPOTS_Y=136//8
local SPOTS
local BUGS
local MAX_BUGS=1000
local BUG_MOVE_INITIAL_TIMER=50
local BUG_MOVE_TIMER=8
local BUG_DIE=.01
local SPOT_DECAY=.93
local SHAPES={}

function BOOT()
	vbank(0)
	initRgbs(128,0,255)
	vbank(1)
	initRgbs(255,100,255)
	initSpots()
	initBugs()
	initShapes()
end

function TIC()
	local sqs1=16+S(T*.01)*8
	local ofs1x=S(T*.015)*(sqs1*3)
	local ofs1y=S(T*.024)*(sqs1)
	local sqs2=16+S(1+T*.02)*8
	local ofs2x=S(1+T*.008)*(sqs2*3)
	local ofs2y=S(1+T*.014)*(sqs2)

	animBugs()
	animSpots()
	vbank(0)
	cls()
	drawSpots(sqs1,ofs1x,ofs1y)
	vbank(1)
	cls()
	drawSpots(sqs1,ofs2x,ofs2y)

	local txt="JTRUK"
	print(txt,209,129,1)
	print(txt,209-1,129-1,4)
		
	T=T+1
end

function initSpots()
	SPOTS={}
	for y=1,SPOTS_Y do
		local l={}
 	for x=1,SPOTS_X do
			l[#l+1]={
			 c1=R(),
			 c2=R(),
			 c4=R(),
			 c8=R(),
			}
	 end
		SPOTS[#SPOTS+1]=l
	end
end

function animSpots()
	for y,l in ipairs(SPOTS) do
		for x,s in ipairs(l) do
			s.c1=s.c1*SPOT_DECAY
			s.c2=s.c2*SPOT_DECAY
			s.c4=s.c4*SPOT_DECAY
			s.c8=s.c8*SPOT_DECAY
	 end
	end
end

function drawSpots(sqSize,ofsX,ofsY)
	local dxc=120-sqSize*SPOTS_X/2+ofsX
	local dyc=68-sqSize*SPOTS_Y/2+ofsY
	for y,l in ipairs(SPOTS) do
		for x,s in ipairs(l) do
		 local c1=s.c1*15
		 local c2=s.c2*15
		 local c4=s.c4*15
		 local c8=s.c8*15
			local x0=dxc+(x-1)*sqSize
			local x1=x0+sqSize-1
			local y0=dyc+(y-1)*sqSize
			local y1=y0+sqSize-1
			local xc=(x0+x1)/2
			local yc=(y0+y1)/2
						
			tri(x0,y0,x1-1,y0,xc,yc-1,c1)
			tri(x1,y0,x1,y1-1,xc,yc,c2)
			tri(x0,y1,x1-1,y1,xc,yc,c4)
			tri(x0,y0+1,x0,y1-1,xc,yc,c8)
	 end
	end
end

function initRgbs(rM,gM,bM)
	for i=0,15 do
		local r=i/15*rM
		local g=i/15*gM
		local b=i/15*bM
		rgb(i,r,g,b)
	end
end

function initBugs()
	BUGS={}
end

function animBugs()
	if R(0,30)==0 then
		local dx,dy=R(1,SPOTS_X),R(1,SPOTS_Y)
		addShape(SHAPES[1],dx,dy)
	end

	for _,b in ipairs(BUGS) do
		if b.alive>0 then
			b.alive=b.alive-BUG_DIE
			b.timer=b.timer-1
			if b.timer==0 then
				b.x=b.x+b.dx
				b.y=b.y+b.dy
				b.timer=BUG_MOVE_TIMER
			end
		 local s=SPOTS[1+b.y%SPOTS_Y][1+b.x%SPOTS_X]

			if b.seg&1>0 then
				s.c1=MIN(1,s.c1+.1*b.alive)
			end
			if b.seg&2>0 then
				s.c2=MIN(1,s.c2+.1*b.alive)
			end
			if b.seg&4>0 then
				s.c4=MIN(1,s.c4+.1*b.alive)
			end
			if b.seg&8>0 then
				s.c8=MIN(1,s.c8+.1*b.alive)
			end
		end
	end
end

function getBugINext()
	for i,b in ipairs(BUGS) do
	 if b.alive<=0 then
			return i
		end
	end
	
	return #BUGS<MAX_BUGS and #BUGS+1 or nil
end

function addBug(bug)
	local i=getBugINext()
	if i==nil then
		return
	end
	
	bug.alive=1
	bug.timer=BUG_MOVE_INITIAL_TIMER
	BUGS[i]=bug
end

function addBug4(x,y)
	addBug({
		x=x,y=y,
		dx=1,dy=0,
	})

	addBug({
		x=x,y=y,
		dx=-1,dy=0,
	})

	addBug({
		x=x,y=y,
		dx=0,dy=1,
	})

	addBug({
		x=x,y=y,
		dx=0,dy=-1,
	})
end

function addShape(shape,dx0,dy0)
	for sy,l in ipairs(shape) do
		for sx,c in ipairs(l) do
		 local dx=1+(dx0+sx)%SPOTS_X
		 local dy=1+(dy0+sy)%SPOTS_Y
			if c&1>0 then
				addBug({
					x=dx,y=dy,
					dx=0,dy=-1,
					seg=1,
				})
			end

			if c&2>0 then
				addBug({
					x=dx,y=dy,
					dx=1,dy=0,
					seg=2,
				})
			end

			if c&4>0 then
				addBug({
					x=dx,y=dy,
					dx=0,dy=1,
					seg=4,
				})
			end

			if c&8>0 then
				addBug({
					x=dx,y=dy,
					dx=-1,dy=0,
					seg=8,
				})
			end
		end
	end
end

function initShapes()
--[[	SHAPES[#SHAPES+1]={
	 {15,0,6},
		{15,15,15},
		{9,0,15},			
	}
--]]
	SHAPES[#SHAPES+1]={
	 {
			   15,0,6,   0, 6,9,12,  0, 6,15, 0, 15,6,
		 0, 15,9, 0, 15,9, 0, 6,15,12, 0, 3,15,9,
		},
		{
			15,15,15, 0, 15,6,15, 0, 15,0, 0, 15,9,
			0, 15,9, 0, 15,15, 0, 3,15,12, 0, 0,15,0
		},
		{9,0,15,   0, 9,0,15,  0, 3,15, 0, 15,3,
		 0, 15,0, 0, 15,12, 0, 3,15,9, 0, 0,15,0
		},
	}
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r) poke(a+1,g) poke(a+2,b)
end