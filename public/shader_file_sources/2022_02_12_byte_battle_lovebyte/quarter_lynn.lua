s=math.sin
c=math.cos
function TIC()t=time()//32
for i=0,32 do
circ((s(t/9+i)*8)+(c(t/16)*20)+120,68,160-i*2,i/4)end
print("eat dmplngs",86,62,9)for i=20,200 do for j=1,7 do
x=(s(t/8+i/24)*c(t/13+i/11)*42)+120+j
line(x,i,x,240,(8+(t//32)*8)+j)end end end