--lets try this again shall we...
--greetz to mantratronic, evilpaul
--jtruk and reality \o/ <3
sin=math.sin
cos=math.cos
fv2=0
text="HARDCORE GREETZ GO OUT TO RIFT, TUHB, SLIPSTREAM, TREPAAN, DESIRE, MARQUEE DESIGN, UR MUM"
function TIC()
 untz=fft(0)+fft(1)+fft(2)+fft(3)+fft(4)+fft(5)*512
 high=fft(200)+fft(201)+fft(202)+fft(203)*256
 cls(0)
 t=time()//32
 
 for j=0,136,2 do
  for i=0,240,2 do
   fv=i/32+sin(j/(4+untz/16)+sin(i/2+t/4)+t/16)
   off=untz/32
   pix(i,j,8+fv%4-off)
   pix(i+1,j,8+fv%4+1-off)
   pix(i,j+1,8+fv%4+1-off)
   pix(i+1,j+1,8+fv%4-off)
  end
 end
 
 for j=0,16 do
  for i=0,32 do
   --circ(i*8,j*32+sin(i+t/4)*untz/8,4,1+untz/32)
  end
 end
 
 sheep(-untz/8)

 --print(untz)
 --print(fv2,0,6)
 
 for i=1,#text do
  c=text:sub(i,i)
  print(c,240+i*12-t*4%1500+1,116+sin(t/4+i*2)*untz/16+1,0,true,2)
  print(c,240+i*12-t*4%1500,116+sin(t/4+i*2)*untz/16,untz/16,true,2)
 end
 
end

function sheep(y)

 rect(102,90+y,5,20,0)
 rect(137,90+y,5,20,0)
 elli(122,70+y,35,25,0)
 elli(95,57+y,10,13,0)
 elli(157,77+y,4,10,0)

 rect(100,88+y,5,20,15)
 rect(135,88+y,5,20,15)
 elli(120,68+y,35,25,12)
 elli(93,55+y,10,13,15)
 elli(155,75+y,4,10,12)
 
end