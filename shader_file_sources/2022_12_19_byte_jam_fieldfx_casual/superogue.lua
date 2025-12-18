-- Monday Night Bytes Bytejam 19/12/2022
-- Superogue
t=1m=29
function SCN(i)poke(16321,0)poke(16322,i*.6+fft(0)*9)end
function TIC()
S=math.sin(t/99+fft(0)*4)
C=math.cos(t/99+fft(1)*4)
cls()
for y=-31,31 do for x=-31,31 do
X=x*C-y*S
Y=x*S+y*C
h=(x//1~y//1)
c=(fft(1)*9+1)*Y/8+y/2%2
z=(fft(0)*6)+(math.sin(t/231)+1)
circ((X*z*1.3)+120,(Y*z)+68-h*z,z*.7+1,4-(c%8+fft(2)*3))
end end 

tx=40ty=56tc=12
T={'"Talent hits a target no one else can hit',' Genius hits a target no one else can see"','- Arthur Schopenhauer'}
print(T[1],tx+1,ty+1,14,1,1,1)
print(T[1],tx,ty,tc,1,1,1)
print(T[2],tx+1,ty+9,14,1,1,1)
print(T[2],tx,ty+8,tc,1,1,1)
print(T[3],tx+1,ty+21,14,1,1,1)
print(T[3],tx,ty+20,tc,1,1,1)
t=t+fft(1)*m+1
end