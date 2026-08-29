e=elli
c=math.cos
p=print
s={"i","am","the","oracle","ask","me"}
function TIC()cls()t=time()//8
v=120+9*c(t*.04)
for y=0,136,1 do
x=v+c((y+y*t*.001)+t*.01)*32
e(x,y,5+y,5,t*.0+(t>>2+(5-y)%7))
end 
p(s[((t>>8)%7)+1],v,15+(t>>5)%64,15-(t>>2)%7)
end