t=0
S=math.sin
R=math.random

for i=0,3 do
	poke(16320+i,0)
end

vbank(1)
for i=0,47 do
	poke(16320+i,i*5)
end
vbank(0)

function TIC()
	
	cls()
	
	for n=0,7 do
		dist = (n-t/9)%8
		for i=0,3 do
			poke(16323+i+n*3,-dist*32)
		end
	for g=0,1 do
		ang = (( ( 4.36+(n+t/9+g*67)//8)%(math.pi*2) )^2.32)
		
		slope = math.tan(ang)
		
		mult = 500*(1+dist*fft(0,63)/99)
		
		xc = 120+mult*S(ang-11)/dist
		yc = 68+mult*S(ang)/dist
		
		x0 = 0
		y0 = slope*(-xc)+68
		x1 = 240
		y1 = slope*(240-xc)+68
		line(x0,y0,x1,y1,n+1)
		
	end end
	
	vbank(1)
	
	if R()<.3 then
		circ(R()*240,R()*136,R()*8,R()*15+1)
	end
	
	for x = 0,1 do
	for y=0,135 do
		pix(16-x,y,1+(R()*ffts(0,y*6))%15)
	end
	end
	
	for l = 0,135 do
	
		shift = ( R()*3 + fft(l*3,l*3+2) )//1
		memcpy(l*120,l*120+shift,120-shift)
	
	end
	
	circ(240-R()*(4*fft(0,512)),R()*136,5,0)
	
	vbank(0)
	
	t=t+1
end