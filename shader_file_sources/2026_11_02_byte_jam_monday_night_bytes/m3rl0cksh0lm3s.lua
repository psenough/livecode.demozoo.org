-- hello, dis is merlock.
-- i haz moved from windows to linux mint
-- because screw microslop :P
-- anyways, LET'S DO THIS!!
-- beb.
-- greetz to aldroid, finkel,
--           gasman, boris,
--           jtruk, mutzbunny,
--           doop, and you!
v={
{1,1,1},{1,1,-1},{-1,1,-1},{-1,1,1},
{1,-1,1},{1,-1,-1},{-1,-1,-1},{-1,-1,1}
}
t=0
m=math
s=m.sin
function TIC()
t=t+1
cls()
for i=0,7 do
local vert=v[i]
for x=0,11 do
for y=0,3 do
circ(x*i*2+60+s(x/4+y+t/16+i*8)*8,y*s(i/4+t/32)*12+60,y,i+t/8)
end
end
end
end