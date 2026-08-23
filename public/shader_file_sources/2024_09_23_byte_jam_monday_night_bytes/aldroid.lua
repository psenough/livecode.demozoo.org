
function drawracc()

elli(120,68,60,40,0)

elli(90,40,15,20,12)
elli(88,40,10,15,0)
elli(150,40,15,20,12)
elli(152,40,10,15,0)

elli(120,68,60,30,0)


elli(120,78,55,25,12)
elli(120,85,40,20,0)
elli(120,95,20,15,12)
elli(120,92,10,6,0)
tri(120,92,110,48,130,48,0)

ellib(105,72,5,3,12)
ellib(135,72,5,3,12)

elli(107,70,2,1,12)
elli(137,70,2,1,12)

for s=-1,1,2 do
for i=0,2 do
line(120+s*30,82+i*3,120+15*s,87+i*2,12)
end
end
end

S=math.sin
C=math.cos

PI=math.pi

function star(ox,oy,r)

ri=4
ro=8
tbw=PI*2/10
for vi=0,4 do
i=vi+r
ci=C(i*PI*2/5)
si=S(i*PI*2/5)
ci1=C(i*PI*2/5-tbw)
si1=S(i*PI*2/5-tbw)
ci2=C(i*PI*2/5+tbw)
si2=S(i*PI*2/5+tbw)
tri(ox+ro*ci,oy+si*ro,
    ox+ri*ci1,oy+si1*ri,
    ox+ri*ci2,oy+si2*ri,
    4)
circ(ox,oy,ri,4)
end

end

stars={}

for i=0,20 do
table.insert(stars,{
x=math.random(10,230),
y=math.random(10,126),
r=math.random()})
end

function TIC()t=time()//32
cls(14)

line(10,78,230,78,15)

for i=0,17 do
am=fft(i*20)*200
rect(30+10*i,78-am,8,am,i%3+3)

end

drawracc()

ox=20
oy=20
for i,v in pairs(stars) do
 star(v["x"],v["y"],v["r"])
 v["y"] = v["y"] + 1
 v["r"] = v["r"]+0.05
 if v["y"] > 135 then
  stars[i]={x=math.random(10,230),y=math.random(-10,0),r=math.random()}
 end
end
end
