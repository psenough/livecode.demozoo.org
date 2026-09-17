-- the cat thing
-- by PotcFdk at Evoke 2025

local Y,X=144,256

local function dist(x1,y1,x2,y2)
	return math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2))
end

local CB={}
local function CBs(x,y,c)
	CB[y*X+x]=c
end

local function CBg(x,y)
	return CB[y*X+x] or 0
end

local function CBa(x,y,c)
	CBs(x,y,CBg(x,y)+c)
end

local function CBdraw(thres)
	for y=0,Y do
		for x=0,X do
			local c = CBg(x,y)
			if c > thres then
			  pix(x,y,CBg(x,y))
			end
		end
	end
end

local function c(x,y,s,c)
	for _y=0,Y do
		for _x=0,X do
		 local C=pix(_x,_y)
			if dist(x,y,_x,_y)<s then
				CBa(_x,_y,c)
			end
		end
	end
end


local mx=30
local my=60
local myy=my-25

local L ={
	{X/2-48,Y/2+20,X/2,Y/2+myy},
	{X/2-50,Y/2+30,X/2,Y/2+myy},
	{X/2-48,Y/2+40,X/2,Y/2+myy},
	
	{X/2+48,Y/2+20,X/2,Y/2+myy},
	{X/2+50,Y/2+30,X/2,Y/2+myy},
	{X/2+48,Y/2+40,X/2,Y/2+myy},
	
	{X/2-1,Y/2+myy,X/2-1,Y/2+myy+20},
	{X/2,Y/2+myy,X/2,Y/2+myy+20},
	{X/2+1,Y/2+myy,X/2+1,Y/2+myy+20},

	{X/2,Y/2+myy+20,X/2+10,Y/2+myy+25},
	{X/2,Y/2+myy+20+1,X/2+10,Y/2+myy+25+1},
	{X/2,Y/2+myy+20+2,X/2+10,Y/2+myy+25+2},

	{X/2,Y/2+myy+20,X/2-10,Y/2+myy+25},
	{X/2,Y/2+myy+20+1,X/2-10,Y/2+myy+25+1},
	{X/2,Y/2+myy+20+2,X/2-10,Y/2+myy+25+2},

}

local tmx=90
local tmx2=160
local tmy=15

local T ={
	{X/2,Y/2+myy/2,X/2-10,Y/2+myy,X/2+10,Y/2+myy,13},
	{tmx,tmy,tmx-10,tmy+15,tmx+10,tmy+15,13},
	{tmx,tmy+2,tmx-10,tmy+15+2,tmx+10,tmy+15+2,0},
	{tmx2,tmy,tmx2-10,tmy+15,tmx2+10,tmy+15,13},
	{tmx2,tmy+2,tmx2-10,tmy+15+2,tmx2+10,tmy+15+2,0}
}

local SKA=14

function TIC()
	local t=time()*.001
	cls()
	CB={}
	--c(X/2,30,100,2)
	c(mx+X/2+math.sin(t*2)*SKA,my,SKA,3)
	c(mx+X/2+math.sin((t+15.55)*2.172)*SKA,my,SKA,4)
	
	c(mx-60+X/2+math.sin(t*2)*SKA,my,SKA,3)
	c(mx-60+X/2+math.sin((t+15.55)*2.172)*SKA,my,SKA,4)
		
	CBdraw(3)
	
	for _,l in next, L do
		line(l[1],l[2],l[3],l[4],13)
	end
	
	for _,t in next, T do
		tri(t[1],t[2],t[3],t[4],t[5],t[6],t[7])
	end
	
	print("$ cat /dev/evoke/by-year/2025\nrIIIIAr\n\n$",10,5,12,false,1)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>