-- Party at night city by water
-- by muffintrap for
-- Monday Night Byte jam 09/06/2025
S=math.sin
C=math.cos
PI=math.pi
W=240
H=136

elevation=0
rotation=0
speed=0.5
horizon=100

stars={}
for i=1,64 do
	stars[i]=math.random(0,H)
end
houses={}
for i=1,14 do
	houses[i]=math.random(20,60)
end

lights={}
for i=0,200 do
	lights[i]=math.random(0,4)
end

stepx=W/#stars
stepfft=1023/#stars
housew=W/#houses+2

function TIC()
	t=time()//32
	cls(0)

	rotation=rotation+0.1
	if rotation>W then rotation=0 end
	for s=1,#stars do
		dh = math.abs(horizon-stars[s])
		dh=dh/H	
		stars[s]=stars[s]-(0.1+speed*dh)
		if stars[s]<0 then
			stars[s]=H
		end

		x=stepx*(s-1)+rotation
		if x>W then x=x-W end

		y=stars[s]	
		lb=stepfft*(s-1)
		radius=fft(lb,lb+stepfft)/2
		
		if y<horizon then		
			circ(x,y,1+radius,3+lights[s])
			reflect=(horizon-y)/2
			circ(x,horizon+reflect,0.5+radius,3+lights[s])		

		end
	end
	
	--buildings
	housex=0
	for h=1,#houses do
		hx=housex
		hy=horizon-houses[h]
		hw=housew
		hh=houses[h]
		rect(hx,hy,hw,hh,14)
		
		wx=hx+1
		ww=(hw-4)/4
		wh=4
		light=(fft(0,20)/2)
		lightnumber=0
		for wy=hy+1,hy+hh-wh,wh*2 do
			for w=1,4 do
				color=lights[lightnumber]
				if color>0 then
			
				rect(hx+1+(w-1)*ww,
					wy,
					ww,wh,
					color+light)
				end
				lightnumber=lightnumber+1
			end
		end
		rect(hx,horizon,hw,hh/2,15)	
		housex=housex+housew
	end
		
	line(0,horizon,W,horizon,10)
end
