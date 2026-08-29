-- greetings, aldroid here
-- congratulations to the demoscene
-- of the netherlands for this epic
-- win
-- and gl fellow coders :)
S=math.sin
C=math.cos
R=math.random

cols={2,12,10} -- oh yeah
message={"con","grats","to","nl!"}

function SCN(l)
  poke(0x3fc0+3*9,59*(136-l)/136)
  poke(0x3fc1+3*9,93*(l)/136)
end

function chee(x,y)
tri(
x-2,y,
x+20,y-2,
x+2,y+5
,4)
tri(
x+20,y-2,
x+2,y+5,
x+2,y+20
,3)
tri(
x+20,y-2,
x+2,y+20,
x+20,y+13
,3)
tri(
x-2,y,
x+2,y+5,
x+2,y+20
,2)
tri(
x-2,y,
x-2,y+14,
x+2,y+20
,2)

line(
x+5,y,x+5,y-10,12)
rect(
x+6,y-9,6,2,cols[1])
rect(
x+6,y-7,6,2,cols[2])
rect(
x+6,y-5,6,2,cols[3])
end

function TIC()t=time()/32
cls(0)
mi=(t//20)% #message + 1
a=print(message[mi],0,0,1)
memcpy(0x8000,0,120*8)
cls(9)
ts=t/5
for y=0,136 do
pix(240-(math.sin(y)*120+ts*(3+math.sin(y*13)))%240 ,y,13)
end
tr=t/20
bs=6+fft(1)*3

for y=0,136,20 do
chee(240-(math.sin(y)*120+t*(3+math.sin(y*13)))%240,y+S(t/2+y)*10)
end

for y=0,8 do for x=0,a do
  if peek4(2*0x8000+y*240+x)==1 then
    col = cols[y//2+1]
    xc = x - a/2
    yc = y
    z = S(tr)*xc
    xw = xc * C(tr)
    yw = (yc-4)*20/(20+z)
		  circ(120+xw*bs,72+yw*bs,4,0)
    
    for i=0,4 do
      circ(120+xw*bs+R()*4,64+yw*bs+R()*8,2,col)
    end
    
		  circ(124+xw*bs,64+yw*bs,1,12)
  end
end
end

end
