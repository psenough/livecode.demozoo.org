p=poke
v=0x3fc0
for i=3,47 do
p(v+i,i%3==1 and 70+i*2 or 50-i)
end
function SCN(l)
p(v+2,255-l)
end
function TIC()t=time()/320
cls()
for x=-40,240,10 do for l=1,8 do
y=68+l*8
w=math.sin(t+(x+y)/50)
tri(
x-l*2,y,x+l*2,y,x+5*w,y-l*3-10,l)
end end
end