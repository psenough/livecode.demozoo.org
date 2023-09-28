ft={}
for x=1,256 do 
 ft[x]=0
end

showFFT=false
function TIC()
	t=time()/60
 cls()

 for x=1,240 do
  ft[x]=ft[x]+(fft(x-1)-.001)*x^0.5
	 if showFFT then pix(x-1,ft[x]*100,12) end
 end
 
 bass=ft[1]+ft[2]+ft[3]
 zoom=math.sin(t/16)
 
 sizeX=60+math.sin(bass/32)*24
	sizeY=68+math.sin(bass/32)*24
    
 for x=0,(240/(sizeX*1))+1 do
  for y=0,(168/(sizeY*1))+1 do
   for z=0,32 do
				
    scaleX=(z/sizeX)*1.8*sizeX
    scaleY=(z/sizeY)*1.8*sizeX
    posX=x*sizeX+scaleX/2-sizeX+sizeX/2
    posY=y*sizeX+scaleX/2-sizeX+sizeX/2
    offsetX=(math.sin(z/16+t/8+bass/4)*(z/32)*16)--(sizeX/2)
    offsetY=(math.sin(z/16+t/8+1+bass/4))*(z/32)*16--(sizeX/2)
    
    circ(
     240-posX+(offsetX*4+(sizeX/2)*(z/8))/4,
     136-posY+(offsetY*4+(sizeX/2)*(z/8))/4,
     (sizeX-scaleX)/2+math.sin(bass/8+z)*4,
     z+bass/8+x+y
    )
   end
  end
 end
end
