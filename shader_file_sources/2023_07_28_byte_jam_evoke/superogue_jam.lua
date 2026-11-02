-- superogue here...
-- gasman we miss you !
-- greetings do dojoe, tobach
-- and everyone at evoke 2023!
-- visit the sizecoding discord
-- and follow tcc (tiny code christmas)
-- to start coding tic80 yourself
-- also seminar at 13.00 on sat ;-)
-- <3
function SCN(l) 
poke(16322,l)
poke(16320,l/4)
end
t=0
function TIC()
f=fft(0)+fft(1)*2+.1
t=t+f
s=math.sin(t/9)
c=math.cos(t/9)
cls()
sc=math.sin(t/24)*4+16
for y=-99,99,5 do for x=-99,99,5 do
-- some rotation
X=x*c-s*y
Y=x*s+c*y
z=fft(2)+(math.sin(x/17+t/8)+math.cos(y/19-t/4)+t/4)%8+8

circ(X*sc/z+120,Y*sc/(z*3)+190-z*8,z/4,z)
end end 
for i=0,3 do
rect(220+i,4-i,15,15,i)
end
print("AHK",225,6,12,1,1,1,1)
-- OCD much...
print("welcome to evoke 2023",77,65,0,1,1,2,1)
print("welcome to evoke 2023",76,64,12,1,1,2,1)
end

