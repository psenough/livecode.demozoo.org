function BDR(y)
vbank(0)
poke(0x3FF9,math.sin(y/30+t/10)*10)
vbank(1)
poke(0x3FF9,math.sin(y/15+t/10)*20)
end

function TIC()
t=time()//32
cls(0)
--for y=0,136 do for x=0,240 do
--pix(x,y,(x+y+t)>>3)
--end end
amp=70

vbank(0)
for y=-68,67 do
 for x=-120,119 do
 Y=60000/math.sqrt(x^2+y^(3))
 X=(math.atan2(y,x)/math.pi+1)/2*255
 Y2=60000/math.sqrt(x^2+y^(2))
-- if Y<0 then Y=Y2 end
 ff=fft((X+t)//1%255)*1.005^((X+t)//1%255)
 if Y>0 then
 pix(x+120,y+68,(ff*amp+Y/100+t*.7)%(5)+8*(t//150%2))
 else
  if Y2<5000 then
  pix(x+120,y+68,(ff*amp+Y2/100+t*.7))
  end
 end
 end
end
vbank(1)
for x=0,240 do

line(x,0,x,fft(x)*amp*4,1+fft(x)*amp+8*((t//150+1)%2))
line(x,136,x,136-fft(x)*amp*4,1+fft(x)*amp+8*((t//150+1)%2))
end
vbank(0)
end
