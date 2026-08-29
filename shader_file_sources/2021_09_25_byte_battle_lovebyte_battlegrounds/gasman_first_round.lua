function TIC()t=time()
m=math
s=m.sin
c=m.cos
b=t/600
z=120
circ(z+30*s(b),64+70*c(b),100,t/100)
circ(z,30,15,4)
circ(z,50,20,4)
x=z
y=70
for i=0,10 do
tri(115+i%2*10,10,z,20,110+i%2*20,20,4)
circ(x,y,5,4)
a=m.sin(t/300)
x=x+5*s(a*i)
y=y+5*c(a*i)
end
end