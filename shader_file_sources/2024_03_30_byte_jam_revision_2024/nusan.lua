r=math.random
s=math.sin
max=math.max
abs=math.abs
function SCN(y)
for k=0,47 do
v=(k//3)*(s(k%3+k%11+t/200+y/170+s(y/270+t/20)*3+(k%8>4 and 3 or 0))*0.5+0.5)*15

poke(0x3fc0+k,v)
end
end

function TIC()t=time()//32

for i=0,1000 do
o=s(t/10)<0.5 and abs(s(t/10))*3+1 or 0
x,y=r(240),r(136)
	circb(x,y,o,pix(x,y)*max(s(t/20)*100,0.5))
end
for i=0,1 do
	circb(r(200)+120-100,r(100)+10,r(30),15)
end
u=s(t)*70*s(t/3)*s(t/7)*s(t/5)
for i=0,30 do
rect(r(240),90-u+i,r(10),u*2+100,15)
end
circb(120,68,40-fft(2)*4000,15)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>