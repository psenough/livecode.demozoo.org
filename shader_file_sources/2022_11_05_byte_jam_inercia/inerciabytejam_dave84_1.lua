t=0
function TIC()
cls()
text="nanogems.demozoo.org"
px,py={},{}
for c=0,10 do
for i=0,360,60 do
 x=120+10*c*math.sin(c+t)*math.sin(math.rad(i+c+t)+t/c)
 y=68+10*c*math.sin(c+t)*math.cos(math.rad(i+c+t)+t/c)
 table.insert(px,x)
 table.insert(py,y)
end
end

for i=1,#px do
for j=1,#px do
 if((px[i]-px[j])^2 + (py[i]-py[j])^2) < 150 then
  line(px[i],py[i],px[j],py[j],8+(t+j)%8)
 end
end
end
print("Ceci n'est pas une nanogem",45,0,10)
for i=1,#text do
print(text:sub(i,i),52+6*i,130,8+(i+t*20)%8,true)
end
t=t+0.01
end