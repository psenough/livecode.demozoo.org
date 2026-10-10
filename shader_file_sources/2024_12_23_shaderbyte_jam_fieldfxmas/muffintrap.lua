SW=240
SH=132
S=math.sin
C=math.cos
T=3.1456345*2

function bauble(bx,by,c)
	br=20
	circ(bx,by,br,c+1)
	circ(bx-1,by-1,br-1,c)

	circ(bx-6,by-6,6,12)
	rect(bx-5,by-br*2+12,10,10,4)
	circb(bx,by-br*2+12,7,4)
end

function star(lx,ly,lr)
	a=t/60
	as=T/12
	
	for i=0,12 do
		rx=lx+S(a+i*as)*lr
		ry=ly+C(a+i*as)*lr
		rx2=lx+S(a+(i+0.4)*as)*lr
		ry2=ly+C(a+(i+0.4)*as)*lr

		--pix(rx,ry,12)
		--pix(rx2,ry2,12)
		c=12
		if i%2==0 then c=11 end
		tri(lx,ly,rx,ry,rx2,ry2,c)
	end
end

function tree()
for i=0,1 do
		br=i*30
		by=i-20
		circ(SW/2,SH/2-by,125-br,7)--branch
		circ(SW/8-24,0-SH/3-by,150-br,0)
		circ(SW/2+SW/2,0-SH/3-by,150-br,0)
	end
end

function pointy(lx,ly,lr)
	a=t/60
	as=T/12
	
	for i=0,12 do
		ext=(lr*2+S(a*12+i)*lr/2)
		rx=lx+S(a+i*as)*ext
		ry=ly+C(a+i*as)*ext
		rx2=lx+S(a+(i+0.4)*as)*ext
		ry2=ly+C(a+(i+0.4)*as)*ext

		--pix(rx,ry,12)
		--pix(rx2,ry2,12)
		c=4
		--if i%2==0 then c=11 end
		tri(lx,ly,rx,ry,rx2,ry2,c)
	end

end

function TIC()
	t=time()//32
	cls(0)
	
	tree()
	
	-- Yellow main star
	pointy(SW/2+4,6,20)
	
	-- stars?!
	lx=SW/2+4
	ly=6
	lr=60
	a=t/120
	as=T/120
	fs=1023/120
	scs={4,12,11,9,10,9,10,9,10}
	for o=0,8 do
		s=1-(o%2)*2
		for i=0,120 do
			fi=i*fs
			rx=lx+S(s*a+i*as)*(lr+o*10)
			ry=ly+C(s*a+i*as)*(lr+o*10)
			pix(rx,ry,scs[o+1])
		end
	end
	
	
	by=0--SH/2
	bca={2,10,5}
	for i=1,10 do
		bx=SW/4+S(t/60+i*5)*SW/2
		c=bca[1+i%3]

		bauble(bx+i*20,-20+(by+t+i*20)%(SH+70),c)
	end

	lx=SW/2
	ly=SH/2
	for i=0,12 do
			fi=i*10
		star((0+t+i*20)%SW,
		(ly+S(t/100+i*10)*60)%SH,

		12+fft(fi,fi+10)*6)
	end


end
