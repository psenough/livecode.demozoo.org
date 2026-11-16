-- Big ups to MrSynAckster, Alia,
-- Dave84, jtruk, NuSan, Mantratronic
-- ToBach and Superogue!
-- Thank you Lynn for the choons!

-- Starting with a palette
-- pre-made before the jam
function BOOT()
 poke(0x3FC3,245)
 poke(0x3FC4,169)
 poke(0x3FC5,184)
 poke(0x3FCF,220)
 poke(0x3FD0,252)
 poke(0x34D1,218)
 poke(0x3FD5,90)
 poke(0x3FD6,132)
 poke(0x34D7,87)
 poke(0x3FDE,91)
 poke(0x3FDF,206)
 poke(0x3FE0,250)
 poke(0x3FE7,179)
 poke(0x3FE8,179)
 poke(0x3FE9,177)
end

function drawCat(sX,sY)
 tri(sX,sY+48,sX+16,sY,sX+48,sY+32,13)
 tri(sX+3,sY+48+3,sX+16,sY+3,sX+48-3,sY+32+3,1)
 tri(sX+47,sY+32,sX+64,sY+20,sX+80,sY+32,13)
 tri(sX,sY+48,sX+48,sY+32,sX+16,sY+80,13)
 tri(sX+16,sY+80,sX+48,sY+32,sX+32,sY+96,13)
 tri(sX+32,sY+96,sX+48,sY+32,sX+64,sY+104,13)
 tri(sX+48,sY+32,sX+64,sY+104,sX+80,sY+32,13)
 tri(sX+64,sY+104,sX+80,sY+32,sX+96,sY+96,13)
 tri(sX+80,sY+32,sX+96,sY+96,sX+118,sY+80,13)
 tri(sX+80,sY+32,sX+118,sY+80,sX+128,sY+48,13)
 tri(sX+80,sY+32,sX+112,sY,sX+128,sY+48,13)
 tri(sX+80+3,sY+32+3,sX+112,sY+3,sX+128-3,sY+48+3,10)
 
 trib(sX+20,sY+60,sX+44,sY+60,sX+32,sY+44,0)
 trib(sX+84,sY+60,sX+108,sY+60,sX+96,sY+44,0)
 trib(116,88,124,88,120,92,0)
 
 line(120,100,110,108,0)
 line(110,108,100,100,0)
 line(100,100,103,97,0)
 
 line(120,100,130,108,0)
 line(130,108,140,100,0)
 line(140,100,133,97,0)
end


t=0
function TIC()
	cls(9)
		
 for i=0,120 do
  s=getSamples(2*i,2*i+1)
  c=i%3+5
  line(i,68,i,68-s.avg*20,c)
  line(240-i,68,240-i,68-s.avg*20,c)
  line(i,69,i,69+s.avg*20,c)
  line(240-i,69,240-i,69+s.avg*20,c)
 end
 
 drawCat(56,18)
 
 s1=getSamples(0,40)
 s2=getSamples(41,80)
 
 poke(0x3FC3,245*math.max(1,(s1.avg*20)))
 poke(0x3FC4,169*math.max(1,(s1.avg*20)))
 poke(0x3FC5,184*math.max(1,(s1.avg*20)))
	
	poke(0x3FDE,91*math.max(1,(s2.avg*20)))
 poke(0x3FDF,206*math.max(1,(s2.avg*20)))
 poke(0x3FE0,250*math.max(1,(s2.avg*20)))
	
	msg="GREETS TO EVERYONE! PROTECT TRANS KIDS"
	for i=0,#msg do
  print(msg:sub(i,i),((222+18*i-t*5)%800)+1,50+12*math.sin(t)+1,9,1,3)
	 print(msg:sub(i,i),((222+18*i-t*5)%800),50+12*math.sin(t),12,1,3)
	end
	
	t=t+0.2
end

function getSamples(min,max)
 s={}
 sAvg=0
 sMax=0
 for i=min,max do
  s[i]=fft(i)
  sAvg=sAvg+s[i]
  if s[i]>sMax then
   sMax=s[i]
  end
 end
 return {
  samples=s,
  avg=sAvg/(max-min),
  max=sMax
 }
end