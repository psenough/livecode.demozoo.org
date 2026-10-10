--hellooo, enfys here !! :3

--greetz to tina, catnip and the army of gasmen <3

sin=math.sin
cos=math.cos

for i=0,15 do
 a=0x3fc0+i*3
 poke(a,i*255/15)
 poke(a+1,i*128/15)
 poke(a+2,i*255/15)
end

pv={}
for i=1,32 do
 pv[i]={math.random()*240,math.random()*136}
end

cls()
fv=0
fvt=0
function TIC()
vbank(0)
 t=time()/100
 
 --ugly but works :)
 fv=fft(1)+fft(2)+fft(3)+fft(4)+fft(5)+fft(6)+fft(7)+fft(8)+fft(9)+fft(10)*16
 for i=0,2000 do
  pix(math.random()*240,math.random()*136,0)
 end
 for i=0,8 do
  circb(120,68,16+fv*8,i/2+fv*2-4)
 end
 for i=1,#pv do
  if t%50<25 then yt=-t*16 else yt=t*16 end
  pix4((pv[i][1]+sin(t/2+i/4)+t/5*8)%240,(pv[i][2]+yt)%136) 
  pix4((pv[i][1]+sin(t/2+i/4)+yt)%240,(pv[i][2]+sin(t/2+i/4+1)*8)%136) 

 end
vbank(1)
cls()
--print(fv)
--print(fvt,0,16)

end
function pxadd(x,y)
 if (x>0 and x<239) and (y>0 and y<135) then
 v=peek4((y//1)*240+(x//1))
 v=v+fv
 if v>15 then v=15 end
 poke4((y//1)*240+(x//1),v)
 end
end

function pix4(x,y)
 pxadd(x,y)
 pxadd(x+1,y)
 pxadd(x,y+1)
 pxadd(x+1,y+1)
end