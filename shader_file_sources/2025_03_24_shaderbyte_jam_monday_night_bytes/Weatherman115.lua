cos=math.cos
sin=math.sin
unpack = table.unpack

function setcolor(num, r, g, b)

	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)

end

function rotate(x,y,r)
	
	return {x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)}
	
end

local function distance(p1,p2)
	return math.sqrt(
		(p2[1]-p1[1])^2 +
		(p2[2]-p1[2])^2 +
		(p2[3]-p1[3])^2
	)
end

function rotate3d(point3d,rot3d)
	
	local x0,y0,z0 = unpack(point3d)
	local rx,ry,rz = unpack(rot3d)
	
	local x1 = x0
	local y1,z1 = unpack( rotate(y0,z0,rx) )
	
	local y2 = y1
	local z2,x2 = unpack( rotate(z1,x1,ry) )
	
	local z3 = z2
	local x3,y3 = unpack( rotate(x2,y2,rz) )
	
	return({x3,y3,z3})
	
end

fov = 5
local projScale = 1/( math.tan( fov/2 * math.pi/180 ) )

t=0
fftSum = 0

setcolor(0,255,255,255)
blendVal=0.4
for i=3,47 do
	val=((i//3)-1)*30*(1-blendVal) + 255*blendVal
	poke(16320+i,val)
end
vbank(1)
setcolor(1,0,0,0)
setcolor(2,255,255,255)
vbank(0)

function TIC()
	
	vbank(0)
	cls()
	
	for i=0,99 do
		circ(120,68,100-i,6*fft(i))
	end
	
	vbank(1)cls()
	
	local p={}
	pNum = 5
	pScale = 10
	rot = t/99
	for x=-400,400 do
		local px = -400+(x+fftSum/8)%800
		local py = 24*sin(x+rot)+x*sin(x)
		local pz = 24*cos(x+rot)
		table.insert(p,{px,py,pz})
	end
	table.sort(p, function(a,b) return a[3]>b[3] end )
	
	local p0 = {0,0,40}
	local pLast = {999,999,999}
	local pLinePrev = {0,0}
	
	for _, point in pairs(p) do
		local lx,ly,lz = unpack(point)
		
		lx = lx+p0[1]
		ly = ly+p0[2]
		lz = lz+p0[3]
		
		local doLine = (pLast ~= 0 and distance(pLast,point) < 4*ffts(0,1023))
		pLast = point
		
		if lz > 0 then
			lx = lx*projScale
			ly = ly*projScale
			
			lx,ly = table.unpack(rotate(lx,ly,t/99))
			
			lx = lx/lz + 120
			ly = ly/lz + 68
			
			lz = lz/projScale
			
			circ(lx, ly, 5/lz, 1)--ly+lz)
			
			if doLine then
				line(pLinePrev[1],pLinePrev[2],lx,ly,1)
			end
		end
		
		pLinePrev = {lx,ly}
		
	end
	
	for x=0,239 do
		local y0=68 + 60*cos(x/99+t/32)*cos((x+t)/64)*cos(x/99)
		
		local range=math.abs(16*cos((x+t)/32))
		line(x,y0-range-2,x,y0+range+2,1)
		line(x,y0-range,x,y0+range,0)
	end
	
	t=t+1
	fftSum = fftSum+fft(0,1023)
end