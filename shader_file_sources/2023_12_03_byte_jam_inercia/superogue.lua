-- Superogue here
-- Greetings to everyone at inercia
-- (and fuckings to ps obviously...)

function SCN(l)
ThreeFutureCrewZero=0x3fc0
for i=0,9 do
c=i*25
poke(ThreeFutureCrewZero+i*3,c)
poke(ThreeFutureCrewZero+i*3+1,c)
poke(ThreeFutureCrewZero+i*3+2,c)
end
c=l*32
poke(ThreeFutureCrewZero+45,l<67 and 255-c or c*2)
poke(ThreeFutureCrewZero+46,l<68 and c or 255-c)
poke(ThreeFutureCrewZero+42,255)
poke(ThreeFutureCrewZero+43,32)
poke(ThreeFutureCrewZero+44,96)
end

S=math.sin
function TIC()
f=(fft(0))*128
t=time()/500+f
cls(1)
for y=0,136 do for x=0,240 do
xx=x-120yy=y+32.1
z=(xx*xx+yy*yy)/999
c=math.abs((x)/z+time()/99)//1 & (y/z)//1
pix(x,y,c%3)
end end 
for y=0,136,2 do line(0,y,240,y,0)end

s=math.sin(t/9)
c=math.cos(t/9)
for y=-99,99,4 do
for x=-99,32,4 do
 z=S(x/27+t)-S(y/15+t)+S(x/19-t)
 X=x*c-y*s
 Y=x*s+y*c
 print('"',120+X,Y*2/z-z,(Y+y/4)%4+1)
 print('"',120-X,Y*2/z-z,(Y+y/4)%4+1)
end end

logo(100,66,0)
logo(98,64,15)
print("and don't forget to leave inercia",56,129,14,1,1,1)
end

function logo(lx,ly,lc)
print(":/|/@|2( [/|",lx,ly,lc)
print("[/|/@| ( :/|",lx+1,ly,lc)
print("_",lx+33,ly-4,lc)
print("_",lx+31,ly,lc)
print(".",lx,ly-math.abs(math.sin(time()/99)*3)-5,lc-1)
print(".",lx+46,ly+math.abs(math.sin(time()/99)*3)+3,lc-1)
end


