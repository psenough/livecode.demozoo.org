-- hello HackFest 2026, this is merlock sholmes
m=math
s=m.sin
abs=m.abs
t=0
function TIC()
t=t+0.25
cls()
f=fft(0,100)
for x=0,7 do
for y=0,7 do
circb(120+s(y*1.5+t/16)*32+s(x*3+t/3)*8,68+s(y*1.5+t/32+x)*32+s(x*5+t/2)*8,f,y/2+t)
end
end
txt="rasterzzz"
txt_w=#txt*6
for x=0,#txt do
local char = txt:sub(x,x)
print(char,x*6+90,68+s(t*-0.15+x*0.175)*7,x+-t)
end
end
function BDR(row)
poke(0x3fc0,s(row/12+t/6+0.25+s(row*32))*32+f*2)
poke(0x3fc1,s(row/12+t/6+0.5+s(row*32))*32+f*2)
poke(0x3fc2,s(row/12+t/6+s(row*32))*32+f*2)
end