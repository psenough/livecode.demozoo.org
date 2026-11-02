-- hello from gasman!!!
-- I haven't done raytracing for a
-- while, so let's see if I still
-- remember how it works...

sin=math.sin
cos=math.cos

maxvol=0

dither={
 {0/16,14/16,2/16,13/16},
 {10/16,6/16,9/16,5/16},
 {3/16,15/16,1/16,12/16},
 {11/16,7/16,8/16,4/16}
}

function TIC()
 for i=0,7 do
  poke(16320+i*3,(i&1)*255)
  poke(16321+i*3,(i&2)/2*192)
  poke(16322+i*3,(i&4)/4*224)
 end

 t=time()

 -- ray origin
 cx=10*sin(t/1234)
 cy=10*sin(t/2345)
 cz=(t/3456)%100
 
 dnx0=0
 dny0=1
 dnz0=0
 
 fwdx0=0
 fwdy0=0
 fwdz0=1
 
 rtx0=1
 rty0=0
 rtz0=0
 
 xrot=t/1357
 
 dnx1=dnx0
 dny1=dny0*cos(xrot)+dnz0*sin(xrot)
 dnz1=dnz0*cos(xrot)-dny0*sin(xrot)
 
 fwdx1=fwdx0
 fwdy1=fwdy0*cos(xrot)+fwdz0*sin(xrot)
 fwdz1=fwdz0*cos(xrot)-fwdy0*sin(xrot)
 
 rtx1=rtx0
 rty1=rty0*cos(xrot)+rtz0*sin(xrot)
 rtz1=rtz0*cos(xrot)-rty0*sin(xrot)
 
 yrot=t/1470
 
 dnx=dnx1*cos(yrot)+dnz1*sin(yrot)
 dny=dny1
 dnz=dnz1*cos(yrot)-dnx1*sin(yrot)
 
 fwdx=fwdx1*cos(yrot)+fwdz1*sin(yrot)
 fwdy=fwdy1
 fwdz=fwdz1*cos(yrot)-fwdx1*sin(yrot)
 
 rtx=rtx1*cos(yrot)+rtz1*sin(yrot)
 rty=rty1
 rtz=rtz1*cos(yrot)-rtx1*sin(yrot)

 r=4+math.sin(t/2323)+(fft(0)+fft(1))*4

 for sy=0,135 do
  for sx=0,239 do
   -- ray direction
   x=(sx-119.5)/120
   y=(sy-67.5)/120
   z=1
   vx=x*rtx+y*dnx+z*fwdx
   vy=x*rty+y*dny+z*fwdy
   vz=x*rtz+y*dnz+z*fwdz
   -- equation of ray is
   -- x=cx+t*vx and ditto for y,z
   -- Find the positive t at which
   -- y=0
   -- (0-cy)/vy=t
   
   -- OK, while you were all distracted
   -- I was working out the formula
   -- for raytracing a cylinder.
   -- I need to solve the quadratic eqn
   -- at^2+bt+c=0
   -- where
   a=vx^2+vy^2
   b=2*vx*cx+2*vy*cy
   c=cx^2+cy^2-r^2
   
   coeff=math.abs(b^2-4*a*c)
   hit=1
   if coeff<0 then
    hit=0
   else
    t1=(-b+math.sqrt(coeff))/2*a
    t2=(-b-math.sqrt(coeff))/2*a
    if t1>0 and t2>0 then
     tf=math.min(t1,t2)
    elseif t1>0 then
     tf=t1
    elseif t2>0 then
     tf=t2
    else
     tf=-math.min(t1,t2)
    end
   end
   
   -- okay, that's not a cylinder
   -- but I think I'm gonna roll
   -- with it anyway
     
   if hit==0 then
    pix(sx,sy,0)
   else
    hx=(sin(cx+tf*vx)+1)/2
    hz=(sin(cz+tf*vz)+1)/2
    hy=(sin(cy+tf*vy)+1)/2
    val=0
    if ((x*x+y*y)+t/5345)%.2>.1 then
     dv=dither[(sx&3)+1][(sy&3)+1]
     dvx=dv
     dvy=dv
     dvz=dv
    else
     dvx=math.random()
     dvy=math.random()
     dvz=math.random()
    end
    if hx>dvx then
     val=val+1
    end
    if hy>dvy then
     val=val+2
    end
    if hz>dvz then
     val=val+4
    end

    pix(sx,sy,val)
   end
  end
 end
end
