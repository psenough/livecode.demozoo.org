function TIC()
 cls()
 for px=1,240 do
  for py=1,136 do
   line(px,py,px,py,4+px/16+math.sin(time()/200)*4)
  end
 end
 for ly=1,8 do
  for lx=1,8 do
   line(0,68+lx+math.sin(time()/200+ly/4)*50,240,68+lx+math.sin(time()/200+ly/4)*50,lx+8)
  end
 end
 for i=1,68 do
  for j=1,16 do
   line(120+j+math.sin(time()/300+i/8)*math.sin(time()/400+i/16)*60,0+i*2,120+j+math.sin(time()/300+i/8)*math.sin(time()/400+i/16)*60,136,j/2)
  end
 end
 for tc=1,4 do
  print("COME TO FIELD-FX!!!",240-time()/3%1200+tc*2,50+tc*2+math.sin(time()/100)*10,8+tc,true,8)
 end
end