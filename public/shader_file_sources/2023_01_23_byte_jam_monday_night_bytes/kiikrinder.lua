-- pos: 0,0
-- Poking the VRAM to give me
-- colours I need. I wrote this before
-- the jam not to take too much time
-- on tediously copying RGB values.
function BOOT()
 poke(0x3FC3,0x50)poke(0x3FC4,0x16)poke(0x3FC5,0x15)
 poke(0x3FD8,0x36)poke(0x3FD9,0x68)poke(0x3FDA,0x76)
 poke(0x3FDB,0x53)poke(0x3FDC,0x90)poke(0x3FDD,0xA1)
 poke(0x3FE1,0x5B)poke(0x3FE2,0xCF)poke(0x3FE3,0xFA)
 poke(0x3FE4,0xF5)poke(0x3FE5,0xAB)poke(0x3FE6,0xB9)
 poke(0x3FE7,0xF4)poke(0x3FE8,0xF4)poke(0x3FE9,0xF4)
 poke(0x3FEA,0xEB)poke(0x3FEB,0xBA)poke(0x3FEC,0xB1)
 poke(0x3FED,0x94)poke(0x3FEE,0xB0)poke(0x3FEF,0xC2)
end

function givesamples(min,max)
 samples={}
 samplesAvg=0
 samplesMax=0
 for i=min,max do
   samples[i]=fft(i)*80
   samplesAvg=samplesAvg+samples[i]
   if (samples[i]>samplesMax) then
    samplesMax=samples[i]
   end
 end
 return {
   samples=samples,
   avg=samplesAvg/(max-min),
   max=samplesMax
 }
end

t=0
function TIC()
 cls(10)
 
 -- first time using fft
 -- lets see what we get
 bass=givesamples(0,15)
 mid=givesamples(16,127)
 high=givesamples(126,255)

 circ(120,68,110+bass.avg,11)
 circ(120,68,80+mid.max,12)
 circ(120,68,40+high.max,13)
 
 -- time for the star of the show
 move=-40+mid.avg*3
 
 elli(20,136-move,20,60,8)
 elli(220,136-move,20,60,8)

 elli(120,136-move,80,120,8)
 elli(120,136-move,60,90,13)
 elli(120,136-move,50,80,14)
 elli(120,136-move,60,50,13)
 elli(60,80-move,6,8,1)
 elli(60,80-move,5,7,0)
 circ(58,82-move,2,13)
 elli(180,80-move,6,8,1)
 elli(180,80-move,5,7,0)
 circ(182,82-move,2,13)
 -- do I just put them one by one?
 for i=0,3 do
  circ(80+i*10,100-i*5-move,5,13)
 end
 circ(120,83-move,5,13)
 for i=0,3 do
  circ(130+i*10,84+i*5-move,5,13)
 end
 -- good enough
 -- I could sin/cos this but
 -- there's not enough coffee
 -- in my bloodstream
 for i=0,3 do
  circ(80+i*7,83-i*8-move,5,13)
 end
 circ(113,55-move,5,13)
 circ(123,55-move,5,13)
 for i=0,3 do
  circ(135+i*7,56+i*8-move,5,13)
 end
 
 msg="TRANS RIGHTS      GREETINGS TO SCOTLAND     FUCKINGS TO TORIES"
 for i=0,#msg do
  print(msg:sub(i,i),((222+18*i-t+1)%1600)-20,20+12*math.sin(t/8+i)+1,3,1,3)
  print(msg:sub(i,i),((222+18*i-t)%1600)-20,20+12*math.sin(t/8+i),4,1,3)
 end
 
 t=time()//32
end
