txts="Deadline 2024"
function TIC()
 t=time()/100
 cls()

 for i=0,136,2 do
  sv=math.sin(i/8+t/2)*math.sin(i/7+t-3)*4
  line(0,i,240,i,sv)
  line(0,i+1,240,i+1,-sv)
 end

 for i=1,#txts do
  for j=0,2 do
   print(string.sub(txts,i,i),-20+i*20+j*2+math.sin(t/4)*32,58+math.sin(i/4+t/4)*(16+math.sin(t/8)*32)+j*2,14-j,true,2+i/8+t/4%2)
  end
 end
end