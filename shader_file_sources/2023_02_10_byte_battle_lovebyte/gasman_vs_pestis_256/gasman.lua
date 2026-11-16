m=math
s=m.sin
c=circ
function TIC()t=time()cls(8)rect(0,70,240,100,5)y=m.min(0,s(t/100))*15
c(150,50+y,25,4)for i=0,7 do
q=200+i*8
elli(q,70,10,20,15-i/3)c(190-i*4,90+i*8,15,i-t/100)
x=60+i%2*50
rect(x,90+y,8,40,0)c(60+i%4*20,60+y+i//4*20,25,12)
end
end
