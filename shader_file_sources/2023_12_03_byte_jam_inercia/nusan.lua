-- nusan here
-- gg aldroid! <3
r,s,abs,max=math.random,math.sin,math.abs,math.max
function fft(i) -- not realy
	return (s(i+t)+max(0,s(i*1.3+t*.7))+max(0,s(i*7.3+t*.3))+max(0,s(i*0.7+t*.3)))*.1
end
function av(c)
for j=0,20 do
	ts=10+30*math.min(1,fft(j+5)*5)
	t2=0.3+0.45*s(j+t*.3)+0.35*s(j*2+t*.2)
	b=j+t*.2+s(t*.1+j)+s(t*.07+j*.3)*2+fft(j)*4
	z,w=120+s(b+j*.13+t*.15)*70,68+s(b*.7+j*.2+t*.27)*40
	z,w=z+s(b*.3)*30,w+s(b*.4)*20
	z,w=z+s(b*1.2+j)*10,w+s(b*0.9+j)*10
	for i=-ts,ts do
		a=i/ts*2*3.1415+t+fft(j+3)*100
		x,y=z+abs(i),w+s(a)*ts*0.2
		line(x,y-ts*t2,x,y+ts*t2,max(c,((a/2)%4+j)%15+1))
	end
end
end
function TIC()t=time()/500
for x=0,1999 do
	a,b=r(240)-1,r(136)-1
	pix(a,b,pix(a,b)*.7)
end
print("INERCIA",r(240),r(136),15)
av(15)
end

function SCN(y)
for k=0,47 do
	poke(16320+k,k/3*15*(s(y/20+t*.2+k%3*.7)*.3+.7))
end
end

function OVR()
for k=0,47 do
	poke(16320+k,(1+k/3)*15*(s(k%3+t*.1+fft(k)*3)*.3+.7))
end
av(-15)
end
