--greetz to alia,
--synackster and doop <3

fruits={}
fruits2={}

text="EAT UR FRUIT!!!"

for i=1,8 do
 fruits[i]={math.random()*256,math.random()*300,math.random()*10}
end

for i=1,4 do
 fruits2[i]={math.random()*256,math.random()*300}
end

tv=true
tx=0

sin=math.sin
cos=math.cos
abs=math.abs
function TIC()
 t=time()//32
 cls(10)

 fval=fft(0)+fft(1)+fft(2)*512
 for k=0,1 do
  for j=0,8 do
   for i=0,6 do
    circ(i*64+k*32+2+sin(t/16)*16,2+j*64+k*32+cos(t/16)*16,8+fval/32,9)
    circ(i*64+k*32+sin(t/16)*16,0+j*64+k*32+cos(t/16)*16,8+fval/32,11)
   end
  end
 end
 
 --hmmmm what else to add....
 --i know! >:)
 for i=1,#fruits2 do
  pinapple(-30+(fruits2[i][1]+sin(t/16+i)*16+t*(2+i/2))%280,-40+(fruits2[i][2]+t*3)%300)
 end
 
 for i=1,#fruits do
  banana(fruits[i][1]+sin(t/16+i)*32,-40+(fruits[i][2]+t)%300,fruits[i][3])
 end

 if tx>=100 then tv=false
 elseif tx<=-100 then tv=true
 end
 if tv==false then tx=tx-1
 elseif tv==true then tx=tx+1 end
 tomato(120+tx,118-abs(sin(t/8))*32)
 
 sintext(text,23,6,3)
 sintext("ONE OF UR 5 A DAY",5,102,2)
 sintext("INNIT",80,120,2)
 
end

function banana(x,y,offset)
 t2=sin(t/8)+5
 for i=0,40 do
  circ(x+sin(i/16+t2+offset)*32,y+cos(i/16+t2+offset)*32,sin(i/12)*6+3,3)
 end
 for i=0,40 do
  circ(x+sin(i/16+t2+offset)*32,y+cos(i/16+t2+offset)*32,sin(i/12)*6+2,4)
 end
 circ(x+sin(t2+2.5+offset)*32,y+cos(t2+2.5+offset)*32,4,1)
end

function tomato(x,y) -- ;)
 elli(x,y,21,19,1)
 elli(x,y,20,18,2)
 tri(x,y-20,x,y+10-20,x+10,y-20,7)
end

function pinapple(x,y)

 for i=0,4 do
  tri(x-20+i,(y-20)-i*5,x,(y-20)+10-i*5,x+20-i,(y-20)-i*5,6)
  trib(x-20+i,(y-20)-i*5,x,(y-20)+10-i*5,x+20-i,(y-20)-i*5,7)
 end
 
 elli(x,y,20,30,1)
 elli(x,y,18,28,4)
 
end

function sintext(text,x,y,amp)
 for i=1,#text do
  c=text:sub(i,i)
  for j=0,2 do
   print(c,x+i*12+j,y+amp*sin((t*32+i*64)/90)+j,14-j+t/4,true,2)
  end
 end
end