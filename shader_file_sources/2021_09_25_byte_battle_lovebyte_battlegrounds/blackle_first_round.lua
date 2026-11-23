function TIC()cls()t=time()/3e3l={}s=math.sin
t=t+s(t*8)/9
for i=1,40 do
l[i]={x=s(t+i)*239,y=s(t+i*97)*149}end
for i=1,40 do
v=l[i]m=1e9w=v
for j=1,40 do
p=l[j]n=(p.x-v.x)^2+(p.y-v.y)^2
if n<m==(n>9) then
m=n
w=p
end
end
line(w.x,w.y,v.x,v.y,i%4+8)end
end