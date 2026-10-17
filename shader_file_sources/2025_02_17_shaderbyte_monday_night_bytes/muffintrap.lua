S=math.sin
C=math.cos
TAU=math.pi*2
PI=math.pi
angle=0
CX=120
CY=68
fx=0

function TIC()t=time()//32

cls(0)
print("muffintrap", 10,10,12, true)
for i = 1,time()//200%4 do
	print(".", 10+7*8+(i*8), 10, 12, true)
end
lineL =fft(1,20)
line(10,20,10+lineL*10,20,12)



for l=0, 10 do
	txt = ""
	for add=0, fft(l,l+20)*5 do
		txt = txt .. "A"
	end
	print(txt, 10, 20+l*8, 3+l%5, false)
end

twistCX=120
twistW=80
twistSpeed=0.005
angle=angle+twistSpeed
while angle>=TAU do
	angle=angle-TAU
end

tw=40+C(t/50)*20
th=40+S(t/50)*20
inc=PI/2.0

if btnp(0) then
	fx=(fx+1)%6
end


for h=0,120 do
	y=20+h
	a=angle+h/100
	b1x=S(a)
	b2x=S(a+inc*1)
	b3x=S(a+inc*2)
	b4x=S(a+inc*3)
	b5x=S(a+inc*5)
	b6x=S(a+inc*6)

	b1y=C(a)
	b2y=C(a+inc*1)
	b3y=C(a+inc*2)
	b4y=C(a+inc*3)
	b5y=C(a+inc*5)
	b6y=C(a+inc*6)
	
	xa={b1x,b2x,b3x,b4x,b5x,b6x}	
	ya={b1y,b2y,b3y,b4y,b5y,b6y}	

	for i=1,4 do
		left=i
		right=i+1
		
		if right > 4 then
			right=1
		end
		
		-- Collection of borked twisters
		
		-- This makes a pseudo 3D
		-- ring with 4 notches on the rim
		if fx==0 then
		rx=50
		ry=40
		line(rx+xa[left]*tw,
				ry+ya[left]*th,
				rx+xa[right]*tw,
				ry+ya[right]*th,
				3+i)
		end

		-- This is kind of a tube
		if fx==1 then
		tx=100
		ty=-20
		line(tx+CY+ya[left]*th,
				ty+CY+xa[left]*tw,
				tx+CY+ya[right]*th,
				ty+CX+xa[right]*tw,
				8+i)
		end
	


			-- This is the diamond
			-- patterned torus-like
			-- thing going horizontally
		if fx==2 then
			try=30
			line(0,--CX+xa[left]*th,
				try+CY+ya[left]*(30),
				240,--CX+xa[right]*th,
				try+CY+ya[right]*(30),
				1+i)
		end
		if fx==3 then
			-- Same but vertically
			line(CX+xa[left]*tw,
				0,--CY-40+S(angle)*50,--CY+ya[left]*tw,
				CX+xa[right]*tw,
				130,--CY+40+C(angle)*50,--130,--CY+ya[right]*tw,
				12+i)
		end

		-- Almost a twister
				if fx==4 then
		line(40+xa[left]*15,y,
		40+xa[right]*15,y,
		8+i)
		end

		
	-- Twister
		if fx==5 then
			if xa[left]<xa[right] then
			line(80+CX+xa[left]*20,y,
				80+CX+xa[right]*20,y,
				2+i)		
		
			end
		end

	end
end


print("Greets to jtruk <3", 10, 120, t)

end
