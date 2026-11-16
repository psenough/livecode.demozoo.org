s=math.sin
t=0
function TIC()
cls(10)
for i=0,150 do
 elli((i*8+t*20)%240+20*s(t),(i*30+t*10)%136+20*s(t),16,6,1)
end
for x=0,240 do
for y=0,136 do
 cl=s(x/20+t)+s(y/20+t)+s(x&y)
 if pix(x,y) == 1 then
  pix(x,y,cl+12)
 end
end
end
t=t+0.05
end