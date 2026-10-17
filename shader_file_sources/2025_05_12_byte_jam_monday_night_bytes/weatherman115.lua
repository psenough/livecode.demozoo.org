sin=math.sin
cos=math.cos
unpack=table.unpack

copyLength=0x2000

for i=0,47 do
	poke(16320+i,i*i/3)
end

function rotate(x,y,r)
	return {x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)}
end

local function pointGet(x,y)
	
	
	x=x-4
	y=y-4
	local bx,by=x,y
	
	local pScale=1*(12+4*cos(t/16))
	x=x*pScale
	y=y*pScale
	
	x=x+8*cos(by+t/10)*sin(t/9)
	
	x,y=unpack(rotate(x,y,t/27+(x+y)/99))
	
	x=x+48*cos(t/24)
	y=y+24*sin(t/20)
	
	return {
		x+120,y+68
	}
end

cls()
function TIC()
t=time()*60/1000

memcpy(0x6000,0,copyLength)
rect(0,0,64,64,0)
xLast=32+32*cos(t/9)
yLast=32+32*sin(t/9)
for n=0,31 do
	local x=32+32*cos(t/(9+n))
	local y=32+32*sin(t/(9+n/2))
	line(xLast,yLast,x,y,n)
	xLast=x
	yLast=y
end
for i=0,127 do
	for ly=0,7 do -- local y on screen
		memcpy(16384+4*ly+32*i,ly*120+4*(i%8+i//8*120),4)
	end
end

memcpy(0,0x6000,copyLength)
if math.random()<.1+.05*sin(t/99) then
	for py=0,135 do
		for px=0,239 do
			pix(px,py,math.max(pix(px,py)-1,0))
		end
	end
end
x=0
y=0
for ty=0,7 do
	for tx=0,7 do
		local x1,y1=unpack(pointGet(tx,ty+1))
		local x2,y2=unpack(pointGet(tx+1,ty))
		for i=0,1 do
			local x0,y0=unpack(pointGet(tx+i,ty+i))
			ttri(
				x0,y0,
				x1,y1,
				x2,y2,
				
				(tx+i)*8,(ty+i)*8,
				tx*8,ty*8+8,
				tx*8+8,ty*8,
				
				0,0)
		end
	end
end


end
