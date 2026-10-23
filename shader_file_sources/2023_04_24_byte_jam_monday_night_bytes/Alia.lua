sin=math.sin
random=math.random
abs=math.abs
max=math.max
min=math.min

-- Greets to gasman, gigabates, nico,
-- h0ffman and ofc aldroidia! 
t=0

for i=0,16320*2 do
 pix(i%240,i//240,random()*15)
end
for i=0,15 do
 poke(0x03FC0+i*3+0,127+i*8)
 poke(0x03FC0+i*3+1,127+i*8)
 poke(0x03FC0+i*3+2,255)
end

f=0

function TIC()
 f=f*0.8
 for i=1,10 do
  f=f+fft(i)
 end
 
 vbank(1)
 --cls()
 local sx=sin(t/14.57)*2
 local sy=sin(t/17.57)*2
 local z=sin(t/12)*2+3
 ttri(
  0,0,
  239,0,
  0,135,
  sx-z/1.76,sy-z,
  239+sx+z/1.76,sy-z,
  sx-z/1.76,135+sy+z,
  2
 )
 ttri(
  239,0,
  0,135,
  239,135,
  239+sx+z/1.76,sy-z,
  sx-z/1.76,135+sy+z,
  239+sx+z/1.76,135+sy+z,
  2
 )
 
 memcpy(0x4000,0,16320)
 cls()
 --print("=^^=",2,33,15,0,10)
 --print("=^^=",5,30,12,0,10)
 local hpos=f/3
 local vpos=70+sin(t/8)*10
 
 --legs
 for x=-15,15,30 do
  for y=0,4 do
   circ(120+x+sin(t/4)*4*y/6,vpos+17+y*4,5,2+y%2)
  end
 end
 for x=-25,25,50 do
  for y=0,6 do
   circ(120+x+sin(t/4)*4*y/6,vpos+17+y*4,5,3+y%2)
  end
 end
 
 for x=0,40 do
  circ(
   120+sin(t+x/8)*x,
   vpos-20-((x/40)^.5)*40,
   4,3+x%2)
 end
 
 elli(120,vpos,40,20,3) --body
 --ears
 elli(108,vpos-34-hpos,7,7,3)
 elli(108,vpos-34-hpos,6,6,4)
 elli(132,vpos-34-hpos,7,7,3)
 elli(132,vpos-34-hpos,6,6,4)
 --head
 elli(120,vpos-18-hpos,25,15,15)
 elli(120,vpos-20-hpos,25,15,3)
 elli(120,vpos-15-hpos,10,6,12)
 rect(120-11,vpos-25-hpos,22,10,3)
 
 rect(120-25,vpos-20-hpos-4,51,4,14)
 circ(120-10,vpos-18-hpos-4,5,15)
 circ(120+10,vpos-18-hpos-4,5,15)
 circ(120-10,vpos-18-hpos-4,4,6)
 circ(120+10,vpos-18-hpos-4,4,6)
 
 print("HELICAPTPER CAT",35+sin(t/4)*24,122,15,0,2)
 print("HELICAPTPER CAT",35+sin(t/4)*20,120,12,0,2)
 
 vbank(0)
 memcpy(0,0x4000,16320)
 
 --for i=0,19 do
  --circb((sin(i+t*20)*120+t)%240,(sin(i*4+t*20)*68+t)%136,8,i)
 --end
 
 t=t+.3
end

function SCN(y)
 vbank(0)
 for x=0,239 do
  local r=random()*sin(x/50+t/4)*sin(y/50+t/5)
  r=r-.5
  pix(x,y,min(
  (
   pix(x,y)+pix(x+1,y)+pix(x,y+1)
   )/3+r+1
   ),15)
 end
 
 vbank(1)
 poke(0x03FC0+6*3+0,y*40-t*40)
 poke(0x03FC0+6*3+1,y*40-t*40)
 poke(0x03FC0+6*3+2,y*40-t*40)
 --vbank(0)
 --poke(0x03FF9,(sin(y/20+t/30+sin(y/17+t/8))*10)//1)
 --poke(0x03FFa,(y%16)*fft(1)*1-y%8+y%4-y%2)
 --vbank(1)
 --poke(0x03FF9,(sin(y/10+t/20)*10)//1)
end