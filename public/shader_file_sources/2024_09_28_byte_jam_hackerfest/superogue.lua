-- Superogue at  Hackfest 2024
for i=0,47 do poke(16320+i,math.sin(i/15)*200)end
function TIC()
f=fft(0)*320
f2=fft(1)*320
t=time()/32+f2/40
cls(0)
angle=t/40
s=math.sin(angle)c=math.cos(angle)
for y=-31,31 do 
for x=-31,31 do
cz=(x*x+y*y)^.5
z=math.sin((cz+t))*f/32+5
u=x*c-y*s
v=x*s+y*c
az=math.abs(v-32)+.1
ax=u*32/az
ay=199/az

k=(x&y&(t)//4)
h=((x*2)&(y*2)&t//2)
X=(ax*z)+120
Y=(ay*z)+68-h-(z/2%64)
circ(X,Y,ay/4,-(k%6))
end end 
ty=64+math.sin(f2/8)
for i=0,3 do
print("HACKFEST 2024",71,ty+1-i,i,1,2,1)
print("HACKFEST 2024",70,ty-i,2+i,1,2,1)
end
for i=0,136,2 do
line(0,i,240,i,0)
end
print("superogue",106,128,t/8,1,1,1)
end