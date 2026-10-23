--ey up!!
-- ^
--tobach here!! greetz to vurpo henearxn
--and ofc the lovely aldroid :)

--hmmmm, what to make this evening...
--i woke up about an hour ago so i
--hope this goes well lol

rain={}

for i=1,100 do
 rain[i]={math.random()*240,math.random()*136}
end

sin=math.sin
cos=math.cos
function TIC()
 fv=fft(0)+fft(1)+fft(2)+fft(3)+fft(4)+fft(5)*8

 cls(9+fv/3)
 t=time()//32

 --print(fv)

 if fv>2.5 then
  for j=0,1 do
  for i=0,3 do
   rv=math.random()*32
   line(40+j*120,0,20+rv+j*200,40+rv,12-i)
   line(80+j*120,90,20+rv+j*200,40+rv,12-i)
  end
  end
 end


 for i=-8,8 do
  circ(i*32+t%32,0,30,15)
 end

 for i=-8,8 do
  circ(i*32+t*2%32,0,20,14)
 end

 for i=-8,8 do
  circ(i*32+t%32,120,50,5)
 end

 for i=-8,8 do
  circ(i*32+t*2%32,210,80,6)
 end

 for j=0,2 do
  for i=1,100 do
   pix((rain[i][1]+t*8+j)%240,(rain[i][2]+t*4+j)%136,9+j)
  end
 end

 for i=-8,16 do
  circ(i*16+t*3%32,0,10,13)
 end


 snail(10+sin(t/4+fv/4)*8,0)
 
 --print(fv/2)

end

function shell(x,y)
 for i=0,90 do
  circ(120+sin(i/8)*(i)/4+2+x,68+cos(i/8)*(i)/4+2+y,3+i/8,3)
 end
 for i=0,90 do
  circ(120+sin(i/8)*(i)/4+x,68+cos(i/8)*(i)/4+y,3+i/8,4)
 end
 for i=0,94 do
  circ(120+sin(i/8)*(i)/4+x,68+cos(i/8)*(i)/4+y,1,15)
 end
end

function snail(x,y)
 for i=4,47 do 
  line(0,78+i,240,78+i,sin(i/16)*4)
 end
 
 for i=0,24 do
  circ(65+i*4+x,88+sin(i/2+t/4+fv)*2,8,6)
 end

 shell(8+x,0+sin(t/4+fv)*2)
 
 for i=0,8 do
  circ(80+sin(i/2+t/4+2+fv)*2+x,80-i*3+sin(t/4),3,7)
  circ(64+sin(i/2+t/4+fv)*2+x,80-i*3+sin(t/4),3,7)
 end
 
 circ(80+sin(t/4+fv)*2+x,54,6,12)
 circ(64+sin(t/4+2+fv)*2+x,54,6,12)

 circ(78+sin(t/4+fv)*2+x,54,2,15)
 circ(62+sin(t/4+2+fv)*2+x,54,2,15)

end