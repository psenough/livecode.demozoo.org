-- hello lovebyte 2024!
-- - vurpo

m=math
pi=math.pi
f={}

s=60

for i=0,15 do
 poke(16320+3*i,(15-i)*16)
 poke(16320+3*i+1,m.max(0,(15-i)*18-128))
 poke(16320+3*i+2,(15-i)*10)
end

cls(16)
function circle(c,s,r1,r2,f,r,color)
 for i=0,s-1 do
  tri(c.x,c.y,
   c.x+(r1+r2*f[i])*m.sin((i+r)/(s/pi)),
   c.y-(r1+r2*f[i])*m.cos((i+r)/(s/pi)),
   c.x+(r1+r2*f[i+1])*m.sin((i+1+r)/(s/pi)),
   c.y-(r1+r2*f[i+1])*m.cos((i+1+r)/(s/pi)),
   color)
  tri(c.x,c.y,
   c.x-(r1+r2*f[i])*m.sin((i+r)/(s/pi)),
   c.y+(r1+r2*f[i])*m.cos((i+r)/(s/pi)),
   c.x-(r1+r2*f[i+1])*m.sin((i+1+r)/(s/pi)),
   c.y+(r1+r2*f[i+1])*m.cos((i+1+r)/(s/pi)),
   color)
 end
end

function TIC()
	t=time()//32+m.sin(time()/100)*4
	for y=0,63 do for x=0,119 do
		pix(
		 x,
			y,
			pix(
			 ((x-119)*0.9)+120,
				((y-62)*0.95)+63
			)+1
		)
		end
	end
	for y=136,63,-1 do for x=0,119 do
		pix(
		 x,
			y,
			pix(
			 ((x-120)*0.9)+120,
				((y-63)*0.95)+63
			)+1
		)
		end
	end	for y=0,63 do for x=240,120,-1 do
		pix(
		 x,
			y,
			pix(
			 ((x-119)*0.9)+120,
				((y-62)*0.95)+63
			)+1
		)
		end
	end
	for y=136,63,-1 do for x=240,120,-1 do
		pix(
		 x,
			y,
			pix(
			 ((x-120)*0.9)+120,
				((y-63)*0.95)+63
			)+1
		)
		end
	end
	for i=0,s do
	 temp=0
		if f[i-3] ~= nil then
		 temp=temp+f[i-3]*0.2
		end
		if f[i-2] ~= nil then
		 temp=temp+f[i-2]*0.2
		end
		if f[i-1] ~= nil then
		 temp=temp+f[i-1]*0.2
		end
	 temp=temp+fft((i+3)/2)
		f[i]=temp
	end
	circle({x=120,y=68},s,30,45,f,-t,1)
	circle({x=120,y=68},s,20,45,f,-t,4)
	circle({x=120,y=68},s,15,45,f,-t,12)
	circle({x=120,y=68},s,8,35,f,-t,16)
end
