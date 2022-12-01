function TIC()t=time()/333
m=math.sin(t)
for j=10,1,-1 do
circ(120,68+m*20,j*30,(j+t/50)%4)
end
for x=0,8 do for y=0,7 do
l=40/((x-3)^2+(y-4)^2)^0.5
for i=0,4 do
z=20+l+m*10
rect(x*60+i+10*m,y*70+i,z,z,i>3 and 7+(l*t/30)%4 or 4)
end end end
end