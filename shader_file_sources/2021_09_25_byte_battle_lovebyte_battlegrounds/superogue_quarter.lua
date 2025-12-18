g=0S=math.sin
function TIC()cls()g=g+.03s=S(g)c=S(g-11)
for y=-31,31 do for x=-31,31 do
a=math.atan(x//2,y)*39//3
u=x*c-y*s
v=x*s+y*c
q=a%5X=120+u*3Y=v+a*2+60
circ(X,Y,q>pix(X,Y)and q/2 or 0,-q)
r=(x*x+y*y)/8w=(S(x/5+g)+r%4)*9
circ(X*2,v+w+144,5,w/6)end end end