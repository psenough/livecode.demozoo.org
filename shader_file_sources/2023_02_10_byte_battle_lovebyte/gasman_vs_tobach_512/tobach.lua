s=math.sin c=math.cos r=rect cr=circ
function TIC()
cls(13)t=time()/32r(30,0,170,130,12)rectb(30,0,170,130,14)f=fft(3)
for i=0,20 do line(40,10+i*6,40+(f*75)+s(t/2+i/2*i)%8*7,10+i*6,15)end r(0,128,240,9,14)
for i=0,14 do r(0+i*16,129,14,5,13)end
for i=0,110 do for j=0,2 do cr(100+s(i/8)*(8+i/5)-j+s(t/8)*4,60+c(i/8)*(32+i/4)-j,4,15-j)end end
for i=0,1 do cr(80+i*32+s(t/8)*4,40,5,12)cr(80+i*32+s(t/8)*4,40,2,15)end
print("your arrays\nstart at 1\nwould you like\nhelp with that?",140,50+s(t/6)*4,15+t/4%5)end