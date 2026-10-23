m=math
function TIC()
t=time()/1000
cls()
for y=-36,172 do
for x=-32,272 do
v1=m.sin(x/5)
v2=m.sin(y/5)+t
color=(v1+v2+y/128)+t
pix(x+m.sin(y/32+t*2)*12,y+m.sin(x/32+t*2)*12,color+t-x/32+m.sin(y/4+x/8))
end
end
end

function OVR()
for x=0,255 do
rectb(120+m.sin(x/3+t/2)*32,68+m.sin(x*1+t)*32,3,3,x/64+t*8)
end
end