function TIC()t=time()/999
cls()r=9
for i=0,135 do
r=(r*57+13)%64pix(-t*(r+10)%240,i,-r/16)
end
for i=0,399 do
x=i%8-3+t//1-t
y=i//8%5-2z=40-i//40-math.max(0,x+y%3)^3
f=40/z
s=(2*(9-i//40))*f
rect(120+x*40*f-s,68+y*40*f-s,s*2,s*2,i+t//1)end
end