m=math
function TIC()
cls(8+fft(1)*2)
for x=0,240 do
a=x
b=240
l=(a^2+b^2)^.5
d=0
for i=0,50 do
u=4e3+d*a/l%8e3-8e3
v=4e3+(time()+d*b/l)%8e3-8e3
d=d+m.max(m.abs(u),m.abs(v))-900
end
h=m.min(138,1e6//d)
for y=0,h do
pix(x,y,(y*d//1e5)%4+9)
end
end
end