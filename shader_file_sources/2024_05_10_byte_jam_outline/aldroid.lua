-- aldroid here
-- love to all at outline!
-- thanks to our fab orga team
-- havoc, zeno4ever, the poobrain
-- crew. and alice for making tic80
-- 100% better for jams! glhf to
-- her, gasman and jtruk and dj
-- dojoe! 
---------------
function TIC1()
cls()
bnd=3
wd = 240/8
for x=0,240/8 do
rect(x*wd+bnd,bnd,wd-2*bnd,136-2*bnd,3)
end
for i=0,239 do
circ(i,110 - fft(i*2)*200,2,0)
end
for i=0,239 do
circ(i,110 - fft(i*2)*200,1,12)
end
end

function TIC2(i)
cls(5)
pd=2
nt=8
bss = fft(0,10)*80
offs = 68 + 40*math.sin(i)
for i=0,bss do
 tri(i*240/nt+pd, offs-20,
     (i+1)*240/nt-pd, offs,
     i*240/nt+pd, offs+20,
     0)
end
end

function TIC3()
cls(9)
circ(120,68,fft(0,10)*560,10)
circ(120,68,fft(0,10)*560-fft(10,40)*190,11)
end

S=math.sin
C=math.cos

bac=0

function TIC4()
cls(12)
bac = bac+ fft(5,10)*2
for i=0,12 do
 circ(
 120+40*S(bac+i*math.pi*2/12),
 68+40*C(bac+i*math.pi*2/12),
  8,0)
end
pkr = (bac // math.pi)%4
x=240-40
y=136-40
if pkr==0 or pkr == 1 then
x=40
end
if pkr==0 or pkr ==3 then
y=40
end
circ(x,y,S(bac)*20,9)
end

function TIC5()
cls(0)
circ(120,68,40,5)
for i=-2,2,0.1 do
 circ(
 120+20*S(i*math.pi*2/12),
 68+20*C(i*math.pi*2/12),
  3,0)
end
circ(120-10,68-10,4,0)
circ(120+10,68-10,4,0)
end

function TIC6()
cls()
bac = bac + fft(0,10)
bnd=3
wd = 240/8
for y=0,3 do
for x=0,240/8 do
rect(
x*wd+bnd,y*wd+bnd,
wd-2*bnd,wd-2*bnd,7)
end
end
t=(bac*5)//1
y=t//8
sh=(t+y*8)%3
cx=(t%8-0.5)*wd
cy=(y%5-0.5)*wd
if sh==0 then
circ(cx,cy,5,0)
elseif sh==1 then
tri(cx,cy-4,cx-4,cy+4,cx+4,cy+4,0)
else
rect(cx-4,cy-4,8,8,0)
end
end

function TIC7()
cls(14)
thx=240/6
circ(thx,68,14+fft(0,10)*600,1)
trmt=20+fft(10,100)*100
trmt = trmt*0.8
tri(thx*3,68-trmt,
    thx*3-trmt,68+trmt,
    thx*3+trmt,68+trmt,
    1)
rcmt=10+fft(100,1000)*300
rect(thx*5-rcmt,68-rcmt,rcmt*2,rcmt*2,1)
end

function TIC()
t=time()
sc=t//500
pc = sc %7
if pc==0 then
TIC1()
elseif pc==1 then
TIC2(sc)
elseif pc==2 then
TIC3()
elseif pc==3 then
TIC4()
elseif pc==4 then
TIC5()
elseif pc==5 then
TIC6()
elseif pc==6 then
TIC7()
end
end