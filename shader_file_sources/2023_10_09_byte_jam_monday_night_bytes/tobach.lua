tarr={}
for i=1,60 do
 tarr[i]={}
end
sr={" ", ",", ".", ":", ";", "O", "3", "#", "#", "#", "#", "#", "#"}
sin=math.sin
cos=math.cos
abs=math.abs
function TIC()
 t=time()//32
 cls()
 for y=1,21 do
  for x=1,60 do
   pv=sin(x/8+t/7+sin(y/7+t/13)+sin(x/32+t/32)*8)*8+8
   pix(x,y,pv-8)
   for i=0,8 do
--    line(30+sin(t/8+i/32)*30,11+cos(t/8+i/32)*11,30-sin(t/8+i/32)*30,11-cos(t/8+i/32)*11,15-i)
   by=abs(sin(t/8+i/4))*14
   bx=sin(t/16+i/4)*24
   circ(31+bx,20-by,3,i/2+8+t/8-2)
   circ(30+bx,19-by,3,i/2+8+t/8)
   end
   print("MONDAY NIGHT BYTES",61-t*2%300,6,0,true,2)
   print("MONDAY NIGHT BYTES",60-t*2%300,6,12,true,2)
   --yes there are still "nil"'s 
   -- being shown on screen
   --i do not care anymore :)
   
   tarr[x][y]=peek4(y*240+x)
  end
 end
 cls()
 for y=1,21 do
  for x=1,60 do
   ft=tarr[x][y]//1
   print(sr[ft+1],x*4,y*6,ft,true,1,true)
  end
 end
end
