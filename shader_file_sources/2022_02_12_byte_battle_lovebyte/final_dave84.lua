--Ran out of time before realising my for loops were nested. The perils of live coding.
s=math.sin
c=math.cos
function TIC()t=time()/32
cls()
for y=0,136 do
line(50+30*s(t+y/6*100)+s(y/5+t)*10,y,190+30*c(t+y/6*100)+c(y/5+t)*10,y,1)
for i=0,32639 do
 x=peek4(i)
 if x>0 then
 poke4(i,x+i/3)
 end
end
end 
end