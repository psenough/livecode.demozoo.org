-- pos: 0,0
rnd=math.random
unpack=table.unpack
cos=math.cos
sin=math.sin

function BOOT()
	t={}
	s=10
	tw=20
	th=10
	x0=240//2
	y0=136//2
	T=0
	-- init mat
	for y=0,th-1 do
		for x=0,tw-1,2 do
			t[y*tw+x+1]=-(tw/2-1)/2*s + x/2*s
			t[y*tw+x+2]=-(th-1)/2*s + y*s
		end
	end
end

function ln(x1,y1,x2,y2,c)
	line(x1+x0,y1+y0,x2+x0,y2+y0,c)
end

function rot(x1,y1,x2,y2,a)
	return
		x1*cos(a)+y1*sin(a),
		x1*sin(a)-y1*cos(a),
		x2*cos(a)+y2*sin(a),
		x2*sin(a)-y2*cos(a)
end

function msg(f)
	txt={
		"Love jam",
		"Love Revision",
		"Love people",
		"\\o/",
	}
	m=txt[f%#txt+1]
	x=x0-#m*9
	y=60
	vbank(1)
	cls()
	print(m,x-1,y-1,12,0,3)
	print(m,x,y,8+fft(0,50)%4,0,3)
end

function star()
	for i=0,30 do
		pix(rnd(240),rnd(136),12)
	end
end

vbank(0)
cls()
function TIC()
	T=T+1
	r=T/100+fft(0,50)*.03
	msg(T//100)
	vbank(0)
	-- NuSan's cls <3
	for i=0,3000 do
		pix(rnd(240),rnd(136),0)
	end
	star()
	-- horz
	for y=0,th-1 do
		for x=0,tw-3,2 do
			x1,y1,x2,y2=unpack(t,y*tw+x+1)
			x1,y1,x2,y2=rot(x1,y1,x2,y2,r)
			ln(x1,y1,x2,y2,rnd(8))
		end
	end
	-- vert
	for y=0,th-2 do
		for x=0,tw-1,2 do
			x1,y1=unpack(t,y*tw+x+1)
			x2,y2=unpack(t,(y+1)*tw+x+1)
			x1,y1,x2,y2=rot(x1,y1,x2,y2,r)
			ln(x1,y1,x2,y2,rnd(4)+2)
		end
	end
end
