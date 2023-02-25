a=0
x=120
y=68
px = x
py = y
dd = 1
t = 0
ini = 0
steps = 0
f = 0

function forward(d)
	x=x+dd*(math.cos(a)*d)
	y=y+dd*(math.sin(a)*d)
end

function rotate(angle,pos)
	local sign = pos and 1 or -1
	a = a + sign*angle
end

function aa()
	return math.abs(math.cos(time()*0.01)*time()*0.01)
end

function rr()
	for i=0,steps do

		rotate(aa(),false)
		
		forward(8)
		circ(x,y,math.cos(aa())*fft(i)*20,15)
		line(px,py,x,y,math.abs(aa()/4)+1)

		px = x
		py = y
		if x < 0 then x = 120 px = x dd = -dd end
		if x > 240 then x = 120 px = x dd = -dd end

		if y < 0 then y = 68 py = y dd = -dd end
		if y > 136 then y = 68 py = y dd = -dd end
		
	end
end

ff = 0

function TIC()
	t=time()*0.01
	t = math.floor(t)
	if (ini == 0) then cls(0) ini = 1 end
	
	steps = 64
	
	rr()
	f=f+1
	if(f%4 == 0) then
		local xo=0
		local yo=0
		
		if ff==0 then
			xo = 0
			yo = 0
		end

		if ff==1 then
			xo = 1
			yo = 1
		end

		if ff==2 then
			xo = 1
			yo = 0
		end

		if ff==3 then
			xo = 0
			yo = 1
		end

	 ff = ff + 1
		ff = ff % 4
		
		for y=xo,136,2 do
			for x=yo,240,3 do
				g = pix(x,y)
				if (g > 0) then g=g-1 end
				pix((x&y+t),(t/2%4)+t/3)
				pix(x,y,g)
			end
		end
	
	end

	print("LOVEBYTE",0,0,1)

	zz = math.cos(t*0.1)*16
	for yy=0,4 do
	for xx=0,48 do
		cc = pix(xx,yy)
		circ(xx*8-58+math.sin(t*0.1)*72,math.cos(t*0.1+xx*0.1)*32+zz+48+yy*8-1,3,cc*((xx+8)/8))
	end
	end	

	print("LOVEBYTE",0,0,0)

	memcpy(0,1,(240*68)-1)

end

function scanline(row)
if (row % 3 == 1 and row > 8) then
	poke(0x3FF9,math.cos(row/4*t*0.1)*2)
end
end