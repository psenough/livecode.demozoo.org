--hello inercia!!
--greetz to gasman, superogue, dave84
--and nico and violet <3
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
--this sucks, i have a better idea >:)
sin=math.sin
cos=math.cos

function TIC()t=time()//32

 rect(0,0,240,80,0)
 for i=0,4 do
  rect(0,76+i*2,240,136/4,i)
 end
  
 --nico is now in!!! helloooo :))
 --starfield didn't work /o\
 
 rect(0,100,240,80,15)
 
  --road back is here
 building1(240-t*2.1%350,20,120,13)
 building1(300-t*2.2%450,30,120,14)
 building2(400-t*2.3%500,50,120,15)
 building1(450-t*2.4%580,30,120,13)
 building1(500-t*2.5%680,60,120,14)
 
 for i=0,8 do
  rect(20+2+i*64-t*4%190,100,20,60,13)
  rect(20+i*64-t*4%190,100,20,60,14)
 end
 

 rect(0,86,240,4,13)
 rect(0,90,240,20,15)

 --nice road hey ;)
 for i=0,8 do
  rect(0+i*64-t*4%190,100,40,2,12)
 end
 
 --god how do you draw a car again??!1


 car(0,0+sin(t/7)*2,0,6)
 car(40,0+sin(t/12)*2,0.4,7)
 car(80,0+sin(t/5)*2,0.2,3)
 
 car2(-80,0,0,0)
 
 rect(0,104,240,8,13) --road front 
 
 building2(350-t*6%650,60,120,13)
 building2(240-t*6.2%600,80,120,14)
 
 --i have had an idea but idk if it
 --will work out wel, ah well why not!
 
 --was deffo a "looked better in my head"
 --ones lol...
 
end

--lets get some "scenery in here" ;)
function building1(x,y,h,col)
 rect(x,y,40,h,col)
 for j=0,16 do
  for i=0,4 do
   rect(x+2+i*8,y+2+j*8,4,4,4)
  end
 end
end

function building2(x,y,h,col)
 rect(x,y,80,h,col)
 for j=0,16 do
  for i=0,8 do
   rect(x+2+i*9,y+2+j*8,4,4,4)
  end
 end
end

function car(x,y,offset,col)
 carx=sin(t/16+offset)*sin(t/32+offset)*8
 rect(x+107+carx,88+y,26,8,col)
 rect(x+112+carx,84+y,15,6,11)
 rect(x+112+carx,84+y,15,2,col)
 circ(x+113+carx,95+y,3,14)
 circ(x+126+carx,95+y,3,14)
end

function car2(x,y,offset,col)
 carx=sin(t/16+offset)*sin(t/32+offset)*8
 rect(x+107+carx*2,88+y,26,8,col)
 rect(x+112+carx*2,84+y,15,6,11)
 rect(x+112+carx*2,84+y,15,2,col)
 circ(x+113+carx*2,95+y,3,14)
 circ(x+126+carx*2,95+y,3,14)
 rect(x+116+carx*2,82+y,3,3,lightcols[t/4%3])
 rect(x+119+carx*2,82+y,3,3,lightcols[t/4%3+1])
end

lightcols={2,10,2,10}