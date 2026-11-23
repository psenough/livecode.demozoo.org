--beep boop enfys

--haven't done a monday ham in a while!!
--greetz to aldroid, jtruk, pumpuli
--and reality404 :)

sin=math.sin
cos=math.cos

function drawbird(x,y,o)

 fv=(fft(0)+fft(1)+fft(2)+fft(3)+fft(4)+fft(5))
 --print(fv)
 sv=math.abs(sin(t/2+o))*3

 for i=0,1 do 
  circ(111+x+i,32+y-fv+sv,1,3)
  circ(111+x+i,33+y+fv+sv,1,3)
 end
 
 circ(120+x,35+y+sv,5,15)
 circ(118+x,32+y+sv,5,15)

 for i=0,10 do
  circ(119+x,55+i+y,1,3+i%2)
  circ(128+x,55+i+y,1,3+i%2)
 end

 for i=0,2 do
  circ(130+i*2+x,52+i+y+sv,3+i/2,15)
 end
 for i=0,1 do
  circ(123+i+x,43+i*4+y+sv,8+i,15-i)
 end
 for i=0,1 do
  circ(120+i+x,43+i*4+y+sv,5+i,2-i)
 end
 
 circ(117+x,30+y+sv,2,0)
end

lv={}
for i=1,32 do
 lv[i]={math.random()*256,math.random()*256,1+math.random()*4}
end

function TIC()
 cls(10)
 t=time()/100
 
 elli(280-t*4%330,18,40,5,12)
 elli(340-t*3%390,38,40,5,12)
 
 for i=1,#lv do
  circ(-2+(lv[i][1]-t*8+sin(t+i/4)*4)%256,-10+(2+lv[i][2]+t*6)%200,lv[i][3],7)
  circ(-4+(lv[i][1]-t*8+sin(t+i/4)*4)%256,-10+(lv[i][2]+t*6)%200,lv[i][3],6)
 end
 
 for i=16,64 do
  circ(200+i*2,38+i*4+(sin(i/8+1)*8),i,3)
  circ(201+i*2,38+i*4+(sin(i/8+1)*8),i,2)
 end
 for i=0,72 do
  circ(100+i*2,68+i+(sin(i/8+3)*8),i/6,3)
  circ(101+i*2,68+i+(sin(i/8+3)*8),i/6,2)
 end
 for i=0,48 do
  circ(170+i*2,38+i+(sin(i/8+2)*8),i/6,3)
  circ(171+i*2,38+i+(sin(i/8+2)*8),i/6,2)
 end
 for i=0,72 do
  circ(130+i*2,42+i+(sin(i/8+1)*8),i/6,3)
  circ(131+i*2,42+i+(sin(i/8+1)*8),i/6,2)
 end

 for i=0,3 do
  drawbird(-10+i*32,5+i*18,i)
 end

end
