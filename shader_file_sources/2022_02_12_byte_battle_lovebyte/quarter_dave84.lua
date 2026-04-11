s=math.sin
c=math.cos
function TIC()
t=time()/10
for y=-68,68 do for x=-120,120 do
X=math.atan2(x,y)*4
Y=10000/(x*x + y*y)^(2+c(t/400))
cl=s(X+t/50)*5 + s(Y+t/50)*5
pix(x+120,y+68,(cl*3)%10+1)
end end end