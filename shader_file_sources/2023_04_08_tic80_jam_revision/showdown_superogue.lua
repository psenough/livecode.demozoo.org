-- pos: 0,0
-- Superogue here...
-- "Groetjes to everyone at Revision!"
-- - Je Moeder
function SCN(l)
poke(16323,l)
end
function TIC()t=time()/39
cls()

f=fft(1)*9--math.random(4)/3
a=t/19+math.sin(t/5)
s=math.sin(a)
c=math.cos(a)


for y=0,136,2 do
for x=0,240 do
X=x-120
Y=y-68.1
Z=1-((X*X+Y*Y)/399)--math.abs(Y+.1)/99
xx=X*9/Z+math.sin(t/15)*32
yy=Y*9/Z+math.sin(t/17)*32
k=xx//8 & yy//4--(xx//1)&(yy//1)
pix(x,y,8+k%2)
end end

for y=-15,15  do for x=-15,15 do
X=x*c-y*s
Y=x*s+y*c
Z=.2
k=(x~y)/8
h=(x~y)+math.sin(t/7)*4
r=Y/99
pix(X/2+16,Y/3+16-h,h/4)
end end 

print("have a great revision!",64,64,12+t/8%3) 
print("- je moeder",64,72,13+t/8%2) 


print("*REC",210,2,t//8&2,1,1,1)
end
