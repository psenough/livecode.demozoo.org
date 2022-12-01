-- hello inercia demoparty! <3
function TIC()t=time()/32
cls(15)
s=math.sin(t/79)
c=math.cos(t/69)
scale=(math.sin(t/99)+1)*8+9
for y=-31,31 do 
for x=-31,31 do
X=x*c-y*s
Y=x*s+y*c
z=scale
sx=math.sin(X/4+t/13)*8+4
sy=math.cos(Y/3+t/9)*8+4
circb(X*z+120,Y*z+68,sx,-((t/8+z)%8))
circ(X*z+120,Y*z+68,sy,8+((t/8+z)%8))
end end 
ty=math.abs(math.cos(t/4))*4
print("Don't forget to:",86,ty+10,0,2,1,1)
print("Don't forget to:",85,ty+8,10,2,1,1)
for i=0,3 do
print(" Human Feedback!",56-i,66-i,i,2,2,1)
end
print("Superogue at Inercia 2022",68,127,0,1,1,1)
print("Superogue at Inercia 2022",68,126,12,1,1,1)
end