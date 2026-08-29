R=load'X,Y,A=...return X*S(A-11)-Y*S(A),X*S(A)+Y*S(A-11)'t=0S=math.sin
function TIC()cls()t=t+.05 
for Z=-8,8 do for Y=-8,8 do for X=-8,8 do
x,y=R(X,Y,t/9)x,z=R(x,Z,t/7)z=z+S(t/9)*8+16
W=16-z
rect(x*99/z+120,y*99/z+68,W,W,t+z/2+8)end end end
print'^2'end