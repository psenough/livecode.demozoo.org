sin=math.sin
cos=math.cos

function BDR(y)
 m0=(y-68)/72
 m1=1-(m0*m0*m0*m0)
 
 if y&1==0 then
  for i=0,7 do
   poke(16320+i*3,i*31/3*m1)
   poke(16321+i*3,i*31/3*m1)
   poke(16322+i*3,i*31/3*m1)
   poke(16344+i*3,0)
   poke(16345+i*3,i*31*m1)
   poke(16346+i*3,0)
  end
 else
  for i=0,7 do
   poke(16320+i*3,i*31*m1)
   poke(16321+i*3,0)
   poke(16322+i*3,0)
   poke(16344+i*3,0)
   poke(16345+i*3,0)
   poke(16346+i*3,i*31*m1)
  end
 end
end

function TIC()
 tg1=time()/834
 tg2=time()/245
 tr1=time()/838
 tr2=time()/249
 tb1=time()/842
 tb2=time()/253

 ro=time()/2345
 dx=time()/1357
 dy=time()/2468

 ft1=time()/1355
 ft2=time()/1466
 ft3=time()/1365
 ft4=time()/1476

 for sy=0,137 do
  for sx=0,239 do
   y0=sy-67.5
   x0=sx-119.5

   ro1=ro+cos(sy/120)+cos(sx/120)
   y1=y0+60*sin(dy)
   x1=x0+60*sin(dx)
   y2=((y1*cos(ro1)+x1*sin(ro1))*2)%240-120
   x2=((x1*cos(ro1)-y1*sin(ro1))*2)%240-120

   a=math.atan2(x2,y2)
   r=math.sqrt(y2*y2+x2*x2)
   sg1=sin(a*3+tg1)
   sg2=sin(a*5+tg2)
   gv=math.abs((1024/r)*(sg1+sg2)/4)
   sr1=sin(a*3+tr1)
   sr2=sin(a*5+tr2)
   rv=math.abs((1024/r)*(sr1+sr2)/4)
   sb1=sin(a*3+tb1)
   sb2=sin(a*5+tb2)
   bv=math.abs((1024/r)*(sb1+sb2)/4)
   wv=rv+gv+bv/3
   
--   f1=(
--   	sin(ft1+sx/32)+sin(ft3+sx/36)
--   )+(sin(ft2+sy/32)+sin(ft4+sy/36))
--   f1=f1%2
--   f2=(
--   	sin(ft1-sx/40)+sin(ft3-sx/44)
--   )+(sin(ft2-sy/40)+sin(ft4-sy/44))
--   f2=f2%2

   fa=math.atan2(x0,y0)
   fr=(x0*x0+y0*y0)/25
   f1=((fa+fr/16+ft1)/math.pi*8//1)%4
   f2=((fa+fr/16+ft2)/math.pi*8//1)%4
   f3=((fa+fr/16+ft3)/math.pi*8//1)%4
   f4=((fa+fr/16+ft4)/math.pi*8//1)%4

   if sy&1==0 then
    -- green/white
    if sx&1==0 then
     if gv<4 then
      pix(sx,sy,f1+8)
     else
      pix(sx,sy,((gv//1)&7)+8)
     end
    else
     if wv<4 then
      pix(sx,sy,f2)
     else
      pix(sx,sy,((wv//1)&7))
     end
    end
   else
    -- red/blue
    if sx&1==0 then
     if rv<4 then
      pix(sx,sy,f3)
     else
      pix(sx,sy,((rv//1)&7))
     end
    else
     if bv<4 then
      pix(sx,sy,f4+8)
     else
      pix(sx,sy,((bv//1)&7)+8)
     end
    end
   end
  end
 end
end
