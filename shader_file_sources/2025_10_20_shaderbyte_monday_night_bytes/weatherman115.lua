-- pos: 6,82
sin=math.sin
cos=math.cos
rnd=math.random
atan2=math.atan2
sqrt=math.sqrt

for i=0,47 do
	poke(16320+i,i*5)
end

vbank(1)

poke(16326,255)

modA = 17
modB = 19
xShift = 0
yShift = 0

drawWarning = false

function TIC()
	
	t=time()*60/1000
	tInt=t//1
	
	xShift = xShift + 16*(rnd()-.5)
	yShift = yShift + 16*(rnd()-.5)
	
	vbank(0)
	
	local columnShake = rnd()<.3 and (rnd()-.5)*2 or 0
	for x=0,239 do
		
		ang = 4*math.asin( (x-119.5)/239*math.pi/2 )
		
		val = math.max(16*sin(ang+t/16+columnShake),0)
		line(x,0,x,135,val)
		
	end
	
	if rnd()<.025 then
		modA=1+rnd()*64
	end
	
	if rnd()<.025 then
		modB=1+rnd()*64
	end
	
	local xShake = 8*(rnd()-.5)
	local yShake = 8*(rnd()-.5)
	for y=0,63 do
		for x=0,63 do
			
			if (x+(xShift//1)~y+(yShift//1)+tInt)%modA>(x|y&tInt)%modB then
				pix(x+88+xShake,y+36+yShake,15-pix(x+88,y+36))
			end
			
		end
	end
	
	blankLines = rnd()<.2
	blankLinesList = {}
	if blankLines then
		
		local blankProb = rnd()*.75
		
		for y=0,239 do
			if rnd()<blankProb then
				line(0,y,239,y,0)
				table.insert(blankLinesList,y)
			end
		end
		
	end
	
	vbank(1)
	
	if t%32<16 then
		if not drawWarning then
			warnString = rnd()<.005 and "URGENT: code trapped but can't bleed!" or "URGENT: code bleeding but can't shutdown!"
		end
		print(warnString,0,130,2)
		drawWarning = true
		
		if blankLines then
			
			for i, y in pairs(blankLinesList) do
				line(0,y,239,y,0)
			end
			
		end
		
	else
		cls()
		drawWarning = false
	end
	
end