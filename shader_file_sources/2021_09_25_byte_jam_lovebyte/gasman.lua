m=math
c=m.cos
s=m.sin
msg="<3 LOVEBYTE <3"
msgwidth=print(msg,0,0)
v={
 {-1,-1,0},
 {-1,1,0},
 {1,1,0},
 {1,-1,0},
 {0,0,1},
 {0,0,-1}
}
for i=0,47 do
 poke(32320+i,peek(16320+i))
end
cy=0
function SCN(y)
 if y<cy then
  for i=0,47 do
   poke(16320+i,peek(32320+i))
  end
 else
  for i=0,47 do
   poke(16320+i,i*5)
  end
 end
end
function TIC()
cls()
t=time()
cx=120+120*s(t/1345)
cy=65+65*s(t/432)

scale=.5+.5*s(t/400)

ix1=120+scale*40*s(t/2345)
iy1=65+scale*40*s(t/5432)
ix2=120-scale*40*s(t/1345)
iy2=65-scale*40*s(t/3432)

for y=0,136 do for x=0,240 do
if (x<cx and y<cy) then
 r1=((x-ix1)*(x-ix1)+(y-iy1)*(y-iy1))^.5*scale//8
 r2=((x-ix2)*(x-ix2)+(y-iy2)*(y-iy2))^.5*scale//8
 pix(x,y,(r1//1~r2//1)&3)
elseif (x>=cx and y>=cy) then
 a1=m.atan2(x-ix1,y-iy1)/m.pi*32
 a2=m.atan2(x-ix2,y-iy2)/m.pi*32
 pix(x,y,((a1//1~a2//1)&3)*3)
end
end end

v1={}
v2={}
w={}
a=t/400
for i=1,6 do
 v1[i]={
  v[i][1]*c(a)+v[i][3]*s(a),
  v[i][2],
  v[i][3]*c(a)-v[i][1]*s(a)
 }
 v2[i]={
  v1[i][1]*c(a)-v1[i][2]*s(a),
  v1[i][2]*c(a)+v1[i][1]*s(a)
 }
 w[i]={
  40*v2[i][1],40*v2[i][2]
 }
end
tri3d(w,1,2,5,5)
tri3d(w,2,3,5,7)
tri3d(w,3,4,5,9)
tri3d(w,4,1,5,11)
tri3d(w,1,2,6,5)
tri3d(w,2,3,6,7)
tri3d(w,3,4,6,9)
tri3d(w,4,1,6,11)
for i=0,90 do
 rect(cx+120+60*s(i/50+t/456)*s(i/10+t/139),cy-130+i,8,130-i,i)
end
print(msg, cx-msgwidth*2,cy-8,time()/32,true,4)
end
function line3d(w,i,j)
  line(
   cx+120+w[i][1],cy-85+w[i][2],
   cx+120+w[j][1],cy-85+w[j][2],
   4)
end
function tri3d(w,i,j,k,clr)
  tri(
   cx-120+w[i][1],cy+85+w[i][2],
   cx-120+w[j][1],cy+85+w[j][2],
   cx-120+w[k][1],cy+85+w[k][2],
   clr)
end