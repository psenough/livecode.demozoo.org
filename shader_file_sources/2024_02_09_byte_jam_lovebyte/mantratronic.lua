-- mt here               ^
-- greets to suule,visy,tobach,
-- jtruk,gasman,vurpo,mrsynackster,
-- lovebyte orgas and you

M=math
S=M.sin
C=M.cos

tx,ty,dx,dy=0,0,1,1
yy=0
function rotate(x,y,z,xa,ya,za)
x1=x
y1=y*C(xa)-z*S(xa)
z1=y*S(xa)+z*C(xa)
x2=x1*C(ya)-z1*S(ya)
y2=y1
z2=x1*S(ya)+z1*C(ya)
x3=x2*C(za)-y2*S(za)
y3=x2*S(za)+y2*C(za)
z3=z2
return{x=x3,y=y3,z=z3}
end

cube={{1,1,1},{1,1,-1},{1,-1,1},{1,-1,-1},
					 {-1,1,1},{-1,1,-1},{-1,-1,1},{-1,-1,-1}}
cl={{1,2},{1,3},{2,4},{3,4},
    {5,6},{5,7},{6,8},{7,8},
    {1,5},{2,6},{3,7},{4,8}}
cls()
for x=0,239 do
for y=0,136 do
pix(x,y,(M.random(2)-1)*(x/24+1))
end
end

function BDR(y)
vbank(0)
for i=1,15 do
rx=8+4*S(i/10+y/100+t/1000)
rg=8+4*S(i/10+y/100+t/800+M.pi*.6)
rb=8+4*S(i/10+y/100+t/700+M.pi*1.4)
poke(0x3fc0+i*3, rx*16)
poke(0x3fc0+i*3+1, rg*16)
poke(0x3fc0+i*3+2, rb*16)
end
end

function TIC()t=time()
vbank(1)
cls(0)
cr={}
for i=1,#cube do
 cr[i]=rotate(cube[i][1],cube[i][2],cube[i][3],
              t/1000,t/1900,t/2900)
end
scale=400*fft(5) + 400
for i=1,#cl do
p1=cr[cl[i][1]]
z1=p1.z+10
x1=120+scale*p1.x/z1
y1=68+scale*p1.y/z1
p2=cr[cl[i][2]]
z2=p2.z+10
x2=120+scale*p2.x/z2
y2=68+scale*p2.y/z2
--pix(x1,y1,12)
x1=x1//1
x2=x2//1
y1=y1//1
y2=y2//1
line(x1,y1,x2,y2,12)
width=100*fft(20)
for i=1,width do
line(x1-i,y1,x2-i,y2,12)
line(x1-i,y1-i,x2-i,y2-i,12)
line(x1+i,y1,x2+i,y2,12)
line(x1+i,y1+i,x2+1,y2+i,12)
end
end
--[
pl=print("LOVEBYTE",0,140,12,true,4)
ph=20
tx=tx+dx
ty=ty+dy
if tx < 0 then tx=1 dx=1 end
if tx > 239-pl then tx=238-pl dx=-1 end
if ty < 0 then ty=1 dy=1 end
if ty > 135-ph then ty=134-ph dy=-1 end
print("LOVEBYTE",tx,ty,12,true,4)
print("LOVEBYTE",tx+2,ty+2,12,true,4)
print("LOVEBYTE",tx+1,ty+1,0,true,4)
--]]
--[
for x=0,239 do
for y=0,136 do
vbank(1)
if pix(x,y) > 0 then
vbank(0)
c0=pix(x,y)
if c0 > 0 then pix(x,y,0) else pix(x,y,x/24+1) end
end
end
end
--]]

vbank(1)
--cls(0)

yy=yy+fft(100)*100
yy=yy%235
rect(0,0,239,yy,0)
rect(0,10+yy,239,135,0)

pl=print("There is no cube.",0,140)
print("There is no cube.",120-pl/2,124,12)
pl=print("Credit to Chris Long for the cool idea",0,140)
print("Credit to Chris Long for the cool idea",120-pl/2,130,12)
end
