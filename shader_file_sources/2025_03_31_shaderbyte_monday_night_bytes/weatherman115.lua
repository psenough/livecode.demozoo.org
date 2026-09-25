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

for n=0,15 do
	setcolor(n,0,n*10,0)
end
vbank(1)
for n=0,15 do
	setcolor(n,n*10,0,0)
end

t=0
function TIC()
	
	local rot = {
		t/99,
		t/30,
		0}
	local p={}
	local pScale = 8
	
	for y=-8,8 do
		for n=0,7 do
			
			local pMod = math.sqrt(1-(y/8)^2)
			local x,z = unpack(rotate(9*pScale*pMod,0,y+n*math.pi/4))
			
			table.insert(p,rotate3d({x,y*pScale*1.1,z},rot))
			
		end
	end
	
	table.sort(p, function(a,b) return a[3]>b[3] end )
	
	for pass=0,1 do
		vbank(pass)cls()
		
		local p0 = {0,0,80}
		
		for _, point in pairs(p) do
			local projMod = (pass==0 and 1 or sin(_/9+t/64))
			local lx,ly,lz = unpack(point)
			
			lx = lx+p0[1]
			ly = ly+p0[2]
			lz = lz+p0[3]
			
			if lz > 0 then
			local col = lz/9
			
			lx = lx*projScale*projMod
			ly = ly*projScale*projMod
			
			if pass==1 then
				lrot = rotate(1,0,t/99)
				lx = lx * (1+lrot[1]^2)
				ly = ly * (1+lrot[2]^2)
			end
			
			lx = lx/lz + 120
			ly = ly/lz + 68
			
			lz = lz/projScale/projMod
			
			circ(lx, ly, 5/lz, col)
			end
		end
		
		for x=0,239 do
			
			y0 = 68+32*sin(x/99+t/99)*sin(t/99)*cos(t/64)-24
			y1 = y0+32
			
			if pass==0 then
				line(x,y0,x,y1,5)
			else
				line(x,y0-1,x,-1,0)
				line(x,y1+1,x,136,0)
			end
			
		end
		
	end
	
	print("happy trains day",0,128,15)
	vbank(0)
	
	for n=0,239 do
		line(n,136,n,136-8*(ffts(n*4,n*4+3)^.5)+1,4)
	end
	
	print("happy trains day",0,129,7)
	
	t=t+1
end