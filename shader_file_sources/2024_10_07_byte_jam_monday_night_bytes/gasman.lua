-- hello from gasman o/
-- greetings to puffuli, roeltje,
-- catnip, aldroid and guywithdog!
-- have a good jam all

words={".the",".dog",".will",".make",".you",".happy"}

function TIC()
 cls()
 t=time()
 word=words[(t//480)%6+1]
 ry=t/1234--math.sin(t/2345)

 cx=math.sin(t/1357)/2
 cy=math.sin(t/1468)/2

 tz=t/3456
 for k=0,1 do
  for a=0,1,0.05 do
   at=a*2*math.pi
   for b=-3,3,0.1 do
    bt=3-(b+tz)%6
    if k==1 then
     fftv=fft(b*8)
     x0=(math.cos(at)*2*1.3*(0.2+fftv))+cx
     y0=(math.sin(at)*2*(0.2+fftv))+cy
    else
     x0=(math.cos(at)*1.3)+cx
     y0=(math.sin(at))+cy
    end
    z0=bt*5
    x1=x0*math.cos(ry)+z0*math.sin(ry)
    y1=y0
    z1=z0*math.cos(ry)-x0*math.sin(ry)
    if z1>0 then
     x2=x1*1/(z1+1)
     y2=y1*1/(z1+1)
     sx=120+x2*200
     sy=68+y2*200
     if k==1 then
      circ(sx,sy,2,b*15+1)
     elseif k==0 then
      print(word,sx,sy,(b*15)%4+12,false,1,true)
     end
    end
   end
  end
 end

 for b=-3,3,0.1 do
  fftv2=fft(b*8)
  lastx=-1
  lasty=-1
  for a=0,1,0.2 do
   at=a*2*math.pi+b*5
   bt=3-(b+tz)%6
   x0=(math.cos(at)*1.3*0.3)+cx
   y0=(math.sin(at)*0.3)+cy
   z0=bt*5
   x1=x0*math.cos(ry)+z0*math.sin(ry)
   y1=y0
   z1=z0*math.cos(ry)-x0*math.sin(ry)
   if z1>0 then
    x2=x1*1/(z1+1)
    y2=y1*1/(z1+1)
    sx=120+x2*200
    sy=68+y2*200
    if lastx>0 then
     line(lastx,lasty,sx,sy,fftv2*32)
    end
    lastx=sx
    lasty=sy
   else
    lastx=-1
    lasty=-1
   end
  end
 end

end
