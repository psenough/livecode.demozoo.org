function TIC()cls()t=time()/999s=math.sin
l={}p=pairs
for x=0,20 do
l[x]={x=s(x*7+t)*250,y=s(x+t)*299}end
for i,v in p(l)do
m=1e9w=v
for q,r in p(l)do
n=(r.x-v.x)^2+(r.y-v.y)^2
if (n-q)^2<m then
m=n
w=r
end
end
line(v.x,v.y,w.x,w.y,i%5)end
end
