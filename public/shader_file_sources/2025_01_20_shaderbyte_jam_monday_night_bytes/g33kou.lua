-- hello fellow coders :)

rnd=math.random

px={
1,1,0,0,0,1,0,0,0,1,1,
1,0,0,0,1,0,1,0,0,0,1,
0,0,0,1,0,0,0,1,0,0,0,
0,0,1,0,0,0,0,0,1,0,0,
0,1,0,0,0,0,0,0,0,1,0,
1,0,0,0,0,0,0,0,0,0,1,
0,1,0,0,0,0,0,0,0,1,0,
0,0,1,0,0,0,0,0,1,0,0,
0,0,0,1,0,0,0,1,0,0,0,
1,0,0,0,1,0,1,0,0,0,1,
1,1,0,0,0,1,0,0,0,1,1,
}

max=0
t=0
cls()

function TIC()
	t=t+1
	for i=0,max do
		y=i//11
		x=i%11
		if px[i+1]==1 then
			circ(60+x*12,8+y*12,5,12)
		else
			circ(60+x*12,8+y*12,5,rnd(1,10))
		end
	end
	if t%4==0 then
		max=max+1
	end
	if max==121 then
		max=0
		cls()
	end
end
