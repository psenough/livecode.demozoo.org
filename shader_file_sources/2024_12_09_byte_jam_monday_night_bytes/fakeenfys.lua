-- FAKE ENFYS HERE!
-- Apparently I gotta make trams
-- Greetz: Violet, Reality, Tina
-- Gasman, Pumpuli, Alia, G33kou
-- Especially jtruk
-- And YOU!

local M=math
local S,A=M.sin,M.abs
local T=0
local CAMX=0
local YB=0

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BDR(y)
	vbank(1)
	local v=1-((y-YB-90)/40)
	rgb(1,255*v,0,0)
	rgb(2,255*v,128*v,0)
	rgb(3,255*v,255*v,0)
	rgb(4,0,255*v,0)
	rgb(5,0,128*v,255*v)
	rgb(6,0,0,255*v)
	rgb(7,128*v,0,255*v)
	
	vbank(0)
	if y>60 then
		v=(y-60)/100
		rgb(0,0,255*v)
	else
		v=.3+y/60
		rgb(0,20*v,40*v,60*v)
	end
end

function TIC()
 CAMX=240-(T%500)

 local x=CAMX
 YB=-A(S(T*.1))*3
 local yb2=-A(S(T*.1)+.3)*3
 local yTrain=50
	local h=50

	vbank(1)
	cls()
 drawTram(x,yTrain+YB,h)

	vbank(0)
	cls()
	poke(0x3ffb,0)
	drawBG(T)
	drawPeople(x,yTrain+yb2)

	vbank(1)
 enfys(x,yTrain+YB,240,h*.7,x,YB)

 print("FakeEnfys",185+1,127+1,14)
 print("FakeEnfys",185,127,12)
 T=T+1
end

function drawBG(t)
	for i=0,100 do
	 local seed=((i^5.4)+(i^3.2))%100
		local size=1+seed/30
		local x=(seed*50+t)%300-30
		local y=40+size*10
		local w=3*size
		local h=10*size
		local c=5+seed%3
		tri(x-w,y,x+w,y,x,y-h,c)
	end
end

function drawTram(ox,oy,h)
	for x=0,4 do
		local winX=10+ox+x*40
		drawLine(winX+10,oy)
	end

	rect(ox,oy,220,h,15)
	for x=0,4 do
		local winX=10+ox+x*40
		rect(winX,oy+10,35,20,0)
	end

	if (T//500)%2==0 then
		print("TRAMS RIGHTS",ox+44,oy+h*.76,12,false,2)
	else
		print("ENFYS EXPRESS",ox+40,oy+h*.76,12,false,2)
	end
end

function drawPeople(ox,oy)
	for x=0,4 do
		local winX=10+ox+x*40
		drawPerson(winX+7,oy+20,T+1,1,x)
		drawPerson(winX+28,oy+20,T+3,-1,4+x*2)
	end
end

function drawLine(ox,oy)
	line(ox+10,oy,ox-10,oy-10,10)
	line(ox-10,oy,ox+10,oy-10,10)
end

function drawPerson(ox,oy,c,f,i)
	local y=oy+A(S(c)*3)
	circ(ox-f*1,oy-2,6,15-i)
	circ(ox,oy,6,4)
	circ(ox+f*6,oy,2,4)
	circ(ox+f*2,oy-2,2,12)
	circ(ox+f*3,oy-2,1,11)
	circ(ox+f*6,oy+2,1,13)
end

function enfys(x0,y0,w,h,xsh,ysh)
	for y=y0,y0+h do
		for x=x0,x0+w do
			local c=pix(x,y)
			if c==15 then
				pix(x,y,1+((x-xsh)//5+(y-ysh)//5)%7)
			end
		end
	end
end