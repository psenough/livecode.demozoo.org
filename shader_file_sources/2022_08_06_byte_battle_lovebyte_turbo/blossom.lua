t=0
function TIC()t=t+1
for y=0,136 do for x=0,240 do
p=x/88-1.3
q=y/66-1
c=p/q-t/9
a=p*p+q*q-1-math.sin(t/9)/2
pix(x,y,a^3<-p*p*q*q*q and 2 or c%2)
end end end