t=0

for i=0,15 do
poke(0x3fc0 + i*3, math.min(255,i*32))
poke(0x3fc0 + i*3 + 1, math.max(0,i*24-128))
poke(0x3fc0 + i*3 + 2, math.max(0,i*24-256))
end

cls()
for y=0,136 do for x=0,240 do
pix(x,y,(x+y+t)>>3)
end end 

function OVR()
t1=(t/1600)%1
if t1 < .5 then
t1=(t1-.25)*math.pi*2
circ(120+500*math.sin(t1),68+20*math.cos(t1),10,0)
else
t1=(t1+.25)*math.pi*2
sx=120+500*math.sin(t1)
sy=68+20*math.cos(t1)
print(" ___ ",0+sx,0+sy,0,true)
print("  |  ",0+sx,4+sy,0,true)
print("##=##",0+sx,8+sy,0,true)
print("  |  ",0+sx,12+sy,0,true)
print(" ___ ",0+sx,13+sy,0,true)
end

end

function TIC()

if(t%141==0) then
for y=0,136 do for x=0,240 do
pix(x,y,((math.pi*math.atan(x-120,y-68))+t)%4+1)
end end 
circ(120,68,50+5*math.sin(t/150),15)
end

if(t%423==77) then
print("LOVE",40,20,15,false,7)
print("BYTE",50,80,15,false,7)
end
if(t%423==218) then
print("RIFT",50,20,15,false,7)
print("TLC",60,80,15,false,7)
end
if(t%423==359) then
print("#BUZZ",20,20,15,false,7)
print("<3ALL",20,80,15,false,7)
end

d=1+2*math.random()
for i=1,5000 do
x=240*math.random()
y=136*math.random()
a=math.atan(x-120,y-68)

op=pix(x,y)-1
if op >= 0 then
pix(x+d*(math.sin(a)+math.sin(t/300)),y+d*(math.cos(a)+math.sin(t/300)),op)
else
pix(x+d*math.sin(a),y+d*math.cos(a),0)
end
end
t=t+1
end