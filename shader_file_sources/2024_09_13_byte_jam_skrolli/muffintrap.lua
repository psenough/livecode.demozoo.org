S=math.sin
C=math.cos

l=60
rot=0
sign=1
bw=40
bwx=0
bwy=0
function TIC()
cls(0)
t=time()//32
rot=rot+0.01
	rx=S(rot+t*0.01)*l
	ry=C(rot+t*0.01)*l*2
	

fftw=20
for fb=0,68,6 do
	RANGE=fft(fb,fb+6)
		rect(120-RANGE*fftw,
		fb*2+bwy*0.5,
		RANGE*2*fftw,10,10)
end

x=120
y=68
	sign=1--sign*-1
	rx=rx*sign
	ry=ry*sign
	bwx=bw*S(t*y*0.001)
	bwy=bw*C(t*y*0.002)
	
	for lx=0,240,60 do
		tri(lx,0,
		bwy+lx+bwx,136,bwy+lx+bwx+10,136,
		(t//10))
	end
	
	for ukkox=bwx, 240,50 do
		circ(ukkox+S(t/4)*2-1,85-1, 7, t//10)
		circ(ukkox+S(t/4)*2,85, 6, 8)
		circ(ukkox+S(t/10)*fft(0,6)*4-1,100-1, 9,t//10)
		circ(ukkox+S(t/10)*fft(0,6)*4,100, 8,8)
		circ(ukkox,120,11,t//10)
		circ(ukkox,120,10,8)

	end
	
	line(bwx/rx+x,bwy+y,
		x+rx,y+ry,(x+t)>>4)
		
	line(bwx+x,bwy+y,
		x+ry,y+rx,(y+t)>>4)
		
		circb(x+ry,y+rx,6+fft(0,10)*20,(x+t)>>4)
		circb(x+rx,y+ry,6+fft(0,10)*20,(x+t)>>4)
	
	for cx=0,240,4 do
		rect(bwx+cx,
		0+C(t*cx*0.05),
		4,S(t*cx*0.005)*20,
		cx)
	end

	for cx=0,240,4 do
		rect(bwx+cx,
		130-C(t*cx*0.05)*2,
		4,C(t*cx*0.005)*20,
		cx)
	end

end
