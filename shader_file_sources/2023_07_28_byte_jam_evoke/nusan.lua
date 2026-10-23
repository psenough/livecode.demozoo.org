s,t,r=math.sin,0,math.random
cls()
function TIC()
t=t+0.005+fft(1)*0.15
if fft(3)>0.6 then
	rect(0,0,240,136,15)
end
ui=(t*40)%68
rect(0,68+ui,240,2,15)
rect(0,68-ui,240,2,15)
for i=0,47 do
	poke(0x3FC0+i,i//3*15*(s(i%3+t)*0.5+0.5 +i//12))
end
for i=0,5 do
circ(s(t+i)*80+120,68,fft(i+1)*40,t*10)
end
te=r(6)
if fft(2)>0.1 then
for i=0,1999 do
a,b=r(240)-1,r(136)-1
rect(a-te,b,te*2,1,pix(a+r(3)-2,b+r(3)-3)*0.99+0.02*s(t))
end
end
for i=0,15 do
o=t+i*0.2
x,y=s(o*3.2)*80+120,s(o+s(o)+s(o*2))*40+68
if i>1 then
	line(x,y,u,v,i)
	line(x,y,w*2-x,z*2-y-10,i)
	line(x,y,u*2-x,v*2-y-10,i)
end
w,z=u,v
u,v=x,y
end
end
