t=0S=math.sin
A=table.insert
R=rect
function TIC()cls()for i=0,4e4 do x=i%240y=i/240o=4*S(x+y+t/99)pix(x,y,o<0 and 0or 12+o)end
for i=0,536 do I=i//4 circ(7+(I%15)*16,7+((I//15)%135)*16,7-i%3,1+(i+t/30-i/16)%3)end
R(60,8,120,120,0)
for i=0,31 do
P={}for j=0,3 do A(P,68+60*S(i+j//(.5+.25*S(t/60))+t/60)+52*(1-j%2))end A(P,10+(i+t/8)%2)line(table.unpack(P))
p=t+i*16+99*S(i+t/(60-i)*S(i))
R(p%256-16,(p+i)%164-16,7,7,8+i%4)
r=(i+t/15)/5
circ(120+80*S(r+t/60),68+80*S(r),8,6+i%4)
end
t=t+1
end