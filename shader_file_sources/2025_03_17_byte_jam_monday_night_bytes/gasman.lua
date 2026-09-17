-- hello everyone!
-- since the raycasting stuff was so
-- much fun last time, let's do some
-- more of that shall we?

sin=math.sin
cos=math.cos
vp=math.tan(math.pi/4)

map={
 {1,0,1,0,1},
 {0,0,0,0,0},
 {1,0,0,0,1},
 {0,0,0,0,0},
 {1,0,1,0,1},
}

function TIC()
 t=time()

 rx=sin(t/845)*0.3
 ry=t/1234

 -- camera pos
 cx=2.5
 cy=0
 cz=2.5

 -- ahead vector
 ahx0=0
 ahy0=0
 ahz0=1
 
 ahx1=ahx0
 ahy1=ahy0*cos(rx)+ahz0*sin(rx)
 ahz1=ahz0*cos(rx)-ahy0*sin(rx)
 
 ahx=ahx1*cos(ry)+ahz1*sin(ry)
 ahy=ahy1
 ahz=ahz1*cos(ry)-ahx1*sin(ry)

 -- up vector
 upx0=0
 upy0=1
 upz0=0

 upx1=upx0
 upy1=upy0*cos(rx)+upz0*sin(rx)
 upz1=upz0*cos(rx)-upy0*sin(rx)

 upx=upx1*cos(ry)+upz1*sin(ry)
 upy=upy1
 upz=upz1*cos(ry)-upx1*sin(ry)
 
 -- right vector
 rtx0=1
 rty0=0
 rtz0=0

 rtx1=rtx0
 rty1=rty0*cos(rx)+rtz0*sin(rx)
 rtz1=rtz0*cos(rx)-rty0*sin(rx)

 rtx=rtx1*cos(ry)+rtz1*sin(ry)
 rty=rty1
 rtz=rtz1*cos(ry)-rtx1*sin(ry)

 for sy=0,135 do
  for sx=0,239 do
   -- deltas for this pixel
   dx0=(sx-119.5)*vp/120
   dy0=(sy-67.5)*vp/120
   dz0=1
   -- convert those into amounts
   -- of ahead, up and right
   dx=ahx+rtx*dx0+upx*dy0
   dy=ahy+rty*dx0+upy*dy0
   dz=ahz+rtz*dx0+upz*dy0
   
   dmin=9999999
   u=0
   v=0
   
   rayx=cx
   rayz=cz

   bail=0
   while bail<10 do
    bail=bail+0.1
    rayx=(cx+bail*dx)//1
    rayz=(cx+bail*dz)//1

    if rayx>0 and rayx<6 and rayz>0 and rayz<6 and map[rayz][rayx]==1 then
     dmin=bail
     u=1
     v=0
     break
    end
   end

   -- crossing point of y=1 plane
   d=(1-cy)/dy
   if d>0 and d<dmin then
    dmin=d
    u=d*dx+cx
    v=d*dz+cz
   end

   if dmin<9999999 then
    pix(sx,sy,(u*4//1)~(v*4//1))
   else
    pix(sx,sy,0)
   end
  end
 end
end
