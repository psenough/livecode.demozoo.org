--         ^ 
--hello!! tobach here!!
--time for another jam :-)

--greetz to violet, nico, alia, mantra
--and molive who i'm sat in vc with
--swearing at my monitor :-)

flr=math.floor
sin=math.sin
cos=math.cos
abs=math.abs

imgbuf={}
for i=1,128 do
 imgbuf[i]={}
 for j=1,128 do
  imgbuf[i][j]=0
 end
end

function SCN(scnln)
 poke(0x3ff9,sin(scnln/16+t)*16)
end

function TIC()
 cls()
 t=time()/100
 twister()
 for y=1,128 do
  for x=1,128 do
   imgbuf[x][y]=peek4(y*240+x)
   --pix(120+x,4+y,imgbuf[x][y])
  end
 end
 --angle=sin(t/128)*8
 angle=t/16
 for y=0,135 do
  for x=0,239 do
   u=flr(x*cos(angle)-y*sin(angle))
   v=flr(x*sin(angle)+y*cos(angle))
   u=u*2
   v=v+y
   pix(x,y,imgbuf[u%127+1][v%127+1])
  end
 end
end

--i have no clue what i'm doing
--but i'm rolling with it lmao

--also my maths is wrong somewhere
--and idk where...

function twister()
 amp=16+sin(t/4)+(fft(0)+fft(1)*64)
 for y=0,135 do
   line(0,y+1,128,y+1,(y/16+t/4+sin(y/4+t/3)+10))
 end
 for y=0,135 do
  a=sin(y/amp+t/2)*cos(y/32+t/32)*40+60
  b=sin(y/amp+90+t/2)*cos(y/32+t/32)*40+60
  c=sin(y/amp+180+t/2)*sin(y/32+t/32)*40+60
  if a<b then line(a,y,b,y,8) end
  if b<c then line(b,y,c,y,9) end
  if c<a then line(c,y,a,y,10) end
 end
end