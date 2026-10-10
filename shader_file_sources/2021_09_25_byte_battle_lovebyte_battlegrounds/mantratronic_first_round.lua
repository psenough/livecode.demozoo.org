m=math
s=m.sin
function g(h,H) return {x=-5+h*13+20*s(h/3+H/19+t),y=H+9*((h%2)+s(h*6+s(t)))} end
function TIC()t=time()/400
for j=-20,200,5 do
for i=0,20 do
J=j+s(t)a=g(i-1,j)b=g(i,j)d=g(i+1,j)
tri(a.x,a.y,b.x,b.y,d.x,d.y,(i+j/4)%4+8)
end
end
end