-- pos: 0,0
sin=math.sin
cos=math.cos
acos=math.acos
asin=math.asin
rnd=math.rnd

PI = math.pi
TAU = PI*2

zScaleShift = 4
polarResolution = 256

tFR = 0

for i=0,47 do
	poke(16320+i,i*5)
end

fxTable = {
	function(r,t) return (r+t)&(t) end,
	function(r,t) return (r+t)|(r-t) end,
	function(r,t,z) return math.min(r~(t%256)+z,255-((t%256)//256)^3) end,
	function(r,t,z) return (r-t+z)~(z-t-r) end,
	function(r,t,z) return (t%256<1) and 0 or 1-math.max(8*(r&t),t%256) end
}

local function polarForm(r,z,scale)
	
	local vOut = fxTable[1+(t//256)%#fxTable](r,t,z)
	-- 1+(t//256)%#fxTable
	
	local dOut = 1-(255&( vOut ))/255
	r = TAU*r/polarResolution
	
	local xOut = 119.5 + 67.5*scale*cos(r)*dOut
	local yOut = 67.5 + 67.5*scale*sin(r)*dOut
	
	return xOut,yOut
	
end

function TIC()
	
	t=time()*60//1000
	
	cls()
	for z=63,0,-1 do
		
		local zScale = zScaleShift/(z+zScaleShift)
		
		x0,y0 = polarForm(0,z,zScale)
		for ang=1,polarResolution do
			
			x1,y1 = polarForm(ang,z,zScale)
			line(x0,y0,x1,y1,16-z/4)
			x0=x1
			y0=y1
			
		end
		
	end
	
	tFR = tFR+1
	
end