--hello lovebyte!!!!!
--glad to be taking part in the byte jam
--this year!!! :)

--greetz to aldroid, gasman, jtruk, mantra
--synackster, suule, visy and you !!

hearts={}
for i=1,100 do
 hearts[i]={math.random()*256,math.random()*320}
end

sin=math.sin
cos=math.cos

--surprisingly this is the first time
--i've even messed around with the
--palette and vbank in a jam lol

--red like the blood of my enemies!!!1
for i=0,15 do
 vbank(1)
 a=0x3fc0+(i*3)
 poke(a,i*16)
 poke(a+1,i*2)
 poke(a+2,i*2)
end

function SCN(ln)
 vbank(0)
 poke(0x3fc0,255)
 poke(0x3fc1,ln)
 poke(0x3fc2,ln)
end

function TIC()
 t=time()/100
 fv=fft(0)+fft(1)+fft(2)+fft(3)+fft(4)*8
 vbank(0)
 cls((t/4)//1)
 vbank(1)
 cls(0)
 for j=0,32 do
  for i=0,32 do
   circ(i*16+sin(j+t+i/2)*8,j*16,4+fv+sin(i+t/2)*8,j+6)
   circ(i*16+sin(j+t+i/2)*8,j*16,4+fv+sin(i+t/2)*8-2,j+6-2)
  end
 end
 for j=-1,1 do
  for i=-1,1 do
   print("LOVE\nBYTE",28+i,28+j,1,true,8)
  end
 end

  print("LOVE\nBYTE",28,28,1+fv*2,true,8)
 for i=50,100 do
  drawheart((hearts[i][1])+sin(t/3+i)*8-120,(hearts[i][2]-(t*i/8))%256-90,fv/2+i%8+1)
 end
 --print(fv,0,0,1)
end

--not sure what to add next
--i think this could be it from this
--this year :3

function drawheart(x,y,col)
 circ(115+x,68+y,8,col)
 circ(125+x,68+y,8,col)
 circ(120+x,74+y,8,col) 
 circ(115+x,68+y,6,col+1)
 circ(116+x,69+y,5,col)
end