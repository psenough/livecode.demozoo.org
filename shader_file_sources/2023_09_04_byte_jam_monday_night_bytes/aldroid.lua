-- aldroid here
-- hello how are you fine thank you
-- thanks to violet and lynn and 
-- love to my fellow coders!
-- wooooo!
s=math.sin
c=math.cos

-- forgotten how arrays work in lua :(
function smokeyboop(x,y,t)
for i=4,0,-1 do
circ(x-s(t+i)*2,y-(t+i*2)%50,2,i)
end
end

function train(x,y)

for i=20,50,10 do
circ(i+x,20+y,3,1)
end
rect(15+x,15+y,45,5,1)
rect(17+x,5+y,35,10,1)
rect(50+x,y,10,15,1)
rect(18+x,y,4,6,1)

for i=0,120,40 do
rect(65+x+i,y,35,20,1)
boops=fft(i)*20*math.pow(i+1,.5)
for kk=0,boops do
k=boops*20
rect(90+x+i-25,y-k-20,35,10,4-kk%5)
end
for j=70+i,95+i,10 do
circ(j+x,20+y,3,1)
end
end
smokeyboop(18+x,y,time()/64)
end

function TIC()t=time()/16
-- last minute decision to do a train
-- :)

cls(0)
train(240-t%550,100)
a=print("choo choo!",0,0,1)
a=math.min(
  math.max(t%550+a+50-550,0)-1,
  a)
ox=30
oy=10
sx=4
sy=4
r=0.5
for i=0,1 do
for x=0,a do for y=0,7 do
if pix(x,y)==1 then
px=sx*x*c(r)-sy*y*s(r)
py=sy*y*c(r)+sx*x*s(r)
circ(ox+px,oy+py,3-i,4-i)
end
end end
end
end