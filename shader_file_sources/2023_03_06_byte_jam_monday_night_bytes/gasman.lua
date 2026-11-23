-- gasman is here!
-- greetings to my fellow jammers
--           (unnecessary accent) -> ^
-- visy, kii and alia
-- synesthesia for the mix
-- and aldroid for putting it all
-- together!

for i=0,15 do
 poke(16320+i*3,i*15)
 poke(16320+i*3+1,i*15/4)
 poke(16320+i*3+2,i*15)
end

function brick(x,y,z,s,w,h)
 if z<1000 then
 c1=10+5*math.sin(time()/300)
 c2=10+5*math.cos(time()/300)
 for a=x,w+x-1 do
  for b=y,y+h-1 do
   bricklet(
    120+2*(a-b)*s,
    60+(a+b)*s-z,s,
    c1,
    c2
   )
  end
 end
 end
end
function bricklet(x,y,s,c1, c2)
tri(x,y,x+2*s,y+s,x+2*s,y-s,8)
tri(x+2*s,y+s,x+2*s,y-s,x+4*s,y,8)
tri(x,y,x,y+2*s,x+2*s,y+s,c1)
tri(x,y+2*s,x+2*s,y+s,x+2*s,y+3*s,c1)
tri(x+2*s,y+s,x+4*s,y,x+4*s,y+2*s,c2)
tri(x+2*s,y+s,x+2*s,y+3*s,x+4*s,y+2*s,c2)
elli(x+2*s,y,s,s/2,c1)
rect(x+s,y-s/2,2*s+1,s/2,c1)
elli(x+2*s,y-s/2,s,s/2,12)
end

oldbricks={}
obc=0
endz=30
cb={0,0,2,2,endz}
z=100

function TIC()
t=time()/100
cls()
for i=1,obc do
 b=oldbricks[i]
 brick(b[1],b[2],b[5]-t,5,b[3],b[4])
end

brick(
 cb[1],
 cb[2],z-t,
 5,cb[3],cb[4]
)
if z<=endz then
 obc=obc+1
 oldbricks[obc]=cb
 endz=t+30
 if math.random()<0.5 then
  cb={
   math.random(0,10),
   math.random(0,10),
   2,
   math.random(2,8),
   endz
  }
 else
  cb={
   math.random(0,10),
   math.random(0,10),
   math.random(2,8),
   2,
   endz
  }
 end
 z=endz+100
else
 z=z-2
end

end
