--[[
muffintrap @ field-fx
monday night bytes
5.10.2026

I did my starfield stuff again
Let's go to space!
]]--

PI=math.pi
SIN=math.sin
COS=math.cos
W=240
H=132

-- Limit draw from min to max
function raising(rotation, c,minrot, maxrot)
	a = rotation
	astep = 0.2
	amount=12
	width=70
	for i=1,48 do
		angle = a+astep*i
		while angle > PI do
			angle=angle-(PI*2)
		end
		if angle > minrot and angle <maxrot then
			angle= angle +PI/2
			x = W/2 + SIN(angle) * 70
			y = -t + i * 8
			while y < 0 do
				y = y+H
			end
			r = 3 +COS(angle)*1.5
			circ(x, y, r, c)
		end
	end
end

stars={}
for i=1,20 do
	stars[i]={x=math.random(-30,30),y=math.random(0,H)}
end

linex={0,0,0,0, 0,0,0,0}
prev_x=0
function TIC()
	t=time()//32
	cls(0)
	-- Circles behind
	raising(t/20,9,  -PI/2,PI)
	-- Raising star streaks
	for i=1,#stars do
		sx=W/2+stars[i].x
		line(sx,stars[i].y-6,sx,stars[i].y,12)
		stars[i].y = stars[i].y-2
		if stars[i].y<0 then
			stars[i].x=math.random(-30,30)
			stars[i].y=H
			end
	end
	-- Rotating lines
	for i=0,7 do
		a=t/40
		ls=(PI*2)/8
		la=a+i*ls
		lx=W/2 - SIN(la)*(40+COS(t/20)*20)
		lc=12
		if (la%PI*2<PI)then
			lc=10
		end
		line(lx
			,0,lx,H,lc)
		prev_x=lx
		linex[i+1]=lx
	end

	--	horizontal lines
	for i=1,80 do
		ly= H/2 + SIN(i+t/50)* (H*0.75)
		line(
			linex[1+i%7], ly,
			linex[1+(i+1)%8],ly,12-(ly/40)%6)
	end
	-- Circles in front
		raising(t/20,11, -PI,-PI/PI/2)
end
