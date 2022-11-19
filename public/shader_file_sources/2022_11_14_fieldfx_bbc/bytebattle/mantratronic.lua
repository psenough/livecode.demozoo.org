--forgot to save for the 
--livecode.demozoo.org
l={}
function TIC()t=time()/99
cls(12)
for i=0,95 do
l[i]={x=i+s(i/8+t/6)*20,y=25+45*math.cos(i/30)}
end
for i=0,63 do
j=i+1
for k=0,368 do
m=k/5n=k/(7-3*(s(t/15)))+20
line(l[i].x+n,l[i].y+m,l[j].x+n,l[j].y+m,(i//8+k//64)%2*2+9)
end
end
end
s=math.sin

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

