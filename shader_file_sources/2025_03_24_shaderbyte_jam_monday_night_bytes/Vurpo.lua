m=math

r0=30
text="Field-FX beats to livecode and jam to"
text_w=0
function BOOT()
	text_w=print(text,0,0,0)
	cls()
end
function TIC()
	t=time()/1000
	cls(8)
	for i=0,50 do
		x=m.random()*250
		y=m.random()*150
		line(x,y,x-5,y-20,9)
	end
	clip(120-r0-1,0,r0*2+2,136)
	print(text,121+r0-(t*45)%(r0*2+text_w),66,0)
	print(text,120+r0-(t*45)%(r0*2+text_w),65,12)
	clip()
	for i=0,1,0.01 do
		c0=-m.sin(6.2832*i)
		s0=-m.cos(6.2832*i)
		c1=-m.sin(6.2832*(i+0.01))
		s1=-m.cos(6.2832*(i+0.01))
		r1=r0+10+60*fft(i*100)
		r2=r0+10+60*fft(i*100+1)
		color=(i*0.96+t/5)*50
		tri(
			120+c0*(r0-2),
			68+s0*(r0-2),
			120+c0*(r1+2),
			68+s0*(r1+2),
			120+c1*(r2+2),
			68+s1*(r2+2),
			0)
		tri(
			120+c0*(r0-2),
			68+s0*(r0-2),
			120+c1*(r2+2),
			68+s1*(r2+2),
			120+c1*(r0-2),
			68+s1*(r0-2),
			0)
		tri(
			120+c0*r0,
			68+s0*r0,
			120+c0*r1,
			68+s0*r1,
			120+c1*r2,
			68+s1*r2,
			color)
		tri(
			120+c0*r0,
			68+s0*r0,
			120+c1*r2,
			68+s1*r2,
			120+c1*r0,
			68+s1*r0,
			color)
	end
end