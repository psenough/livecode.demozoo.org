--               ^
--hello stream, tobach here! :))
--really hoping this becomes a regular
--thing it is awesome
sin=math.sin
cos=math.cos
rnd=math.random
function TIC()
 t=time()//32
 
 cls(15)

 rndval=rnd(20)

 t2=t%200
 
 if (t2>=5 and t2<=10) then
  cls(12+t/4%3)
  for i=0,2 do
   line(20+rndval+i,0,0+rndval*5,60,12-i-t%3)
   line(0+rndval*5+i,60,40+rndval,120,12-i-t%3)
  end
 elseif t2>=150 and t2<=155 then
  cls(12+t/4%3)
  for i=0,2 do
   line(170+rndval+i,0,150+rndval*5,60,12-i-t%3)
   line(150+rndval*5+i,60,190+rndval,120,12-i-t%3)
  end
 end

 for i=0,239 do
  sval=sin(i/32+t/20)*sin(i/16+t/10)*4
  line(i,20+sval,i,0,12)
 end
 
 for i=0,239 do
  sval=sin(i/32+t/20)*sin(i/24+t/10)*4
  line(i,100-sval,i,136,8)
 end
 
 tri(95,100+cos(t/8)*4+sin(t/16)*4,110,110,130,100-cos(t/8)*4+sin(t/16)*4,13)
 trib(95,100+cos(t/8)*4+sin(t/16)*4,110,110,130,100-cos(t/8)*4+sin(t/16)*4,14)
 for i=0,2 do
  line(110+i-cos(t/8)*4+sin(t/16)*4,80+sin(t/16)*4,110+i,100+sin(t/16)*4,15-i)
 end
 --bloody sail maths!!!!! >:(
 --tri(115-cos(t/8)*4+sin(t/16)*4,85+cos(t/8)*4+sin(t/16)*4,115,95,130,85,12)
 
 --its really starting to look
 --like a mess now isn't it...
 --:)
 
 for i=0,160 do
  px=(t+sin(t/5)+i*sin(t/20+i)-t*8)%240
  py=(t*4+i*20)%136
  pix(px,py,10)
 end
 
 for i=0,239 do
  sval=sin(i/32+t/16)*sin(i/24+t/8)*6
  line(i,105-sval,i,136,9)
 end

 for i=0,239 do
  sval=sin(i/32+t/16)*sin(i/12+t/4)*6
  line(i,10+sval,i,0,13)
 end
 
 for i=0,239 do
  sval=sin(i/32+t/12)*cos(i/24+t/6)*8
  line(i,115-sval,i,136,10)
 end
 
 --its pissin it down!!!

 for i=0,160 do
  px2=(t+sin(t/8)+i*sin(t/30+i)-t*4)%240
  py2=(t*5+i*15)%136
  pix(px2,py2,11)
 end
 
 
end
