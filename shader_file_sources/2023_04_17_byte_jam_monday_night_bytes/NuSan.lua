p,r,mi,ma,s,t={},math.random,math.min,math.max,math.sin,0
cls()
for i=1,20 do
p[i]={x=r(240),y=r(136),u=0,v=0}
end
function TIC()
	for i=0,47 do
		poke(0x3FC0+i,(i//3)*15+(s(t/50+i%3+s(t/30+i%4))*60+60))
	end
	--rect(0,(t*5)%136,240,6,t%4+10)
	--rect((t*5)%240,0,6,136,t%6+8)
	for i=1,299 do
		a,b=r(240)+1,r(136)+1
		circ(a,b,2,ma(0,pix(a,b)*0.5))
	end
	for i=1,#p do
		c=p[i]
		g,h=10,3
		if fft(i*4)>0.03 and r(20)<2 then
			t=t+2
			c.u,c.v,g,h,b=r(10)-6,r(10)-6,15,10,r(60)+10
			circb(120,65,b,15)
			circb(120,65,b+1,15)
			circb(120,65,b+2,15)
			a,b=r(240),r(126)
			for j=1,10 do
				line(a,b+j,c.x,c.y,t%6+8)
			end
		end
		circ(c.x,c.y,h,g)
		c.u,c.v=c.u*0.95,c.v*0.95
		c.x,c.y=c.x+c.u,c.y+c.v
		n,m=ma(10,mi(230,c.x)),ma(10,mi(126,c.y))
		if c.x~=n then c.u=-c.u end
		if c.y~=m then c.v=-c.v end
		c.x,c.y=n,m
	end
end
