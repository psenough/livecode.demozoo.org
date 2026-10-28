goodbye="thanks for the amazing party"
function TIC()
 cls()
 --vbank(0)
 t=time()/100
 for i=0,240,2 do
   sv=math.sin(i/16+t/5)*math.sin(i/13*t/16)*4
  line(i,0,i,135,sv)
 end
 for i=0,2 do
  print("bye bye\ndeadline",60+i,30+i+math.sin(t/4)*8,14-i,false,3)
 end
 for j=0,1  do
  for i=1,#goodbye do
   print(string.sub(goodbye,i,i),30+i*6,100+math.sin(i/8+t)*8-j,13-j,true)
  end
 end
 print("- enfys <3",100,120,12)
end