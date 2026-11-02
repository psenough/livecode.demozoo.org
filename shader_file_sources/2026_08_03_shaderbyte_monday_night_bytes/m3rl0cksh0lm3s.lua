function TIC()
t=time()/32
for y=0,136 do
for x=0,240 do
pix(x,y,(x/240*y/136+math.tan(x/32+t/64)*math.sin(x/22+y/8+x/24+t/6+math.sin(y/8+x/4+y/-12)))+y/128+math.sin(t/128)*16)
end
end
end

function SCN(row)
poke(0x3ff9, math.sin(t/12+row/8)*6)
end

function OVR()
circ(120,80,45,13)
tri(72,27,75,80,95,44,13)
tri(172,27,165,80,145,44,13)
elli(102,68,12,18,15)
elli(136,68,12,18,15)
tri(115,90,120,95,125,90,1)
line(115,95,125,95,15)
print("here's a cat face for ye :)",53+math.sin(t/32)*16,20,12)
print("procedurally generated with shapes",25,128,12)
end