--pallete stuffz
for i=0,15 do
 a=0x3fc0+(i*3)
 poke(a,i*16)
 poke(a+1,i*8)
 poke(a+2,i*16)
end

sin=math.sin
cos=math.cos
cls(0)
function TIC()
 cls(0)
 vbank(0)
 t=time()/50
 ct=t*8
 ct=ct%500
 for j=0,135,2 do
  for i=0,240,2 do
   pix(i,j,sin(j/16+t/8+sin(i/24+t/7+sin(j/7+t/5)))*2+2)
  end
 end
 amt=20
 for i=0,135 do
  --how????
  --isn't it radians??!?!?!!?!
  --ffs !!!!
  sv=30+(sin(t/4+i/32)*20)
  x=sin(i/amt+t/7)*sv+120
  y=sin(i/amt+90+t/7)*sv+120
  z=sin(i/amt+180+t/7)*sv+120
  tv=sin(t/8+i/32+sin(i/27+t/17))*32
  if x<y then line(x+tv,i,y+tv,i,sin(x/8+t/4)*4+4) end
  if y<z then line(y+tv,i,z+tv,i,sin(y/12+t/4)*4+4) end
  if z<x then line(z+tv,i,x+tv,i,sin(z/16+t/4)*4+4) end
 end

end

function SCN(scnln)
 --poke(0x3ff9,sin(t+scnln/8)*4)
end