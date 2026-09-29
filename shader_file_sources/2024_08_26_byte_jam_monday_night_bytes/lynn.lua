-- pos: 0,0
v={}
d=0
function TIC() T=time()*2.083/1000
d=d+1
if d==2 then
d=0
l=""
for i=0,fft(10,10+30)*9 do
ch=string.char(math.floor(fft(i,i+30)+61))
l=l..ch
end
table.insert(v,1,l)
if #v>20 then table.remove(v,20) end

end
c=math.cos s=math.sin
cls(12)
for y=1,17 do
print(v[y],4,y*8-4,13)
end
for t=0,6280 do
b=30+c(t*0.05+T*0.5)*5
m=0
for i=0,3 do
 m=m+s(t*0.01*(6-i)+i+T)*fft(i+1,i+10)*5
end
for k=0,3 do
local n=b+k*m/4+fft(20,30)*10
x=c(t*0.01)*n+120
y=s(t*0.01)*n+65
pix(x,y,k+13)
end
end end
