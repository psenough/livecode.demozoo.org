a={}
m=math
for y=0,36 do
a[y] = m.random(240)
end
function TIC()
cls()
t=time()//32
for x=0,300 do
pix(m.random(240),m.random(136),t)
end
for y=0,36 do
circ((a[y]+t-40)%260,-m.abs(m.cos(t/12+y))*50+100,20,(y+t/9)%5+2)
end
print('ALLEZ',10,10,t)
end