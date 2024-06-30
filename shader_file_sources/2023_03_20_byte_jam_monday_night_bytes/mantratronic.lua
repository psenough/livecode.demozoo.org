--   ^ 
--  nobach here
-- (mantratronic)

m=math
rand=m.random

p={}

bass=0
bassh=0
mid=0
midh=0
high=0
function TIC()t=time()//32
bass=0
for i=0,9 do
 bass=bass+fft(i)
end
bassh=bassh*9/10 + bass/10
mid=0
for i=10,49 do
 mid=mid+fft(i)
end
midh=midh*9/10 + mid/10
p={}
vbank(0)
cls()
l=print("3 WEEKS",-100,-100,12,false,5)
print("3 WEEKS",120-l/2,10,12,false,5)

l=print("TO",-100,-100,12,false,5)
print("TO",120-l/2,40,12,false,5)

l=print("REVISION",-100,-100,12,false,5)
print("REVISION",120-l/2,70,12,false,5)

l=print("HYPE!!!!",-100,-100,12,false,5)
print("HYPE!!!!",120-l/2,100,12,false,5)

l=print("irish sheep best sheep",200,230,12,false,1)
print("irish sheep best sheep",120-l/2,130,12,false,1)

for y=0,136 do for x=0,240 do
if pix(x,y) == 12 then 
 if x < 80 then c = 6 
 elseif x < 160 then c = 12
 else c = 3
 end
 d=((x-120)^2+(y-68)^2)^.5
 a=m.atan2(x-120,y-68)+(t/200)%1*2*m.pi*m.cos(bassh*d/40+t/200)
 w=d+10*m.sin(d/40*midh+t/99)+(t/111)%5
 nx=w*m.sin(a)
 ny=w*m.cos(a)
 table.insert(p,{nx,ny,c})
end
end end 
cls()

vbank(1)
for i=1,5000 do
 x=rand(240)-1
 y=rand(136)-1
 pix(x,y,m.max(pix(x,y)-1,0))
end

if t%4 == 0 then
cls()
end
 
for i=1,#p do
 pp=p[i]
 pix(120+pp[1]+.5,68+pp[2]+.5,pp[3])
 pix(120+pp[1]-.5,68+pp[2]+.5,pp[3])
 pix(120+pp[1]+.5,68+pp[2]-.5,pp[3])
 pix(120+pp[1]-.5,68+pp[2]-.5,pp[3])
end

end