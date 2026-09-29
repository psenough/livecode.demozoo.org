s,t,r=math.sin,0,math.random
function po(u)
q,f=s(u*.3)*20,s(u*.4)*15
q,f=q+s(u*.6+t*.03)*70,f+s(u*.7+t*.02)*40
q,f=q+ju,f+jo
return q,f
end
function TIC()
ju,jo=s(t*.03)*13,s(t*.02)*10
t=t+fft(1)+fft(5)+0.03
for k=0,47 do
poke(0x3fc0+k,k//3*27*(s(k%3+t*.01)*.5+.5))
end
for i=1,9999 do
x,y=r(240)-1,r(136)-1
a=0.7+r()*.2
pix(x,y,pix((x-120)*a+120,(y-68)*a+68)*.5)
end
z=fft(2)>0.01 and 7 or 1
for i=1,2000 do
a=i*0.0125+t*.05
x,y=po(a)
o,p=po(a-0.5)
o,p=o-x,p-y
v=math.min(2+fft((a/4)%30)*40,z)
c=math.abs(i//20%16-8)+1
b=math.min(v*v*.03,3)
line(x-p*b+120,y+o*b+75,x+p*b+120,y-o*b+76,c+2)
circ(x+120,y+76,v,c)
if i>1000 and i<1100 then
circ(120+ju,76+jo,(fft(4)*60+10)*(9-(i//10)%10)*0.2,15+i)
end
end
end
