t=0
w=30 h=23
abs=math.abs
sin=math.sin
f=0
function TIC()
 vbank(0)
 cls(14)
 for y=0,136//h do
  for x=0,240//w do
   local x=x*w 
   local y=y*h
   --rectb(x,y,w,h,12)
   elli(x+15,y+17,13,5,15)
   elli(x+15,y+12,13,5,3)
   
   local hh=abs(sin(t/8))*3
   elli(x+22,y+9-hh,6,4,2)
   elli(x+22,y+8-hh,6,4,3)
   
   elli(x+22,y+7-hh,4,2,12)
   rect(x+18,y+6-hh,8,2,3)
   --rect(x+18,y+6-hh,8,2,3)
   
   for i=0,4 do
    circ(x+7+i*3,y+16,2,3+i%2)
   end
 
  end
 end
 
 --local f=0
 f=f*.9
 for i=0,10 do
  f=f+fft(i)
 end
 
 local yo=abs(sin(t/16))*8*f*.2
 local y2=abs(sin(t/16+1))*4*f*.3
 vbank(1)
 cls(0)
 for i=0,12 do
  circ(147+i*5,
   80+sin(t/4+i)*8*(i/12)*f*.2,
   5,13+i%2)
 end
 for i=0,4 do
  circ(120+i*3,
  40+i*10-yo,
  15,i%2+13)
 end
 
 circ(100,10-y2,8,13)
 circ(88,10-y2,10,0)
 
 elli(105,26-y2,18,15,14)
 elli(105,25-y2,18,14,13)
 
 elli(95,23-y2,3,6,12)
 elli(94,23-y2,2,4,14)
 
 for i=0,4 do
  circ(122-yo*(4-i)/4,110-i*5-yo,6,13+i%2)
  circ(122-yo*(4-i)/4,115+i*5-yo,6,13+i%2)
  
  circ(142+yo*(4-i)/4,110-i*5-yo,6,13+i%2)
  circ(142+yo*(4-i)/4,115+i*5-yo,6,13+i%2)
  
  circ(102-yo*(4-i)/4,65-i*5-yo,6,13+i%2)
  circ(102-yo*(4-i)/4,65+i*5-yo,6,13+i%2)

  circ(132+yo*(4-i)/4,65-i*5-yo,6,13+i%2)
  circ(132+yo*(4-i)/4,65+i*5-yo,6,13+i%2)
 end
 
 circ(100,10-y2,8,13)
 circ(88,10-y2,10,0)
 
 elli(105,26-y2,18,15,14)
 elli(105,25-y2,18,14,13)
 
 elli(95,23-y2,3,6,12)
 elli(94,23-y2,2,4,14)
 
 --print("=^^=",5,30,12,0,10)
 t=t+1
end

function SCN(y)
 local s=(y//h)/3+.5
 s=s*t
 local f=fft((y-t)%136)
 vbank(0)
 poke(0x03FF9,f*100+(s%240))
 poke(0x03FFA,f*200)
 vbank(1)
 poke(0x03FF9,f*100-(t+sin(y/50+t/16)*30)%240-120)
 poke(0x03FFA,f*200)
 
end
