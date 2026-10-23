-- hello from gasman!!!
-- greetings to weatherman115,
-- reality404, and jammers everywhere!

-- tonight:
-- the attempts at raycasting will
-- continue until morale improves

sin=math.sin
cos=math.cos
fov=math.pi/4

maxsteps=20

for i=0,15 do
 poke(16320+i*3,i*4)
 poke(16321+i*3,i*12)
 poke(16322+i*3,i*17)
end

function TIC()
 rotax=time()/1234/2
 rotay=time()/1345/4
 
 cpx=sin(time()/468)*0.8
 cpy=sin(time()/579)*0.8
 cpz=time()/500

 for sy=0,135 do
  y=(sy-67.5)/120
  for sx=0,239 do
   x=(sx-119.5)/120
   
   cx0=x
   cy0=y
   cz0=1
   
   cx1=cx0
   cy1=cy0*cos(rotax)+cz0*sin(rotax)
   cz1=cz0*cos(rotax)-cy0*sin(rotax)
   
   cx=cx1*cos(rotay)+cz1*sin(rotay)
   cy=cy1
   cz=cz1*cos(rotay)-cx1*sin(rotay)

   -- camera vector = (x,y,1)
   -- let's see when it hits
   -- x=-1 or x=1
   if cx>0 then
    -- will hit positive x
    wallx=1
    wallstepx=2
   else
    wallx=-1
    wallstepx=-2
   end

   -- same, but y=-1 or y=1
   if cy>0 then
    wally=1
    wallstepy=1
   else
    wally=-1
    wallstepy=-1
   end

   steps=0
   while steps<maxsteps do
    steps=steps+1
    if steps==maxsteps then
     pix(sx,sy,0)
     break
    end

    dtox=(wallx-cpx)/cx
    dtoy=(wally-cpy)/cy
    if dtox<dtoy then
     d=dtox
     dx=wallx
     dy=d*cy+cpy
     dz=d*cz+cpz

     if dz-cpz>20 then
      pix(sx,sy,0)
      break
     end

     if (dy//1)%2==0 and (dz//1)%2==0 then
      ty=(dy%1)*16//1
      tz=(dz%1)*16//1
      pix(sx,sy,ty~tz)
      break
     else
      wallx=wallx+wallstepx
     end

    else
     d=dtoy
     dx=d*cx+cpx
     dy=wally
     dz=d*cz+cpz

     if dz-cpz>20 then
      pix(sx,sy,0)
      break
     end

     if dx>0 then
      wallyhit=(dz//1)%2==0 and (dx//1)%2==1
     else
      wallyhit=(dz//1)%2==0 and (dx//1)%2==0
     end

     if wallyhit then
      tz=(dz%1)*16//1
      tx=(dx%1)*16//1
      pix(sx,sy,tx~tz)
      break
     else
      wally=wally+wallstepy
     end

    end

   end
  end
 end
end
