function TIC()
t=time()/100
for y=0,136 do
for x=0,240 do
pix(x,y,y+t+x*y/8*x/3.86)
end
end
end

function OVR()
print("beh fieldfx behbehbeh", 65, 68+math.sin(t/4)*16, 12)
end