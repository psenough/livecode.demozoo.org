-- pos: 0,0
t=0
sin=math.sin 
cos=math.cos

x=50
y=50

function TIC()


cls(13+2*sin(t*0.5) )

t = t+0.1
sz = 50

x1 = 50+sz*sin(t*2.3454)
y1 = 50+sz*cos(t*3.1232)

for i=0,16 do
	line(x1+sz*i*sin(i+t),
	 y1+sz*cos(i+t) ,
	x1+sz*i*0.1*sin(i+t+0.4),
	 y1+sz*i*0.1*cos(i+t+0.4), i)
		
	circ(x1+30*sin(i*t),y1+30*cos(i*t+t),10,10+t%4)
end


print("Hello Revision", (t*10)%300-50, 10+10*sin(t), 12, false, t%4)

end