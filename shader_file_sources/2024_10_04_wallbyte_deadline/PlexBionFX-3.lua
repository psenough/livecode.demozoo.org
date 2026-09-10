t=0
r=240
w=32639
cx=0
cy=0
function TIC()
	cls()
	for i=0,w do
	 x=i%r
		y=i//r
	 poke4(i,
		math.sin((x^2+y^2)^.5/2+x/37+t/53+math.sin(y/19+t/47)*9)
  +math.sin(y/27+t/31+math.sin(x/17+t/43)*7)
		+i%.7)
	end
	cx=math.sin((t+25)/23)*48
	cy=math.sin((t+25)/37)*28
	print("Deadline 2024",120-80+cx,68+cy-5,12,33,2)
	print("Plex was here",120-80+cx+60,68+cy+7,13,33,1)
	t=t+1
	cx=math.sin(t/23)*48
	cy=math.sin(t/37)*28
	for i=0,r do
		centerLine(i-120,-68,i/3%8+8)
		centerLine(i-120,68,i/3%8+8)
	end
	for i=0,135 do
		centerLine(-120,i-68,i/3%8+8)
		centerLine(120,i-68,i/3%8+8)
	end
end

function centerLine(xx,yy,col)
 dx=math.sin(yy/12+xx/23+t/17)*12
 dy=math.sin(xx/13+yy/22+t/13)*12
	line(xx+120,yy+68,xx/1.5+120+cx+dy,yy/4+68+cy+dx,col+(xx+yy)%.7)
end