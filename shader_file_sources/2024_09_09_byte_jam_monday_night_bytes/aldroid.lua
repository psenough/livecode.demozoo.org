s=math.sin
c=math.cos

function SCN(l)
o=3*11
poke(0x3fc0+o,l+110)
poke(0x3fc1+o,10+l+130)
end

function dorib(t,clm,clo, of, wi)
 for y=70,105,1 do
 sox=-120+s((y+1)*0.1+t*0.01)*100
 soy=of+y*wi
 for i=0,45,0.5 do
  cv = ((i+y//3+y)%1)*20 +2
  cv = cv *clm +clo
  circ(sox+i*10,(s((t+i)/100)*10)+soy+s(t/90+y*0.01+i/10)*2*(i-5)*wi,3,cv)
 end
end
end

function cld(x,y)
circ(x-7,y+4,5,12)
circ(x,y-2,5,12)
circ(x,y+4,5,12)
circ(x+7,y+4,5,12)
end

function TIC()
 t=time()/10
 cls(11)
 rect(0,90,240,45,10)
 for i=0,300,50 do
  cld((i+t)%300,40-fft(i)*1*(50+i))
 end
 dorib(t,0,9,100,0.4)
 dorib(t,1,0,0,1)
end
