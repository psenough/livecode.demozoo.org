--hello you lot!!!!
--massive greetz to mantra, superogue and nico <3
--we have new commands to play with :)

--shall we do a festive diorama?? :)
--im thinking xmas rave...

sin=math.sin
cos=math.cos
function TIC()
 cls(9)
 t=time()/100

 bassval=fft(0)+fft(1)*50
 
 mountains()
 
 tree()
 elli(120,180,240,80,12)
 ellib(120,180,240,80,13)
 --print(bassval)
 
 snow()
 
 for i=0,4 do
  snowman(20+i*45,75-math.abs(sin(bassval/8+i/2)*4))
 end
 --waiting for bass lol
 
end

function mountains()
 for i=-2,8 do
  tri(5+i*32-4,110,40+i*32,50-sin(i*9)*16-4,75+i*32,110-4,12)
  tri(0+i*32,110,40+i*32,50-sin(i*9)*16,80+i*32,110,14)
  trib(0+i*32,110,40+i*32,50-sin(i*9)*16,80+i*32,110,13)
 end
end

function tree()
 rect(100,60,40,50,1)
 for i=0,9 do
  tri(110-i*8,20+i*8,120,5+i*8,130+i*8,20+i*8,6)
 end
 print("*",116,0,4+sin(bassval)*2,true,2)
 for i=0,164 do
  circ(120+sin(i/4)*i/2,10+i/2,2,i%4+t+i/2*bassval/128)
 end
end

function snowman(x,y)
 for i=0,2 do
  circ(x+10,y+10+i*15,8+i,12)
  circb(x+10,y+10+i*15,8+i,13)
  for i=0,1 do
   --circ(x+7+i*6,y+7,1,15)
   rect(x+5+i*6,y+6,5,3,15)
   line(x+4+i*6,y+6,x+10+i*6,y+6,15)
  end
 end
 
 --i have forgotten how to maths
 line(x+5,y+20,x-5-sin(bassval)*4,y+20+cos(bassval)*4,1)
 line(x+15,y+20,x+25+sin(bassval)*4,y+20+cos(bassval)*4,1)
 
 line(x+10,y+10,x+13,y+12,3)
 
end

function snow()
 for i=0,239 do
  sn1=(time()/20+sin(time()/500)+i*sin(time()/2000+i))%240
  sn2=(time()/20+i*20)%136
  pix(sn1,sn2,12)
 end
end