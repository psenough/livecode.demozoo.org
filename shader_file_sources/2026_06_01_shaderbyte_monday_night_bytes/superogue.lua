-- Ben by: superogue
m=math

function shark(level)

for i=0,32 do 
sx=120+m.sin(i/40+t/3.3)*32+m.sin(t/4)*16
sy=m.sin(i/8+t)*16+138-i*2
z=i/6+2
z2=i/8
sc=11-z/2
elli(sx,sy,z*3,z*6,sc)
elli(sx,sy+16,z*2.5,z*4,-z2)
end
-- fins
sy2=m.sin(t)*8+60
elli(sx+20,sy2,z*1,z*2,z2/2+5)
elli(sx-20,sy2,z*1,z*2,z2/2+5)
elli(sx,sy-40,4,16,7)

elli(sx,sy,12,8,3)

elli(sx,sy-3,10,6,12)

elli(sx-15,sy-16,3,6,0)
elli(sx+15,sy-16,3,6,0)
sy2=m.sin(t)*2
elli(sx-15,sy-sy2-16,1,2,12)
elli(sx+15,sy-sy2-16,1,2,12)
end

function TIC()t=time()/120
cls()
level=m.sin(t/32)*8
for i=0,136 do
line(0,i,240,i,(i/22)+i%1.3)
end

for j=0,8,.1 do
if (j<3) then shark(level)end
for i=0,240 do
wy=level+40+m.sin(i/32+t-j)*8+m.sin(i/12+t)*4 + j*16
line(i,wy,i,136,13-j+((3*j+t)%1.3))
end
end
tx=m.sin(t*7)*4+78
ty=sy/4-12
print("Blahahahahahaaa!",tx+1,ty+1,0)
print("Blahahahahahaaa!",tx,ty,12)
print("Ik ben Ben",198,128,12,1,1,1,1)
end