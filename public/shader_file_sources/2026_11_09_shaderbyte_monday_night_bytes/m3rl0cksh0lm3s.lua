-- ello, dis is merlock
t=0
function TIC()
t=t+1
m=math
s=m.sin
c=m.cos
cls()
for y=58,78,4 do
for x=-9,244,4 do
rect(x+s(y),y+s(x/32*s(t/64)*1+t/32)*32,4,4,2)
rect(x+s(y),y+c(x/32*s(t/64)*1+t/32+1)*32,4,4,4)
end
end
end
