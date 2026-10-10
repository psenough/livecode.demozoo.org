--hellooooo!!!
--greetz to mantra, alia, nusan and suule <3

coltab={11,10,9,8,1,2,3,4,12}
snowflakes={}
sin=math.sin
abs=math.abs
for i=1,200 do
 snowflakes[i]={math.random()*256,math.random()*256}
end
function TIC()
 t=time()/10
 cls()
 --sorry for any stumbling in my code!
 --i got out of bed about 10 mins before
 --the jam... :)
 
 for i=0,8 do
  rect(0,126-i*16,240,16,coltab[i])
 end
 tri(40,100,120,20,200,100,9)
 tri(40,100,140,24,200,100,9)
 tri(90,50,120,20,140,50,12)
 tri(90,50,140,28,169,60,12)
 
 rect(0,100,240,40,12)
 rect(0,102,240,40,12)
 rect(0,103,240,8,14)
 rect(0,104,240,8,15)
 
 for i=0,1 do
  rect((t*4%240),45,2,60,15)
  rect(2+(t*4%240),45,2,60,14)
 end
 
 shinkansen(0+sin(t/64)*8)
 
 for i=0,10 do
  rect(-32+(i*32)+(t*4%32),100,3,20,14) 
 end
 
 for i=0,480 do
  sv=abs(sin(i/80)*8)
  pix(-250+i+(t*4%240),50+sv,15)
  pix(-250+i+(t*4%240),51+sv,14)
 end
 
 elli(260-t/16%280,40,20,2,13)
 elli(261-t/16%280,41,20,2,12)

 elli(260-t/12%280,30,20,2,13)
 elli(261-t/12%280,31,20,2,12)
 
 for i=1,200 do
  if i%2==0 then
   rect((snowflakes[i][1]+sin(t/32*i/4)+t)%256,(snowflakes[i][2]+t)%256,2,2,12)
  else
   pix((snowflakes[i][1]+sin(t/32*i/4)+t*2)%256,(snowflakes[i][2]+t)%256,12)
  end
 end

end

function shinkansen(x)
 for i=0,8 do
  circ(30+i*6+x,98-i,4+i,12)
 end
 rect(82+x,78,180,25,12)
 line(68+x,93,280+x,93,8)
 for i=0,24 do
  elli(76+i*9+x,86,3,4,7)
 end
 rect(26+x,98,240,5,15)
 for i=0,8 do
  line(45+x+i*3,88-i,55+x+i*2,88-i,15)
 end
end