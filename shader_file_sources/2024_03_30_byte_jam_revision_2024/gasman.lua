function BOOT()
  poke(16320+15*3,255)
  poke(16321+15*3,255)
  poke(16322+15*3,255)

 cls(0)
 -- cls BEFORE printing stuff dammit
 print("WE",10,0,1)
 print("ARE",6,8,1)
 print("MANY",4,16,1)

 img={}
 for y=0,23 do
  img[y]={}
  for x=0,31 do
   img[y][x]=pix(x,y)
  end
 end
end

function TIC()
 for i=0,14 do
  poke(16320+i*3,i*16)
  poke(16321+i*3,i*3)
  poke(16322+i*3,i*2)
 end

 t=time()
 for sy=0,135 do
  for sx=0,239 do
   cx=sx-119.5
   cy=sy-67.5
   zx=math.abs(1/cx)*140+t/200
   zy=math.abs(1/cy)*100+t/200
   z=math.min(zx,zy)
   if zy<zx then
    -- floor/ceiling
    z=zy
    tx=(cx/z)%1
    ty=zy/4%1
   else
    -- walls
    z=zx
    tx=zx/4%1
    ty=(cy/z)%1
   end
   rota=t/1000
   tx1=tx*math.cos(rota)+ty*math.sin(rota)
   ty1=ty*math.cos(rota)-tx*math.sin(rota)
   pix(sx,sy,(tx1*16//1)~(ty1*16//1))
  end
 end
 textz=3-t/1000%4
 lines=(((t/1000+1)%4)//1)*8-1
 for y=0,lines do
  for x=0,31 do
   if img[y][x]==1 then
    circ(120+4*(x-16)/textz,68+4*(y-12)/textz,4-textz,15)
   end
  end
 end

 bz=3-(t/1000+2)%4+1
 bounce=1-math.abs(math.sin(t/134))
 for j=0,7 do
  rb=j*math.pi/8
  for i=0,7 do
   sx=math.sin(i*math.pi/4+t/1234)
   cy=math.cos(i*math.pi/4+t/1234)
   bx=32*sx*math.sin(rb)
   by=32*cy+32*bounce
   circ(120+(bx)/bz,68+(by)/bz,6-2*bz,15)
  end
 end
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>