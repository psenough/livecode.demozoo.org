-- Greetz Nusan, Alia, Suule, Aldroid
SX,SY=128,128
BOB={}
T=0
SIN=math.sin

function BOOT()
	cls()

	local fc,hc,ec,ebc=1,2,3,4
	circ(64,55,55,hc)
	rect(32,50,64,70,fc)

	elli(64,110,32,8,hc)
	elli(64-14,70,10,5,ec)
	elli(64+14,70,10,5,ec)

	-- eyeballs
	circ(64-14,70,3,ebc)
	circ(64+14,70,3,ebc)
	-- nostrils
	circ(64-4,86,3,ec)
	circ(64+4,86,3,ec)

	elli(64,110,20,5,fc)
	elli(64,107,20,5,hc)
	get()
	cls()
end

function BDR(y)
	vbank(1)	
	for c=1,15 do
		local addr=0x3fc0+c*3
		local r=.5+math.sin(c*.1+T*.08+y*.05)*.5
		local g=.5+math.sin(-c*.13-T*.05+y*.027)*.5
		local b=.5+math.sin(-c*.18+T*.07-y*.04)*.5
		poke(addr,r*255//1)
		poke(addr+1,g*255//1)
		poke(addr+2,b*255//1)
	end

	vbank(0)
	local addr=0x3fc0
	local r=.5+math.sin(T*.032-y*.05)*.5
	local g=.5+math.sin(T*.04-y*.027)*.5
	local b=.5+math.sin(T*.028+y*.04)*.5
	poke(addr,r*255//1)
	poke(addr+1,g*255//1)
	poke(addr+2,b*255//1)
end

function TIC()
	vbank(1)
	decay()

	NROSSES=6
	for i=1,NROSSES do
		local ofs=(i/NROSSES)*math.pi*2
		local s=.25+SIN(ofs+T/54)*.12
		local x=120+SIN(ofs+T/50)*80-s*64
		local y=68+SIN(ofs+T/82)*48-s*64
		set(x,y,s)
	end
	
--	set(30,30,.5)
 vbank(0)
 decay()
	local x=120+SIN(T/33)*70-1*64
	local y=70+SIN(T/28)*20-1*64
	set(x,y,1)
	drawText("SHADEBOBS!",34-x/4,64-y/4,3)
	T=T+1
end

function decay()
	for y=0,135 do
		for x=0,239 do
			local c=pix(x,y)
			if c>0 then --and math.random()>.1 then
				pix(x,y,c-1)
			end
		end
	end
end

function get()
 for y=0,SY-1 do
  for x=0,SX-1 do
  	BOB[y*SX+x]=pix(x,y)
  end
 end
end

function set(x0,y0,z)
 local y1=(SY-1)*z
 local x1=(SX-1)*z
 for y=0,y1 do
  for x=0,x1 do
  	local ys=((y/(y1+1))*SY)//1
   local c=BOB[((ys*SX)+(x/z))//1]
   if c>0 then
    local xd,yd=x0+x,y0+y
    local c=math.min(c+pix(xd,yd),15)
	  	pix(xd,yd,c)
			end
  end
 end
end

function drawText(t,x,y,s)
	print(t,x-1,y-1,0,false,s)
	print(t,x+1,y+1,0,false,s)
	print(t,x,y,12,false,s)
end

