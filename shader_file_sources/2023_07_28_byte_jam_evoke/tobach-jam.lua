sin=math.sin
cos=math.cos
abs=math.abs
flr=math.floor
fv=0

function TIC()
 t=time()/100
 for y=0,135 do
  for x=0,239 do
   sv=flr(sin(x/(16+sin(t/2)*8)+cos(t/4)*2+t)*sin(y/(16+sin(t/2)*8)+sin(t/2)*2))
   pix(x,y,flr(sv+y/16-t/2))
  end
 end
 
 for j=0,16 do
  for i=0,16 do
   circ(-48+i*24+sin(j/4+t/4)*64,0+j*18+sin(j/4+t)*8,5,i)
  end
 end
 
 for i=0,3 do
  print("EVOKE 2023",28+i,68+i-abs(sin(t)*16),15-i,true,3)
 end
 
 --print(fv,0,0,2,2)
 for i=0,256 do
  fv=fft(i)*256
  --line(i,135,i,135-fv,i)
 end
end

