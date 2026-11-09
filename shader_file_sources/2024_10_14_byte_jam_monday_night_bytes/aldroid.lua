-- aldroid here!
a=0
S= math.sin
C= math.cos

function cb(x,y,r,a)
x1=-1
y1=-1
x2=1
y2=-1
x3=1
y3=1
x4=-1
y4=1
CA=C(a)
SA=S(a)
x1r=CA*x1-SA*y1
y1r=CA*y1+SA*x1
x2r=CA*x2-SA*y2
y2r=CA*y2+SA*x2
x3r=CA*x3-SA*y3
y3r=CA*y3+SA*x3
x4r=CA*x4-SA*y4
y4r=CA*y4+SA*x4
tri(
x+r*x1r,y+r*y1r,
x+r*x2r,y+r*y2r,
x+r*x3r,y+r*y3r,
3)
tri(
x+r*x1r,y+r*y1r,
x+r*x4r,y+r*y4r,
x+r*x3r,y+r*y3r,
3)

end

sead = {}

fwoi=0

function gfa(x,y)
 return -3.14*4.8+S(x*0.2+t/20)+C(y*0.01)
end

function csea()
t=time()/29
nead = {}
if fwoi >3 then
table.insert(sead,{x=240,y=math.random(-10,10),r=2+fft(1)*60,vx=-1,vy=0})
fwoi = 0
else
fwoi = fwoi + 1
end
for i,bl in pairs(sead) do
circb(bl["x"],bl["y"]+68,bl["r"],3)
fan=gfa(bl["x"],bl["y"])
fc = 0.6
bl["vx"]=(bl["vx"]+S(fan))*fc
bl["vy"]=(bl["vy"]+C(fan))*fc
bl["x"] = bl["x"]+bl["vx"]
bl["y"] = bl["y"]+bl["vy"]
if bl["x"] > -4 then table.insert(nead,bl) end
end
sead=nead
end

function TIC()
t=time()/100
mt = debug.getinfo(TIC)
cd = mt["source"]
cls(0)
rect(10,10,220,116,15)
clip(10,10,220,116)
print(cd,20,10,0)
clip()
rt = t*3.14/20

cb(120,68-S(rt*4),20+math.abs(C(rt*2))*10,rt+S(3.14+rt*4)/4)

csea()

for q=0,140,10 do
 i=(q-t+140)%140
 rectb(5,i-5,8,8,3)
 rectb(225,i-5,8,8,3)
end

end
