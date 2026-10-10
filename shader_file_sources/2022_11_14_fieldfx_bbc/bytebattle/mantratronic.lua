--forgot to save for the 
--livecode.demozoo.org
l={}
function TIC()t=time()/99
cls(12)
for i=0,95 do
l[i]={x=i+s(i/8+t/6)*20,y=25+45*math.cos(i/30)}
end
for i=0,63 do
j=i+1
for k=0,368 do
m=k/5n=k/(7-3*(s(t/15)))+20
line(l[i].x+n,l[i].y+m,l[j].x+n,l[j].y+m,(i//8+k//64)%2*2+9)
end
end
end
s=math.sin
