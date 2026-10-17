-- HELLO MONDAY NIGHT BYTES!
-- hope you are well
-- thank you reality for hosting again
-- and Px for the tunes!
-- glhf to my fellow jammers,
-- jtruk, pumpuli, and enfys

function haz(ofs)
 ww=30
 cl=0
 for h=0,239,ww do
 x1=ofs
 x2=ofs+ww
 y1=h-ww
 y2=h
	y3=h+ww
	
 
 tri(x1,y1,x2,y2,x1,y2,4*cl)
 tri(x1,y2,x2,y2,x2,y3,4*cl)
 cl = (cl + 1) % 2
 end
end

S=math.sin
C=math.cos

function SCN(l)
vbank(0)
poke(0x3fc0+3*10+0,255-l)
poke(0x3fc0+3*10+1,255-l)
poke(0x3fc0+3*10+2,115+l)
poke(0x3fc0+3*15+0,115+l)
end

function TIC()
 tng = math.floor(time()/6000)
 vbank(0)
 cls(15)
 circ(140,40,30,12)
 circ(120,40,40,15)
 
 circ(120,1500,1420,10)
 vbank(1)
 poke(0x03FF8, 14)
 dp= 30*math.atan(S(2*math.pi*time()/6000)*80)
 cls(13)
 rect(60+dp+15,0,91-dp*3,136,14)
 
 rectb(-30+dp,80,60,25,15)
 print("WARNING",-25+dp,85,15)
 warningmes = {
  "jtruk",
  "px",
  "reality",
  "pumpuli",
  "enfys",
  "Airlock",
  "Space",
  "Outdoors",
  "Big door",
  "Muuuuun",
  "Bytejam",
  "Self doubt"
 }
 print(warningmes[(tng % #warningmes)+1],-25+dp,95,15)
 line(-20+dp,0,-20+dp,80,15)
 line(-30+60+dp,85,60+dp,85,15)
 
 rectb(200-dp,20,17,25,15)
 circ(200-dp+8,27,4,2)
 if (time()//800)%2 == 0 then
 circ(200-dp+8,27,3,3)
 end
 haz(60-15+dp)
 haz(180-15-dp)
end