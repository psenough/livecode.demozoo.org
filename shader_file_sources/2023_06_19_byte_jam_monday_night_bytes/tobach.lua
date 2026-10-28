--greetz to gasman, reality and alia!!
--hmmmm what to make this week
--well nova is THIS WEEKEND!!
abs=math.abs
sin=math.sin
cos=math.cos
function TIC()
 cls()
 t=time()//32
 fv=fft(0)+fft(1)+fft(2)+fft(3)*3
 if fv>1 then fv=1 end
 if fv<0.5 then fv=0 end
 --print(fv)
 
 rect(30,15,180,110,12)
 
 print("THE CHAIR",40+sin(t/4)*6,28,t/4,true,3)
 print("DANCING",60+sin(t/6+0.5)*16,48,t/4+2,true,3)
 print("WILL",90+sin(t/8+1)*32,68,t/4+3,true,3)
 print("RETURN",70+sin(t/4+1.5)*16,88,t/4+4,true,3)
 --print("THE CHAIR",120+sin(t/4+2)*6,28,true,0,3)

 print("NOVA 2023   23-25 JUNE   BUDLEIGH SALTERTON    YOU BETTER BE THERE !!",240-t*4%1200,3,12,true,2)
 
 for i=0,20 do
  line(i,0,i,135,i%2+1)
  line(220+i,0,220+i,135,i%2+1)
 end

 for k=0,4,2 do
  if fv>0.9+sin(k)/32 then
   person2(-70+k*38,10+sin(k+3)*8)
  else
   person1(-70+k*38,10+sin(k+3)*8)
  end
 end
 
 for i=0,8 do
  rect(0+i*28,120,24,24,15)
 end
 
 --line(0,135,0,135-fft(0)*200,12)
 
end

function chair(x,y)
 rect(x+50,y+50,3,20,1)
 rect(x+70,y+50,3,20,1)
 rect(x+56,y+50,3,17,1)
 rect(x+76,y+50,3,17,1)
 rect(x+50,y+50,28,3,1)
 rect(x+50,y+30,3,20,1)
 rect(x+65,y+30,3,20,1)
 rect(x+50,y+30,20,18,1)
end

function person1(x,y)
 chair(x+42,y+0)
 rect(x+94,y+84,20,6,14)
 rect(x+94,y+64,6,20,14)
 rect(x+110,y+84,20,6,14)
 rect(x+110,y+64,6,20,14)
 circ(x+120,y+68,10,14)
 rect(x+117,y+72,7,10,14)
 rect(x+108,y+80,25,35,14)
 rect(x+110,y+110,8,35,14)
 rect(x+123,y+110,8,35,14)
end

function person2(x,y)
 chair(x+48,y+-10)
 for i=0,6 do
  line(x+100+i,y+55,x+104+i,y+88,14)
 end
 for i=0,6 do
  line(x+120+i,y+55,x+124+i,y+88,14)
 end

 circ(x+120,y+62,10,14)
 rect(x+117,y+72,7,10,14)
 rect(x+108,y+74,25,35,14)
 rect(x+110,y+106,8,35,14)
 rect(x+123,y+106,8,35,14)
end