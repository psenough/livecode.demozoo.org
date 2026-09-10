function setcolor(num, r, g, b)

	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)

end

S=math.sin
C=math.cos
t=0

setcolor(0,0,0,0)
function SCN(l)
	local val=math.abs((l-67))+ 64*ffts(l*7,l*7+6)/4
	setcolor(1,val,val,val)
	
	for i=2,9 do
		setcolor(i,
			l+64*S(t/4 + ffts(i*16,i*16+15)/4)+t*4,
			192-l,
			i*(16 * 8*S(i+t/99) ))
	end
end

cam_z = 10
function TIC()
	
	cls(1)
	
	for x=-1,1,2 do
		for y=0,8 do
			rect(
				116+100*x,
				(y*16+t*4 + x*4)%(136+8)-8,
				8,8,
				2+(y+4)%8
			)
		end
	end
	
	for i=0,1023 do
	 local li = i/8
		x=120+(60+60*math.sqrt(fft(i)))*C(t+li + math.pi)
		y=68+60*S(t+li/(2+S(t/32)/16))
		circ(x,y,math.max(S(t+li)*8,0)*(1+fft(i)),2+i%8)
	end
	
	t=t+.1
end