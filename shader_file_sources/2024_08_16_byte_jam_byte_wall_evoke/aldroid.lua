-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon

ox=120
oy=68
a=0

function rrect(x1,y1,x2,y2,c)
 sa=math.sin(a)
 ca=math.cos(a)
 rx1=ca*x1-sa*y1
 ry1=ca*y1+sa*x1
 rx2=ca*x2-sa*y1
 ry2=ca*y1+sa*x2
 rx3=ca*x1-sa*y2
 ry3=ca*y2+sa*x1
 rx4=ca*x2-sa*y2
 ry4=ca*y2+sa*x2
 tri(rx1+ox,ry1+oy,rx2+ox,ry2+oy,rx3+ox,ry3+oy,c)
 tri(rx4+ox,ry4+oy,rx2+ox,ry2+oy,rx3+ox,ry3+oy,c)
end

function TIC()
t=time()/800
a = t+math.sin(t)
cls((a/math.pi-1) % 2 < 0.05 and 15 or 0)
for x=-15,15 do
for y=-15,15 do
rrect(x*10+math.sin(t+y)*10,y*10,x*10+8,y*10+8,2*(1+math.sin(x+y+t)))
end end
end