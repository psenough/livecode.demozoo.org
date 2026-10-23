S=math.sin
C=math.cos
R=math.random

function setcolor(num, col)
	
	local r,g,b = table.unpack(col)
	
	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)

end

	setcolor(0, {0,0,0})

vbank(1)
for i=0,47 do
	poke(16320+i,i*5)
end
vbank(0)

function PRNG(n)
	return (1.32+n/9)^5.2
end

local rInner = 20
local rOuter = 10

t=0
function TIC()
	
	dy = ( 99*S(t/99) )%16
	for y=0,152,8 do
		dx = ( 99*C(t/99) )%16
		for x=0,248,8 do
			if R()<.1 then rect(x-dx,y-dy,8,8,(x/8+y/8)%2) end
		end
	end
	
	vbank(1)
	
	for x=0,239 do
		for y=0,135 do
			pix(x,y,math.max(0,pix(x,y+1)-1))
		end
	end
	
	local dl = 0
	for n=0,15 do
		local d = 16*S(t/99+n) + ( (PRNG(n))%128 ) + rInner
		local x0 = 120+d*C(n+t/64)
		local y0 = 60+d*S(n+t/64)
		circ(x0,y0,4*S(d),d)
		dl = d
	end
	
	for b=0,1023 do
		local d=rOuter*math.sqrt(ffts(b))
		local ang = b/1024*math.pi*2 + t/64
		local x0,y0 = 
			120+rInner*C(ang),
			68+rInner*S(ang)
		local x1,y1 = 
			120+(rInner+rOuter*d)*C(ang),
			68+(rInner+rOuter*d)*S(ang)
		line(x0,y0,x1,y1,15)
	end
	
	vbank(0)
	
	t=t+1
end

function SCN(l)
	l = (135-l)/2 + 32
	setcolor(1, {l/( 1.2+.5*S(l/200+t/200)^2 ),l/2,l} )
end