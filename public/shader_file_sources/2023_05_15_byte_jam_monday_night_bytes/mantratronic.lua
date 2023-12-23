-- mt here
-- greets to alia, nusan, jtruk,
--   synesthesia, aldroid + the wolf

ffth={}
fn = 7
clouds={}
nc=50

function BOOT()
 for i=1,fn do
  ffth[i] = {}
  for j=0,255 do
   ffth[i][j] = 0
  end
 end
 
 for i=1,nc do
  clouds[i] = {x=math.random()*260,y=math.random(50),s=math.random(10)}
 end
end

function BDR(l)
 if l==0 then
  for i=0,13 do
   poke(0x3fc0+i*3, i*17)
   poke(0x3fc0+i*3+1, 100+i*10)
   poke(0x3fc0+i*3+2, i*17)
  end
   poke(0x3fc0+14*3, 255)
   poke(0x3fc0+14*3+1, 255)
   poke(0x3fc0+14*3+2, 255)
   poke(0x3fc0+15*3, 50)
   poke(0x3fc0+15*3+1, 75)
   poke(0x3fc0+15*3+2, 255)
 end
 
 
 
end

function TIC()t=time()/200
 cls(15)

 for i=1,fn do
  for j=255,1,-1 do
   ffth[i][j] = ffth[i][j-1]
  end
  ffth[i][0]=0
  for j=(255/fn)*(i-1),(255/fn)*(i) do
   ffth[i][0] = ffth[i][0] + fft(j)
  end
  ffth[i][0] = (ffth[i][0] + ffth[i][1])/2
 end
 
 for i=1,nc do
  clouds[i].x = clouds[i].x - 0.5
  if clouds[i].x < -10 then
   clouds[i] = {x=260,y=math.random(50),s=math.random(10)}
  end
  circ(clouds[i].x-10,clouds[i].y,clouds[i].s,14)
 end
 len=print("greets to everyone in the chat",240,20,14,false,2)
 
 print("greets to everyone in the chat",240-(t*2)%(len+240),20,14,false,2)
 
 for x=0,239 do
  tx=239-x
  for f=1,fn do
   line(x,50+f*6-((10-(fn-f)))*ffth[f][tx//f],x,89,14-f*2)
  end
  --[[
  line(x,69-7*ffth[1][tx],x,89,13)
  line(x,74-20*ffth[2][tx//2],x,89,10)
  line(x,79-20*ffth[3][tx//3],x,89,7)
  line(x,84-15*ffth[4][tx//4],x,89,4)
  line(x,89-10*ffth[5][tx//5],x,89,1)
  --]]
 end

 for y = 0,45 do
  by=y+90
  memcpy(by*120,math.min(89,(math.sin(y+t)*2+90-y*1.5))//1*120,120)
  
  -- shift left right a bit
  shift = math.random(2)-1
  memcpy(by*120+shift,by*120,120+shift)

 end
 
 

end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

