-- ~~~ Tinsel Greets ~~~
-- Violet (thanks for running)
-- Aldroid, ^ Suule, Nico
-- gasman, ToBach, Mantratronic :)

T=0
S=math.sin
C=math.cos
R=math.random
A=math.abs
PI=math.pi
Z=0
TREES={}
Y=0
BLINK=0
MAX_BLINK=30

function BDR(y)
	vbank(0)
	local r,g,b=25,40+y*2,255
	if y>72-Y*2 then
		local f=.9+((y-72)/68)*.1
		r,g,b=230*f,230*f,255*f
	end
	setRGB(15,r,g,b)
end

function setRGB(i,r,g,b)
	poke(16320+i*3,r)
	poke(16320+i*3+1,g)
	poke(16320+i*3+2,b)
end

function BOOT()
	vbank(0)
	setRGB(0,0,0,0)
	vbank(1)
	setRGB(1,0,0,0)
end

function TIC()
	vbank(0)
	cls(15)
	
	drawTrees()
	
	if (T%2==0) then
		local x=R(-30,30)
		if x<-.05 or x>.05 then
			-- don't make a crashable tree!
			addTree(x,0,Z+1)
		end
	end
	
	local tDeer=T/10
	drawDeer(120-40,85,1,false,tDeer)
	drawDeer(120+40,85,-1,true,tDeer+PI/2)
	
	-- Beard time
	for i=-5,5 do
		local x=120+i*30
		local y=100+C(i/5)*40
		circ(x,y,30,12)
		local y=24-C(i/5)*40
		circ(x,y+10,30,12)
	end
	for i=-5,5 do
		local x=120+i*30
		local y=28-C(i/5)*40
		circ(x,y,30,2)
	end

	Y=-5+S(T/100)*5
	
	T=T+1
	Z=Z+.005
	
	vbank(1)
	cls(1)
	if BLINK>0 then
		BLINK=BLINK-1
	elseif R(200)==1 then
		BLINK=MAX_BLINK
	end
	
	local h=60*(MAX_BLINK-BLINK)/MAX_BLINK
	elli(120-40,68,100,h,0)
	elli(120+40,68,100,h,0)
	elli(120,160,60,60,1)
end

function drawTrees()
	for i=1,#TREES do
		local t=TREES[i]
		if t.alive then
			drawTree(t)
		end
	end
end

function addTree(x,y,z)
	TREES[getNextTreeI()]={
		x=x,y=y,z=z,alive=true
	}
end

function getNextTreeI()
	for i=1,#TREES do
	 if not TREES[i].alive then
			return i
		end
	end
	return #TREES+1
end

function drawTree(t)
	local hu,hd,w=2.5,1,.8
	local xt,yt,zt=P(t.x,t.y-hu,t.z)
	local xbl,ybl,zbl=P(t.x-w,t.y+hd,t.z)
	local xbr,ybr,zbl=P(t.x+w,t.y+hd,t.z)

	-- cull the tree :(
	if zt<=0 or xbr<0 or xbl>240 then
		t.alive=false
		return
	end
	
	local ys=2	
	tri(xt,yt-ys,xbl,ybl-ys,xbr,ybr-ys,12)
	tri(xt,yt,xbl,ybl,xbr,ybr,6)
end

function drawDeer(x,yc,fl,rn,m)
	local y=yc-A(S(m))*10
	-- shnozz
	local yb=S(m+.6)*5
	elli(x+15*fl,y-15+yb,3,3,rn and 2 or 3)
	-- head
	elli(x+5*fl,y-15+yb,10,20,3)
	-- antlers??
	tri(x+5*fl,y-35+yb,x-20*fl,y-40+yb,x-15*fl,y-45+yb,7)
	tri(x+5*fl,y-35+yb,x+20*fl,y-40+yb,x+15*fl,y-45+yb,7)
	-- body
	local yb=S(m+.9)*10
	elli(x,y+yb,10,30,3)
	-- tail
	tri(x-3*fl,y-20+yb,x-3*fl-5,y-30+yb,x-3*fl+5,y-30+yb,12)
	-- front legs
	local yb=S(m+.6)*10
	rect(x+4*fl-4,y+2+yb,3,20,3)
	local yb=S(m+1.2)*10
	rect(x+4*fl+4,y+2+yb,3,20,3)
	-- back legs
	local yb=S(m+1.8)*10
	rect(x-5,y+13+yb,3,30,3)
	local yb=S(m+2.4)*10
	rect(x+5,y+13+yb,3,30,3)
end

function P(x,y,z)
	local zF=(z-Z)/3
	return 120+x/zF,68+(y-Y)/zF,zF
end