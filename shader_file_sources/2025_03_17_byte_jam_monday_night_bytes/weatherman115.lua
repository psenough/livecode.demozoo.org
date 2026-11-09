cos=math.cos
sin=math.sin
unpack = table.unpack

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

local pBase = {}
pNum = 5
pScale = 100

pNumMin = -(pNum/2 - .5)
pNumMax = pNum/2 - .5

for x = pNumMin,pNumMax do
for y = pNumMin,pNumMax do
for z = pNumMin,pNumMax do

	table.insert(pBase,
		{x*pScale,
		 y*pScale,
		 z*pScale}
		)

end end end

for bank=0,1 do
vbank(bank)
for i=0,47 do
	poke(16320+i, ((i* (bank==0 and 25 or 5) )%256)*(bank==0 and 1 or 1) )
end
end

t=0
function TIC()
	
	vbank(0)
	
	local px = 4*cos(t/9 + sin(t/16))
	local py = sin( (t/16 + 4*cos(t/16)) )
	for x=0,239 do
		for y=0,135 do
			pix(x,y,12+ ( math.atan2(
			sin(y/8 + py ),
			cos(x/8 + px ))*4 )+t/9)
		end
	end
	
	vbank(1)
	cls()
	
	local rot = {
		t/30,
		t/50,
		t/20}
	local p={}
	
	for _, point in pairs(pBase) do
		table.insert(p, rotate3d(point,rot))
	end
	
	table.sort(p, function(a,b) return a[3]>b[3] end )
	
	circ(120,68,25,1)
	for n=0,119 do
		fftv = (ffts(n))*16
		line(n,43-fftv,n,94+fftv,1)
	end
	rect(0,43,120,51,1)
	
	local p0 = {0,0,350}
	for _, point in pairs(p) do
		local lx,ly,lz = unpack(point)
		
		lx = lx+p0[1]
		ly = ly+p0[2]
		lz = lz+p0[3]
		
		lz = lz^(1/2)
		
		lx = lx/lz + 120
		ly = ly/lz + 68
		
		if lz > 0 then
		circ(lx, ly, 10/lz*3, 14)
		circ(lx, ly, 10/lz, _%12)
		end
	end
	
	t=t+1
end