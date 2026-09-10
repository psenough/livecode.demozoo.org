ma,mi,r,s,abs=math.max,math.min,math.random,math.sin,math.abs
cls()
function SCN(y)
for i=0,47 do
v=i//3*(s(i%3+t/15+y/50+i//3*0.6*s(t/50))*7+8)
if (t*2-abs(y-64))%120<30 then
v=mi(255,i//3*(s((i+(t/100)//3)%3+t/200+(abs(y-64)-t*4)//40%3)*0.5+0.5)*25)
end
	poke(0x3FC0+i,v)
end
end
uu=20
function TIC()t=time()/50
if t%20<1 then vo=r(140)+50 end
for i=0,3 do
if t%50<2 then
circ(vo,64,64,0)
end
if fft(i*3)>0.02 then
if t%100<50 then
	rect(r(240),r(136),r(30),r(30),15)
else
	circ(r(240),r(136),r(10),15)
end
if t%230<60 then
	line(r(240),r(136),r(240),r(136),15)
end
end
end
for i=0,3 do
if fft(r(20))>0.02 then
	circb(vo,64,r(64),15)
end
end
d=ma(s(t/7)*60-30,0)
for i=0,9999 do
x,y=r(240),r(136)
a=pix(x-1,y)+pix(x+1,y)+pix(x,y-1)+pix(x,y+1)
pix(x+d*(r()-0.5),y+d*(r()-0.5),mi(15,ma(pix(x,y)*0.5+a*0.125,0)))
end
if fft(1)>0.02 then uu=r(136) end
print("FieldFx",vo-50,uu,15,3,3)
end
