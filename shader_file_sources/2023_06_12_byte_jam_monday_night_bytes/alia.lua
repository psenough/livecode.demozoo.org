
for y=0,135 do
 for x=0,239 do
  if y>95 then
   pix(x,y,13+math.random()*4)
  else
  	local col=((x)%8<4 and 1 or 0)
  	pix(x,y,13+col)
  end
 end
end

for i=0,12 do
 print("bopalong\n   cats",0+i,30-i,i,0,3)
end

t=0
t2=0
fs={0,0,0}

function cat(i,x,y)
-- 40w
 -- body
 elli(x,y,20,30,3)
 elli(x,y-5,15,20,12)
 
 -- head
 local hpos=y-30-fs[2]
 elli(x,y-hpos+1,18,13,2)
 elli(x,y-hpos,18,13,3)
 -- mouth
 elli(x,y-hpos+3,10,4,12)
 elli(x,y-hpos,12,3,3)
 -- eyes
 elli(x-8,y-hpos-3,5,3,12)
 elli(x+8,y-hpos-3,5,3,12)
 elli(x-8,y-hpos-3,2,3,15)
 elli(x+8,y-hpos-3,2,3,15)
 
 -- hat
 elli(x,y-hpos-10,23,3,7)
 rect(x,y-hpos-20,8,12,5)
 rect(x+8,y-hpos-20,3,12,6)
 rect(x-12,y-hpos-20,12,12,7)
 
 -- legs
 for i=0,8 do
  elli(x-12,y+22+i*3,4,6,3+i%2)
  elli(x+12,y+22+i*3,4,6,3+i%2)
 end
 -- feets
 local xpos=-15
 local off=0
 for i=0,5 do
 	if i==3 then off=20 end
  local ypos=math.max(0,fs[1]-2)*(off>=3 and 1 or 0) 
  elli(x+xpos+i*2+off,y+50-ypos/2,1,2,12)
 end
 
 -- upper legs
 xpos=0
 xpos2=0
 local off1=math.sin(t2/3+i)
 local off2=math.cos(t2/3+i)
 for i=0,8 do
  elli(x-20-xpos,y-5+i*2,4,4,3+i%2)
  elli(x+20+xpos2,y-5+i*2,4,4,3+i%2)
  xpos=xpos+fs[3]+off1
  xpos2=xpos2+fs[3]+off2
 end
 for i=0,8 do
  elli(x-20-xpos,y+11+i*2,4,4,3+i%2)
  elli(x+20+xpos2,y+11+i*2,4,4,3+i%2)
  xpos=xpos-fs[3]+off2
  xpos2=xpos2-fs[3]+off1
 end
end

function TIC()
 poke(0x3FFB,0)
 t=t+1
 
 fs[1]=fs[1]*.8+(fft(0)+fft(1)+fft(2)+fft(3)+fft(4))
 fs[2]=fs[2]*.8+(fft(10)+fft(11)+fft(12)+fft(13)+fft(14))
 fs[3]=fs[3]*.8+(fft(20)+fft(21)+fft(22)+fft(23)+fft(24))
 t2=t2+fs[3]
 
 vbank(1)
 cls()
 for i=0,3 do
 	local x=i*80-t*1.5
 	x=x%300-30
 	cat(i,x,48)
 end
 local str={"greets to","gasman","visy","tobach","aldroidia","and you"}
 print("love u all =^^=",10,120,12,0,2)
end

function SCN(y)
 vbank(0)
 local o=t*math.max(1,(y-85)/10)
 poke(0x3FF9,-o%240-120)
  
 vbank(1)
 poke(0x3FF9,y>119 and -o%240-120 or 0)
end
