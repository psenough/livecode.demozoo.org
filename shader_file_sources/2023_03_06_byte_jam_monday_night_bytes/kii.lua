lastChange=0
effect=0

function TIC()
 cls(9)
 t=time()//32
 
 if (time()-lastChange>5000) then
  effect=(effect+1)%3
  lastChange=time()
 end
 
 rect(90,10,120,26,0)
 rect(95,10,100,16,15)
 print("Classic viz vol. 1",97,17,12)
  
 rect(10,36,220,100,13)
 
 max=0
 maxBass=0
 maxMid=0
 maxHigh=0
 for i=0,254 do
  if (fft(i)>max) then
   max=fft(i)
  end
  
  if (i>=16 and i<128) then
   if (fft(i)>maxMid) then
    maxMid=fft(i)
   end
  end
  
  if (i>=128 and i<255) then
   if (fft(i)>maxHigh) then
    maxHigh=fft(i)
   end
  end
  
  if (i>=0 and i<16) then
   if (fft(i)>maxBass) then
    maxBass=fft(i)
   end
  end
 end
 
 if (effect==1) then
  for y=41,131 do
   for x=15,180 do
    pix(x,y,(x+y+t)>>3)
   end
  end
 end
 
 if (effect==2) then
   for y=41,131 do
   for x=15,180 do
    pix(x,y,10*max+math.sin(x/8)+math.sin(y/16)+t/8)
   end
  end
 end
  
 if (effect==1) then
  for y=41,131 do
   for x=15,180 do
    x1=math.atan2(y,x)
    y1=(x*x+y*y+1)^0.5
    c=(x1//1)~(y1//1)+t
    pix(x,y,c*math.sin(max+t/128)/20)
   end
  end
 end
 
 if (effect==0) then
  rect(15,41,165,90,15)
  for x=15,180 do
   mag=32*math.sin(2*math.pi*(x/50))
   
   y=mag*math.sin(x*maxBass)+82
   if (y>=41 and y<=131) then
    pix(x,y,2)
   end
   
   y=mag*math.sin(x*maxMid)+82
   if (y>=41 and y<=131) then
    pix(x,y,4)
   end
   
   y=mag*math.sin(x*maxHigh)+82
   if (y>=41 and y<=131) then
    pix(x,y,6)
   end
  end
 end
  
 circ(205,50,7,15)
 
 tri(205,45,209,49,201,49,2)
 
 circ(205,110,18,15)
 for n=-20,20,9 do
  for m=0,3 do
   line(187,92+m+n,223,128+m+n,13)
	 end
 end
  
 for n=0,1 do
  for m=0,4 do
   c=1
   if (max>0.2 and m==4) then c=6 end
   if (max>0.4 and m==3) then c=6 end
   if (max>0.6 and m==2) then c=6 end
   if (max>0.8 and m==1) then c=2 end
   if (max>0.95 and m==0) then c=2 end
  
   circ(200+10*n,62+6*m,2,c)
  end
 end
end
