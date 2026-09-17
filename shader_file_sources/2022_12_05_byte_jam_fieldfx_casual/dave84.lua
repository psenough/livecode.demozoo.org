s=math.sin
c=math.cos
d=math.deg
 pal={2,12}
function TIC()
cls()
print("It's beginning to look a lot like...",0,0,2)
print("TINY",0,15,2,false,8)
print("CODE",0,67,2,false,6)
print("Christmas!",0,110,2,false,4)
for x=0,240 do
for y=0,136 do

 if pix(x,y) == 2 then
  pix(x,y,pal[(1+((s(t*20+x/100)+s(t*20+y/100))*10)%2)//1])
 end
end
end
for i=0,360,10 do
 for j=1,150,15 do
  x=5*j*s(d(i+t))
  z=5*j*c(d(i+t))-10000
  y=-100-j*10+s(t*j*10)*20
  pix(195+600*(x/z),5+600*(y/z),z/100)
 end
end
t=time()/99999
end
t=0
