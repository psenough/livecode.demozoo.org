-- greetings people!
-- shoutouts to jtruk, weatherman115,
-- g33kou, littletheremin, catnip,
-- zool, suule, polynomial, reality404
-- AND YOU!!!!!!!

-- tonight I am going to confront my
-- deepest fears and attempt some
-- raycasting. raymarching? whatever

cos=math.cos
sin=math.sin
vp=math.tan(math.pi/4)

function TIC()
 ts=time()

 hr=0.5+0.5*sin(ts/1345)
 hg=0.5+0.5*sin(ts/1345+math.pi/3)
 hb=0.5+0.5*sin(ts/1345+2*math.pi/3)

 for i=0,15 do
  poke(16320+i*3,hr*i*17)
  poke(16321+i*3,hg*i*17)
  poke(16322+i*3,hb*i*17)
 end

 ry=ts/5234
 rz=ts/2345
 rx=ts/5567
 for sy=0,135 do
  for sx=0,239 do
   dx0=(sx-120)*vp/120
   dy0=(sy-68)*vp/68
   dz0=1
   dx1=dx0*cos(ry)+dz0*sin(ry)
   dy1=dy0
   dz1=dz0*cos(ry)-dx0*sin(ry)
   dx2=dx1*cos(rz)+dy1*sin(rz)
   dy2=dy1*cos(rz)-dx1*sin(rz)
   dz2=dz1
   dx=dx2
   dy=dy2*cos(rx)+dz2*sin(rx)
   dz=dz2*cos(rx)-dy2*sin(rx)
   
   ox=0.8*math.sin(ts/2444)
   oy=0.8*math.sin(ts/3444)
   oz=0.8*math.sin(ts/1444)

   tmin=9999999
   tx=0
   ty=0

   if dy>0.00001 or dy<-0.00001 then
    -- find crossing point of y=.5 plane
    --t=(.3-oy)/dy
    --if t>0 and t<tmin then
    -- tx0=t*dx
    -- ty0=t*dz
    -- if tx0>-0.3 and tx0<0.3 and ty0>-0.3 and ty0<0.3 then
    --  tx=0.5
    --  ty=0.5
    --  tmin=t
    -- end
    --end

    -- find crossing point of y=1 plane
    t=(1-oy)/dy
    if t>0 and t<tmin then
     tmin=t
     tx=t*dx+ox
     ty=t*dz+oz
    end

    -- find crossing point of y=-1 plane
    t=(-1-oy)/dy
    if t>0 and t<tmin then
     tmin=t
     tx=t*dx+ox
     ty=t*dz+oz
    end
   end

   if dx>0.00001 or dx<-0.00001 then
    -- find crossing point of x=1 plane
    t=(1-ox)/dx
    if t>0 and t<tmin then
     tmin=t
     tx=t*dy+oy
     ty=t*dz+oz
    end

    -- find crossing point of x=-1 plane
    t=(-1-ox)/dx
    if t>0 and t<tmin then
     tmin=t
     tx=t*dy+oy
     ty=t*dz+oz
    end
   end

   if dz>0.00001 or dz<-0.00001 then
    -- find crossing point of z=1 plane
    t=(1-oz)/dz
    if t>0 and t<tmin then
     tmin=t
     tx=t*dx+ox
     ty=t*dy+oy
    end

    -- find crossing point of z=-1 plane
    t=(-1-oz)/dz
    if t>0 and t<tmin then
     tmin=t
     tx=t*dx+ox
     ty=t*dy+oy
    end
   end

   tx1=tx*16
   ty1=ty*16
   if tx1%2<.2 or ty1%2<.2 then
    pix(sx,sy,0)
   else
    tx=16-(math.abs(tx))*16
    ty=16-(math.abs(ty))*16
    tf=tx//2+ty//2+ts/100
    pix(sx,sy,tf)
   end
  end
 end
end
