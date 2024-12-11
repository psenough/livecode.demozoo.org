t=0
t1=0
sin=math.sin
cos=math.cos
pi=math.pi
max=math.max
s=sin
function tris(x,y,l,an,c)
	--line(240/2,136/2,240/2+l*cos(an),136/2+l*sin(an),4)
	tri(x,y,
				 x+l*cos(an-pi/6),y+l*sin(an-pi/6),
					x+l*cos(an+pi/6),y+l*sin(an+pi/6),
					c)
	tri(x,y,
				 x+l*cos(an+3*pi/6),y+l*sin(an+3*pi/6),
					x+l*cos(an+5*pi/6),y+l*sin(an+5*pi/6),
					c)

		tri(x,y,
				 x+l*cos(an+7*pi/6),y+l*sin(an+7*pi/6),
					x+l*cos(an+9*pi/6),y+l*sin(an+9*pi/6),
					c)
end


function BOOT()
cls(0)
for i=1,240+136 do
line(0,i,i,0,(i%8)*2+1)
end
end
function TIC()
vbank(0)
ff=fft(10,30)/0.7
for j=3,47 do
 poke(16320+j,(((j+t1*1.8)%48/48)^(ff))*255)
end
t1=t1+1
vbank(1)
for j=0,45 do
 poke(16320+j,s(j+t/100)^2*255)
end
--cls(0)
for i=0,5000 do
pix(math.random(0,240),math.random(0,135),0)
end
 f=fft(5,30)
	t=t+max(f/2,0.2)
	num=8
	for i=1,num do
	 f=0--fft(255//num*i,255//num*(i+1))
		an=t/(10*i)
		l=20+10*(num-i)
	 tris(240/2+sin(t/i/8)*20,
							80-f*10+cos(t/i/10)*40*sin(t/1000),
							l,an,
	 i*3+t/100)
 end

 for i=1,15 do
	 h=10
 	tri(0,h*i,
      0,h*(i+1),
      h*fft((i-1)*10,(i-1)*10+10),h*i+h/2,i)
  tri(240,h*i,
      240,h*(i+1),
      240-h*fft((i-1)*10,(i-1)*10+10),h*i+h/2,i)

 end

end
