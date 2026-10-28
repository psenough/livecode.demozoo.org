--meow meow meow meow 
--meooooooooooooooooow?
--it me 
--the missing cat 
--been meowing but nobody answer
--pls lemme back
--need noms

sin=math.sin
cos=math.cos
abs=math.abs
rand=math.random

-- Greeeeeeeeeetz! To:
-- tobach, jtruk, gasman, d33kou, 
-- pumpuli, aldroid + lynn
-- and "and you" whoever that is

function bkg()
	-- 15 x 8 @ 16x17
	vbank(0)
	cls(8)
	--for x=0,29 do
		--for y=0,16 do
		 --rect(x*8,y*8,8,8,rand()*16)
		--end
	--end
	
	for i=0,1000 do
	 local x=rand()*240
	 local y=rand()*136
		local r=rand()*5+3
		local c=rand()*8+7
		wcirc(x,y,r,c-2)
		wcirc(x-1,y-2,r-2,c)
	end	
	
	for i=0,47 do
	 poke(16320+i,i*5*(i%3==1 and 1 or 0.5))
	end
	memcpy(0x4000,0,16320)
end

function wcirc(x,y,r,c)
 elli(x,y,r,r*.7,c)
 if x-r<0 then
 	elli(x+240,y,r,r*.7,c)
  
	 if y-r<0 then
		 elli(x+240,y+136,r,r*.7,c)
		end
	 if y+r>136 then
		 elli(x+240,y-136,r,r*.7,c)
		end
 end
 if x+r>240 then
	 elli(x-240,y,r,r*.7,c)
		
	 if y-r<0 then
		 elli(x-240,y+136,r,r*.7,c)
		end
	 if y+r>136 then
		 elli(x-240,y-136,r,r*.7,c)
		end
 end
 if y-r<0 then
	 elli(x,y+136,r,r*.7,c)
	end
 if y+r>136 then
	 elli(x,y-136,r,r*.7,c)
	end
end

function fkg()
	-- 15 x 8 @ 16x17
 vbank(1)
	--for x=0,14 do
		--for y=0,8 do
		 --rectb(x*16,y*17,16,17,rand()*15)
		--end
	--end
	
	for i=0,30 do
	 local x=rand()*240
	 local y=rand()*136
		local r=rand()*20+10
		local c=rand()*6+10
		wcirc(x,y,r,c-2)
		wcirc(x-1,y-2,r-2,c)
	end
	
	for i=0,47 do
	 local s=i>24 and 1 or 
			(i%3==0 and 1.2 or i%3==1 and 1 or 0)
	 poke(16320+i,i*5*s)
	end
	memcpy(0x4000,0,16320)
end

t=0
sx=0
sy=0
dx=1
dy=0

bkg()
fkg()

function r2d(p,a)
 local ca=cos(a)
 local sa=sin(a)
 return {
  x=ca*p.x+sa*-p.y,
  y=ca*p.y+sa*p.x
 }
	--p=cos(a)*p+sin(a)*-p.y,p.x
end

function TIC()
	vbank(0)
	--cls()
	--memcpy(0,0x4000,16320)
	--for i=0,12 do 
		--print("=^^=",
		 --5+sin(t*2+i/8)^3*15,
			--40+sin(t*1.7+i/8)^3*15,i,0,10)
	--end
	
	poke(0x3FF9,sx%240-120)
	poke(0x3FFa,sy%136-68)
	
	t=t+.03
	vbank(1)
	cls()
	memcpy(0,0x4000,16320)
	
	--local cx=sx*3%240
	--local cy=sy*3%136
	--wcirc(cx-25,cy-25,10,7)
	--wcirc(cx+25,cy-25,10,7)
	--wcirc(cx,cy,40,5)
	--wcirc(cx,cy+10,15,15)
	--wcirc(cx,cy+0,15,5)
	--wcirc(cx-14,cy-10,7,15)
	--wcirc(cx+14,cy-10,7,15)
	--wcirc(cx-14,cy-10,3,1)
	--wcirc(cx+14,cy-10,3,1)
		
	poke(0x3FF9,sx*2%240-120)
	poke(0x3FFa,sy*2%136-68)
	
	sx=sx+dx
	sy=sy+dy
	local d=r2d({x=dx,y=dy},sin(t/2)^7*0.05)
	dx=d.x dy=d.y
end
