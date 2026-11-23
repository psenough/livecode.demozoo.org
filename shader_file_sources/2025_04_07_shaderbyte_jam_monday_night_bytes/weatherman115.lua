cos=math.cos
sin=math.sin
unpack = table.unpack

pal = "000000626262898989adadadffffff9f4e44cb7e756d5412a1683cc9d4879ae29b5cab5e6abfc6887ecb50459ba057a3"
for bank=0,1 do
vbank(bank)
for i=0,47 do
	poke(16320+i, (bank==0 and 1/2 or 1) * tonumber(pal:sub(i*2+1,i*2+2),16) )
end
end

function rotate(x,y,r)
	
	return {x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)}
	
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
function TIC()

	vbank(0)
	local px = 32*sin(t/99)*cos(t/64)
	local py = 0
	
	local yTable = {}
	for y=0,135 do
		yTable[y] = sin(y/8 + cos(8*(1-y/135)^2) + t/9)
	end
	
	local xTable={}
	for x=0,239 do
		xTable[x]=cos(x/8 + px)
	end
	
	for x=0,239 do
		local lx = xTable[x]
		for y=0,135 do
			pix(x,y,
			8*yTable[y] + lx )
		end
	end
	
	vbank(1)cls()
	local p={}
	
	
	for n=1,15 do
	
		local rot = {
		t/99/n*4,
		t/64/n*4,
		n}
	
		local circScale = (4.5+sin(t/99))*(n + fft(9,16)/4)
		angAmnt = 4*n
		for ang=0,angAmnt-1 do
			local x,y = unpack(rotate(circScale,0,2*math.pi*ang/angAmnt))
			
			local point = rotate3d({x,y,0},rot)
			point[4] = n
			
			table.insert(p, point)
		end
	end
	
	table.sort(p, function(a,b) return a[3]>b[3] end )
	
	local p0 = {0,0,30}
	
	for _, point in pairs(p) do
		local lx,ly,lz = unpack(point)
		
		lx = lx+p0[1]
		ly = ly+p0[2]
		lz = lz+p0[3]
		
		if lz > 0 then
		lx = lx*projScale
		ly = ly*projScale
		
		lx = lx/lz + 120
		ly = ly/lz + 68
		
		lz = lz/projScale
		
		circ(lx, ly, 3/lz, point[4])
		end
	end
	
	t=t+1
end