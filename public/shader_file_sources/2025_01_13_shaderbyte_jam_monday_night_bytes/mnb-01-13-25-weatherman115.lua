t=0
v=vbank
S=math.sin
A=table.insert
function SCN(l)
	for i=0,47 do
		poke(16320+i,(i//(3.5+S((t-l)/60)))*96)
	end
end

function TIC()
	
	for i=0,4e4 do
		x=i%240
		y=i//240
		d=((240-x)^2+(136-y)^2)^.5
		if x>32 or y<104 then
			pix(x,y,d>64+50*S(d) and x&y//32+x//99 or d/8)
		else
			v(1)
			pix(x,y,x+y+S(y+t/2))
			v(0)
		end
	end
	p={}
	for n=0,5 do
		A(p,60*(S(t/60+n)+1+S(t/60)))
	end
	A(p,15)
	tri(table.unpack(p))
	for i=1,5,2 do
		line(p[i],p[i+1],p[i],0,2)
	end
	t=t+1
end