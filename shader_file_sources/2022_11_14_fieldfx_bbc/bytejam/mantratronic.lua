-- dark+light blue = dublin
-- dark blue + yellow = wicklow
-- tobach is right, needs rain
l={}
c={{9,2},{8,-4},{2,9}}
poke(0x3fc6,180)
poke(0x3fc7,40)
poke(0x3fc8,180)
function TIC()t=time()/99
cls(12)
circ((-40+t)%340,350,250,6)
circ((100+t)%340,280,200,7)
circ((200+t)%340,350,250,6)
ct=(t/150+2)%3//1+1
for i=0,100 do
x=math.random(239)
y=math.random(130)
line(x,y,x-2*s(t/20),y+6,15)
end
for i=0,95 do
l[i]={x=i*s(i/10+t/20)+s(i/8+t/8)*40,
y=25+45*math.cos(i/30)}
end
checker=64/(((t/16)//1%4)^2+1)+1
for i=0,63 do
j=i+1
for k=0,511 do
m=k/5
n=120+25*s(k/320)+30*s(t/20)--k/(7-3*(s(t/15)))+20
line(l[i].x+n,l[i].y+m,l[j].x+n,l[j].y+m,(i//checker~k//(checker*8))%2*c[ct][2]+c[ct][1])
end
end
print('FIELD-FX',25,58,0,true,4,false)
print('FIELD-FX',29,58,0,true,4,false)
print('FIELD-FX',25,61,0,true,4,false)
print('FIELD-FX',29,61,0,true,4,false)
print('FIELD-FX',28,60,c[ct][1]+c[ct][2],true,4,false)
print('FIELD-FX',26,59,c[ct][1],true,4,false)
for i=0,100 do
x=math.random(239)
y=math.random(130)
line(x,y,x-2*s(t/20),y+6,14)
end
end
s=math.sin


