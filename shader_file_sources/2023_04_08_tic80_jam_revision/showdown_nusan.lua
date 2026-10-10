-- pos: 0,0
s,r,p=math.sin,math.random,math.pow
function TIC()t=time()//32
for i=0,40+s(t/10)*60 do
	rect(0,r(136)-1,240,1,0)
end
for i=0,4 do
	--circb(120,64,r(140),r(16))
	c=r(70)
	rectb(120-c,64-c,c*2,c*2,r(16))
end
for i=0,100 do
	t2=t*2+i/2+s(t/5)*1
	x,y=s(t2/5)*s(t2/5)*s(t2/5)*80+120, s(t2/8)*s(t2/8)*s(t2/8)*40+64
	c=s(t/12+i/30)*8+8
	circ(x,y,c*0.3,i/60+t/9)
	--circb(x,y,c*2,i/60+8+t/9)
	rectb(x-c,y-c,c*2,c*2,i/60+8+t/9)
end
for i=0,-10+20*s(t+s(t)) do
	rect(r(240),r(136),r(40),r(40),t/6)
end
end
