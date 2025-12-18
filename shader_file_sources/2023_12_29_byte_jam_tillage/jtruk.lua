-- Greets:
-- MrsBeanbag, gasman, Suule
-- Polynomial
-- Crypt, Reality
-- All tillers!

M=math
R,PI,S,C,A,MIN,MAX=M.random,M.pi,M.sin,M.cos,M.abs,M.min,M.max
TAU=2*PI
SEGS=20
TURNCHANCE=.05
ADDCHANCE=.05
TURN=.05
WORMS={}
cls()

PATT={}

function BOOT()
	for i=1,15 do
		local f=i/15
		local r=160*f
		local g=82*f
		local b=45*f
		setRGB(i,r,g,b)
	end

	vbank(1)
	for i=1,15 do
		local f=i/15*.25+.75
		local r=255*f
		local g=204*f
		local b=255*f
		setRGB(i,r,g,b)
	end

	vbank(0)
	cls(1)
	for i=0,10 do
		print("TILLAGE-FX",6+R(120),3+i*12,3,false,2)
	end
	for y=0,135 do
		for x=0,239 do
		 PATT[y*240+x]=pix(x,y)
		end
	end

	cls()
	drawMud()
end

T=0
function TIC()	
	if R()<ADDCHANCE then
		addWorm()
	end

	moveWorms()	

	vbank(0)
	munchWorms()
	
	vbank(1)
	cls()
	drawWorms()
		
	T=T+1
end

function drawMud()
 for y=0,135 do
	 for x=0,239 do
		 local c=13+R()*2
			pix(x,y,c)
		end
	end
	local txt="Then t'worms'll come an' eyt thee oop"
	local x,y=20,128
	print(txt,x+1,y+1,10)
	print(txt,x,y,5)
end

function addWorm()
	local i=getNextWorm()
	local r=R(0,3)
	local x,y,a=0,0,0
	if r==0 then
		a=0
		x=math.random(220)+10
	elseif r==1 then
		a=PI*.5
		y=R(116)+10
	elseif r==2 then
		a=PI
		x=R(220)+10
		y=136
	elseif r==3 then
		a=PI*1.5
		x=240
		y=R(116)+10
	end

	worm={
		s={},
		a=a,
		aim=a,
		t=0,
		alive=true,
	}
	worm.s[1]={x=x,y=y}
	for i=2,SEGS do
		-- Offscreen somewhere
		worm.s[i]={120,120}
	end

	WORMS[i]=worm
end

function moveWorms()
	for i=1,#WORMS do
		local w=WORMS[i]
		w.t=w.t+1
		if R()<TURNCHANCE then
			w.aim=w.a+(R()-.5)*PI*2
		end
		
		local aDiff=w.a-w.aim
		if aDiff<0 then
			w.a=w.a-aDiff*TURN
		elseif aDiff>0 then
			w.a=w.a-aDiff*TURN
		end		

		local si=1+(w.t%#w.s)
		local sl=1+((w.t-1)%#w.s)
		local d=A(S(w.t*.2))*2.5
		local seg={
			a=w.a,
			x=w.s[sl].x+S(w.a)*d,
			y=w.s[sl].y+C(w.a)*d,
		}
		if (seg.x<-40 or seg.x>280 or seg.y<-40 or seg.y>176) then
			w.alive=false	
		end

		w.s[si]=seg
	end
end

function drawWorms()
	for i=1,#WORMS do
		local w=WORMS[i]

		local iSegs=MIN(#w.s,w.t)
		for i=1,iSegs do
			local seg=w.s[i]
			local c=1+((i-w.t)%#w.s)%15
			circ(seg.x,seg.y,3+S(i)*1,c)
		end

		local ish=1+(w.t%#w.s)
		circ(w.s[ish].x,w.s[ish].y,4,1)
	end
end

function munchWorms()
	for i=1,#WORMS do
		local w=WORMS[i]
		local si=1+((w.t-1)%#w.s)
		local s=w.s[si]
		local width=1.5

		for i=-width,width do
			local digx=(s.x+C(w.a)*i)//1
			local digy=(s.y-S(w.a)*i)//1
			if digx>=0 and digx<=239 and digy>=0 and digy<=135 then
				local a=PATT[digx+digy*240]
				pix(digx,digy,MAX(pix(digx,digy)-a,a))
			end
		end
	end
end

function getNextWorm()
	for i=1,#WORMS do
		if not WORMS[i].alive then
			return i
		end
	end
	
	return #WORMS+1
end

function setRGB(i,r,g,b)
	poke(16320+i*3,r)
	poke(16321+i*3,g)
	poke(16322+i*3,b)
end