sin=math.sin
cos=math.cos

function setColor(col)
	local max = col/15
	local min = max/2
	for n=0,2 do
		poke(16320+3*col+n,255*(math.random()*(max-min)+min))
	end
end

for col=1,15 do
	setColor(col)
end

function TIC()
	t=time()*60/1000
	
	for n=1,15 do
		if math.random()<.05 then
			setColor(n)
		end
	end
	
	cls()
	
	for x=0,239,8 do
		for y=16,135+16,8 do
			
			cap=15*(ffts((x+(y-16)*17)/8)^.7)
			for dy=0,cap do
				circ(x+4,y-dy,3,dy==0 and 0 or dy%15+1)
			end
			
		end
	end
	
	local thump=ffts(9,16)/4
	barPos={
	sin(t/23+thump),
	sin(t/25+thump),
	sin(t/27+thump)
	}
	
	for i=1,3 do
		barPos[i]=barPos[i]/2+.5
	end
	
end

function SCN(l)
	
	local width = ffts(0,1023)
	local posMin = width
	local posMax = 135-width
	
	for i,colPos in pairs(barPos) do
		
		colPos = colPos*(posMax-posMin)+posMin
		
		local val= math.max(0,255*(width-math.abs(colPos-l))/width)
		
		poke(16320+i-1,val)
		
	end
	
end