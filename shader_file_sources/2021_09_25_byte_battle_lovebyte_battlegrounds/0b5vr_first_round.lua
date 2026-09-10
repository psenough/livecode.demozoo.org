T,R,S=0,math.random,math.sin
function TIC()cls()T=T+.1
for i=0,8E3 do
t=math.acos(R()*2-1)p=99*R()m=10+2*S(2*S(p*2)*S(t*3)+t+T)y=m*S(t+11)x=m*S(t)z=18+x*S(p)x=5*S(T/4)+x*S(p+11)z=z/99
x=120+x/z
y=68+y/z
g=math.tan(y/99+T/8)
pix(x+g,y,8+g/9+m+R())end
end
