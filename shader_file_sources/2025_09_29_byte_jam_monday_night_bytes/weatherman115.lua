-- pos: 0,0
sin=math.sin
cos=math.cos
rnd=math.random

vqtTable={}

for i=0,47 do
	poke(16320+i,i*5)
end

local function dist(x0,y0,x1,y1)
	return ( (x1-x0)^2 + (y1-y0)^2 )^.5
end

local function rotate(x,y,r)
	return x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)
end

cls()

function TIC()
	
	t=time()*60//1000
	
	for n=0,119 do
		vqtTable[n]=vqts(n)
	end
	
	vbank(1)
	if t>2 then circ(circX,circY,circR,0) end
	
	circX=120+120*sin(t/24+cos(t/32))//1
	circY=64+64*cos(t/24+4*sin(t/99)*sin(t/74))//1
	circR=24+8*cos(t/37)*sin(t/47)//1
	trailRot=t/20
	
	vbank(0)
	
	for y=circY-circR-1,circY+circR do
		for x=circX-circR-1,circX+circR do
			
			if dist(x,y,circX,circY) <= circR then
				pix(x,y,16*vqtTable[( (x+t)~(y+t) )%120])
			end
			
		end
	end
	
	vbank(1)
	
	circ(circX,circY,circR,0)
	circb(circX,circY,circR,12)
	
	for xSide=-1,1,2 do
		for ySide=-1,1,2 do
		
			local xTrail,yTrail = rotate(circR*xSide,circR*ySide,trailRot)
			xTrail = xTrail
			yTrail = yTrail
			
			if rnd()<.1 then
				for n=1,10 do
					pix(
						circX+xTrail+4*rnd(),
						circY+yTrail+4*rnd(),
						12
						)
				end
			end
			
		end
	end
	
end