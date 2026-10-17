sin=math.sin
cos=math.cos
min=math.min
max=math.max
rnd=math.random

function rotate(x,y,r)
	return x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)
end

vizGridBase={}
vizGridOut={}
vqtrVals={}

shiftVals = {1,119,121}

-- set up grid base
for n=0,119 do
	local x=n%12 - 5.5
	local y=n//12 - 4.5
	vizGridBase[n]={x,y}
end

-- clear color vals
for i=0,47 do
	poke(16320+i,128)
end

cls()
shiftVal=1
function TIC()

	vizGridRot = (time()*60/1000)/24
	vizGridScale = 2+sin(time()/1000)
	
	if rnd()<.01 then
		shiftVal = shiftVals[1+(rnd()*#shiftVals)//1]
	end
	
	for n=0,119 do
		vqtrVals[n]=vqts(n)
		-- since we're here
		local x,y = table.unpack(vizGridBase[n])
		x,y = rotate(x,y,vizGridRot)
		vizGridOut[n]={n,x,y}
	end
	
	table.sort(vizGridOut, function(a,b) return a[3]<b[3] end)
	
	-- render a
	memcpy(0,shiftVal,16320-shiftVal)
	for _,point in pairs(vizGridOut) do
		local n,x,y = table.unpack(point)
		-- scale
		x=x*vizGridScale
		y=y*vizGridScale
		-- shift
		x=x+240
		y=y+136
		line(x,y,x,y-vqtrVals[n]*64,1+(n)%15)
	end
end

function SCN(l)
	local colScale=1
	for i=0,15 do
		poke(16320+i*3,i==0 and 0 or 128+8*i*colScale)
	end
end