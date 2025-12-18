--Hi from Roeltje!
sin,cos=math.sin,math.cos
rnd=math.random
min,max=math.min,math.max

cls()
function TIC()
	vbank(0)
	local t=time()/1000
	for y=0,135 do
		for x=0,239 do
			c=pix(x+rnd(-1,1),y)
			--if rnd()<0.1 then c=max(c-3,0) end
			if rnd()<0.001 then c=c~10 end
			if rnd()<0.05 then c=0 end
			pix(x,y,c)
		end
	end
	
	for i=0,50 do
	tt=t+i*.05
	x=120+sin(tt*1.33)*sin(tt*0.55)*60
	y=68+sin(tt*0.88)*sin(tt*0.54)*40
	r=8+sin(tt*2)*7
	circ(x,y,10+r,10+((i+t)%10))
	end
	
	vbank(1)
	cls()
	local dy=sin(t*10)*2
	print("Hello Evoke!",23,59+dy,2,false,3)
	print("Hello Evoke!",25,60+dy,4,false,3)
end