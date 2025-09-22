-- Hello everyone !
-- So nice to be here <3

unpack=table.unpack
sin=math.sin
cos=math.cos
rnd=math.random

function ln(x1,y1,x2,y2,c)
	line(x1+px,y1+py,x2+px,y2+py,c)
end

function rot(x,y,a)
	return x*cos(a)+y*sin(a), x*sin(a)-y*cos(a)
end

function BOOT()
	t0={}
	t={}
	ly=11
	lx=11*2
	s0=10
	px=240/2
	py=136/2
	r=5
	T=0
	tr={}
	for y=0,ly-1 do
		for x=0,lx-1,2 do
			i=y*lx+x+1
			tr[i],tr[i+1]= rnd(r),rnd(r)
		end
	end
end

function TIC()
	T=T+1
	cls()
	sz=s0+fft(0,50)*.3
	for y=0,ly-1 do
		for x=0,lx-1,2 do
			i=y*lx+x+1
			t0[i]= -(lx/2-1)/2*sz + x/2*sz + tr[i]
			t0[i+1]= -(ly-1)/2*sz + y*sz + tr[i+1]
		end
	end
	-- rot1
	for y=0,ly-1 do
		for x=0,lx-1,2 do
			i=y*lx+x+1
			t[i],t[i+1]=rot(t0[i], t0[i+1], T/100)
		end
	end	
	-- rot2
	for y=1,ly-2 do
		for x=2,lx-3,2 do
			i=y*lx+x+1
			t[i],t[i+1]=rot(t0[i], t0[i+1], T/100+sin(T/50)*.5)
		end
	end	
	-- rot3
	for y=3,ly-4 do
		for x=6,lx-7,2 do
			i=y*lx+x+1
			t[i],t[i+1]=rot(t0[i], t0[i+1], T/100+sin(T/25)*3)
		end
	end	
	-- line
	for y=0,ly-1 do
		c=rnd(3)+2
		for x=0,lx-3,2 do
			i=y*lx+x+1
			x1,y1,x2,y2=unpack(t,i)
			ln(x1,y1,x2,y2,c)
		end
	end
	-- col
	for y=0,ly-2 do
		c=rnd(3)+8
		for x=0,lx-1,2 do
			i=y*lx+x+1
			x1,y1=unpack(t,i)
			i=(y+1)*lx+x+1
			x2,y2=unpack(t,i)
			ln(x1,y1,x2,y2,c)
		end
	end	
end
