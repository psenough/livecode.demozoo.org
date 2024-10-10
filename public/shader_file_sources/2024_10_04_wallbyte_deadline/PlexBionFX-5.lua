t=0
cls()
function TIC()
	t=t+1
	p1=math.sin(t/27)^2*55+1
	p3=math.sin(t/21)^2*55+1
	p2=math.sin(t/13)^2*12+3
	for i=0,32639 do
	x=i%240-120
	y=i//240-68
	for i=0,11 do
	x=x+y/p1
	y=y-x/p3
	end
	poke4(i,(((x*y))/(11+p2*4))/16%4+3)
	end
end