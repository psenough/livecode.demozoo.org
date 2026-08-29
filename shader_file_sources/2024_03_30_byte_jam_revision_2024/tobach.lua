--ohhh yea, i'm on stage
--hello revision!!!
--greetz to gasman, jtruk, aldroid,
--violet, nusan and numtek <3

sin=math.sin
cos=math.cos
abs=math.abs
saustab={}
currtab={}
for i=1,20 do
 saustab[i]={math.random()*80,math.random()*10}
end

for i=1,100 do
 currtab[i]={math.random()*100,math.random()*30}
end

curstr="Currywurst"
rvsnstr="Revision 2024"

function heart(x,y)
 --this is cheap don't do this
 tri(109+x,68+y//1,120+x,85+y//1,132+x,68+y//1,1)
 circ(115+x,68+y,6,1)
 circ(125+x,68+y,6,1)
 tri(110+x,68+y//1,120+x,83+y//1,131+x,68+y//1,2)
 circ(115+x,68+y,5,2)
 circ(125+x,68+y,5,2)
end

function TIC()
 cls()
 t=time()//32
 --this is boring, lets do a plasma :3
 --for i=0,135 do
  --line(0,i,240,i,sin(i/8+t/4+sin(i/3+t/3))*2+t/8)
 --end

 --what an absolute CHOON this is!!!
 for i=0,2 do
  print("Greetz to... Slipstream, RiFT, Poo-Brain, Bitshifters, Torment, Logicoma, Marquee Design, Lemon., Team210, 5711, TUHB, FTG, DESiRE,  and you !!",240-t*8%7200-i*3,70-abs(sin(t/4)*32)-i*3,i+2,true,8)
 end
 --thank you xxx for the currywurst delivery
 --hahahaha <3
 
 for y=0,135,2 do
  for x=0,239,2 do
   c=10+sin(x/32+y/17+t/4)*sin(y/32+sin(x/13+t/4)*sin(t/32+x/16))*2+t/8
   pix(x,y,c)
  end
 end
 
 elli(120,84,50,20,12)
 elli(120,68,70,30,12)
 ellib(120,68,70,30,13)
 ellib(120,68,60,20,13)
 elli(120,68,55,18,2)
 for i=1,100 do
  pix(75+currtab[i][1],55+currtab[i][2],3)
 end

 elli(120,48,21,16,3)
 elli(120,48,20,15,4)
 elli(120,43,15,10,12)
 rect(120,20,4,18,4)
 rect(119,35,2,5,4)
 rect(123,35,2,5,4)

 --this is making me hungry now...
 --should've seen it coming :D

 for i=1,20 do
  for j=0,5 do
   circ(80+saustab[i][1],saustab[i][2]+58+j,8,1)
   circ(80+saustab[i][1],saustab[i][2]+58+j,7,3)
  end
 end
 for i=1,100 do
  pix(70+currtab[i][1],50+currtab[i][2],4)
 end
 for i=1,#curstr do
  --took long enough to figure out
  --lol
  c=string.sub(curstr,i,i)
  for j=0,2 do
   print(c,45+i*12+j,115+j+sin(i/2+t/4)*4,14-j,true,2)
  end
 end
 
 --cba making it into a function lol
 for i=1,#rvsnstr do
  c=string.sub(rvsnstr,i,i)
  for j=0,2 do
   print(c,30+i*12+j,10+j+sin(i/2+t/4+2)*2,14-j,true,2)
  end
 end
 --love when it swaps keyboard
 --layouts in the middle of a jam....
 heart(-80,50+sin(t/4)*2)
 heart(80,50+sin(t/4)*2)

end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>