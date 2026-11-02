r,s=math.random,math.sin
p=0
function SCN(j)
for k=0,47 do
	poke(0x3fc0+k,k/3*16*(s(t*1+k%3*2+((k+j/30+t*.2)%48>24 and 2 or 0)+(k%7)*p-j/220)*.5+.5))
end
end
function OVR()
for k=0,47 do
	poke(0x3fc0+k,k/3*16*(s(t*1+k%3*2)*.2+.8))	
end
for i=0,300 do
	a=t*7+i/100
	a=a+s(t*.7+a*.4)*.5+s(t*4.7+a*.3)*.3
	x,y=s(a)*70,s(a*.3)*40
	x,y=x+s(a*.3)*30,y+s(a*0.7)*20
	x,y=x+s(a*1.3)*20,y+s(a*1.2)*10
	si=6+s(a*1.7)*4+s(a*.7)*3
	circ(x+120,y+78,si,i/20)
	if i>0 then
		line(x+120,y+78,px+120,py+78-si*2,15)
		line(x+120,y+78,px+120,py+78+si*2,15)
	end
	px,py=x,y
end

end
d,q,u=0,0,1
function TIC()t=time()/1000
d,q,u=(d+r(3)-2)*.95,(q+r(3)-2)*.95,((u+(r(3)-2)*.005)-1)*0.99+1
p=math.max(0,s(t/15)*.5)*20
tr=9999
t3=t*2.3
if s(t3*.7)*s(t3*1.3)>0.2 then
	tr=0
end
for i=0,tr do
	x,y=r(240)-1,r(136)-1
	pix(x,y,pix((x+d)*u,(y+q)*u)*.9)
end
t2=t*10
for i=0,1 do
	x,y=r(240),r(136)
	rect(x,y,r(20),r(20),15)
	if s(t2)*s(t2/1.7)*s(t2/2.6)>0.1 then
		line(x,y,120,78,15)
		circb(120,78,r(60),15)
	end
end
if s(t2*.7)*s(t2*1.3)>0.1 then
for i=0,10 do
	circ(r(240),r(136),8,10)
end
end
end
