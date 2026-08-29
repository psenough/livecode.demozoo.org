--tobach here
--GUESS WHO FELL ASLEEP
--TIME TO MAKE SOMETHING IN 30 MINS!!!
--greetz to synackster, evilpaul and truck <3
sin=math.sin
cos=math.cos
abs=math.abs
function TIC()
t=time()//32
cls(13)
rect(0,88,240,68,14)
circ(180,30,10,12)
line(180,30,180-sin(t/8)*8,30+cos(t/8)*8,0)
line(180,30,180-sin(t/60)*4,30+cos(t/64)*4,0)
circb(180,30,10,8)

rect(15,60,5,50,3)
rect(15,70,90,20,3)
rect(100,80,5,30,3)
print("z",28+sin(t/4)*6,65-t*2%68,15)
rect(20,65,20,10,12)
circ(28,68+sin(t/16)*1.5,7,4)
rect(20,70,80,30,7)

elli(175,80,40,30,12)
ellib(175,80,40,30,15)

circ(120,50,8,12)
circ(90,45,6,12)
circ(70,50,4,12)
circ(50,60,3,12)
circb(120,50,8,15)
circb(90,45,6,15)
circb(70,50,4,15)
circb(50,60,3,15)

rect(150,60,50,40,11)
rect(150,90,50,10,6)
rect(173,85,3,10,3)

xval=sin(t/4+3/2)*12
yval=-abs(sin(t/4)*16)
sheepval=math.floor(t/12)
rect(178+xval,93+yval,2,6,15)
rect(170+xval,93+yval,2,6,15)
elli(175+xval,90+yval,8,5,12)
circ(168+xval,90+yval,3,15)
print(sheepval,170,102)

for i=0,3 do
 print("sorry for oversleeping the stream, it won't happen next time i promise <3",240+i-t*5%1400,120+i-abs(sin(t/4)*8),i+8,true,2)
end

end
