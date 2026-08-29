-- Machen wir party?
-- Fixing your post-party depressions
-- since 2021...
-- superogue 17/4/2023
t=1
for i=0,47,3 do poke(16320+i,i)end
function SCN(l)
poke(16323,l/2)
end
function TIC()
cls(1)
f=(fft(0)+fft(1))*7+.5
f2=fft(2)*9
f0=fft(0)*9
t=t+f
P=t//64
for z=99,1,-.5 do 
for x=0,240 do
h=math.abs(x*2*z)//99~(z+t)//1 
if (P&8>0) then
h=math.abs(x*2*z)//99&(z+t)//1 
end
if (P&16>0) then
h=math.abs(x*2*z)//99|(z+t)//1 
end
if (P&2>0) then
h=h~z//4 
end
X=math.cos(x/99+f0)*8+31
k=7+z/11
ch=93-math.abs(math.sin(t/64)*8)+math.sin((t+x)/96)*8
circ(x,64*(ch-h%128)/z+X,1,k)
end end
for l=-136,480,2 do
line(0,l,240,l,t/32%3-1)
--line(l,0,l,136,1)
--line(l,0,l+240,240,1)
end

--if (P&1>0) then
print("<3",3,5,0,1,1,1)
print("<3",2,4,(t/9)%8+8,1,1,1)
--end
end
