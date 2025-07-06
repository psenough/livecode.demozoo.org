--ello!!!
--been a while since i've done a jam
--greetz to dave, suule and doop :)

sin=math.sin
cos=math.cos
rain={}

for i=1,200 do
rain[i]={math.random()*256,math.random()*256}
end

function TIC()
 cls(13)
 t=time()/100
 for i=-1,5 do
  elli(0+(i*64)+t*3%64,20,50,15,12)
 end
 
 for i=0,3 do
  house(0+i*71,60)
  line(0+i*71,40+60,0+i*71,112+60,1)
 end
 
 for i=1,200 do
 for j=0,3 do
  pix((rain[i][1]+t*8+j/2)%256,(rain[i][2]+t*48+j)%256,9+j/2)
 end
 end
 
 for i=-1,5 do
  elli(0+(i*64)+t*4%64,10,50,20,14)
 end
 for i=-1,5 do
  elli(0+(i*64)+t*5%64,5,50,15,15)
 end
 
 for i=0,3 do
  print("HOPE YOU PUT YER\n     BINS IN",25+sin(t/3+i/2)*4,4+sin(t+i/2)*2,15-i,true,2)
 end
 
 for k=0,3 do
  for j=0,8,4 do
   for i=(t*48%1700)-600,(t*48%1700)-440,3 do
    pix(0+sin(i/32+j/2)*32+i/4+j*8,50+cos(i/32+j/2)*(16+sin(i/32+k)*8)+k*8,12)
    pix(0+sin(i/32+j/2)*32+i/4+j*8,50+cos(i/32+j/2)*(16+sin(i/32+k)*8)+k*8+1,14)
   end
  end
 end
 
 brolly(-150+t*16%280,4+sin(t/2)*8)
 bin(-150+t*12%370,0+sin(t/3)*sin(t/7)*32)
 
end

function bin(x,y)
 rect(110+x,38+y,30,45,6)
 rect(106+x,38+y,36,5,7)
 rect(116+x,38-3+y,22,3,6)
 rect(110+x,80+y,4,8,6)
 circ(136+x,83+y,6,15)
end

function brolly(x,y)
 --stuck with maths here...
 for i=-4,4 do
  circ(120-sin(i/4)*16+x,68-cos(i/4)*16+y,3,1)
  circ(120+x,68+i*3+y,2,15)
 end
 for i=-1,2 do
  circ(113+sin(i/2)*8+x,78+cos(i/2)*8+y,2,15)
 end
end

function house(x,y)
 for i=0,72 do
  line(0+x,40+i+y,70+x,40+i+y,2+i%2)
 end
 rect(25+x,93+y,20,20,1)
 rect(4+x,46+y,15,25,12)
 rect(6+x,48+y,11,21,13)
 rect(4+24+x,46+y,15,25,12)
 rect(6+24+x,48+y,11,21,13)
 rect(4+48+x,46+y,15,25,12)
 rect(6+48+x,48+y,11,21,13)
 for i=0,10 do
  line(0+x,30+i+y,70+x,30+i+y,1+i%2)
 end
end