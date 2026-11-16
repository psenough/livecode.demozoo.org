-- hello from gasman
-- live from Edinburgh Hacklab!

-- tonight I'm going to have another go
-- at the tunnel I couldn't get working
-- two jams ago

-- I have an idea for a different
-- approach, so hopefully it will at
-- least go wrong in a *different*
-- interesting way...

sin=math.sin
cos=math.cos

for i=0,14 do
 poke(16320+i*3,i*9)
 poke(16321+i*3,0)
 poke(16322+i*3,i*17)
end

function TIC()
 fft0=fft(0)*15
 fft1=fft(1)*15
 t=time()
 dnx0=0
 dny0=1
 dnz0=0
 rtx0=1
 rty0=0
 rtz0=0
 fwdx0=0
 fwdy0=0
 fwdz0=1
 
 ry=t/2234
 rx=.1+sin(t/1523)/2
 rq=t/5424
 
 dnx1=dnx0
 dny1=dny0*cos(rx)+dnz0*sin(rx)
 dnz1=dnz0*cos(rx)-dny0*sin(rx)
 dnx=dnx1*cos(ry)+dnz1*sin(ry)
 dny=dny1
 dnz=dnz1*cos(ry)-dnx1*sin(ry)
 
 rtx1=rtx0
 rty1=rty0*cos(rx)+rtz0*sin(rx)
 rtz1=rtz0*cos(rx)-rty0*sin(rx)
 rtx=rtx1*cos(ry)+rtz1*sin(ry)
 rty=rty1
 rtz=rtz1*cos(ry)-rtx1*sin(ry)
 
 fwdx1=fwdx0
 fwdy1=fwdy0*cos(rx)+fwdz0*sin(rx)
 fwdz1=fwdz0*cos(rx)-fwdx0*sin(ry)
 fwdx=fwdx1*cos(ry)+fwdz1*sin(ry)
 fwdy=fwdy1
 fwdz=fwdz1*cos(ry)-fwdx1*sin(ry)

 for sy=0,135 do
  for sx=0,239 do
   x=(sx-119.5)/120
   y=(sy-67.5)/120
   
   vx=x*rtx+y*dnx+fwdx
   vy=x*rty+y*dny+fwdy
   vz=x*rtz+y*dnz+fwdz

   ang=math.atan2(vx,vy)*16/math.pi
   
   -- distance from origin will
   -- increase by this for each
   -- +1 in k
   rad=math.sqrt(vx*vx+vy*vy)
   -- intersection with rad=1
   k=.5/rad
   z=k*vz*4+t/400
   
   if k>0 and k<20 then
    q1=ang*cos(rq)+z*sin(rq)
    q2=z*cos(rq)-ang*sin(rq)
    if (q1-q2)%1>.9 or (q1+q2)%1>.9 then
     pix(sx,sy,15)
    else
     k2=4/rad
     z2=k2*vz*4+t/20
     if k2>0 and k2<200 then
      fftlim=(fft0*sin(ang*4)+fft1*sin(ang*8)/2)
      if (z2%10-2)<fftlim then
       clr=14-(k2/2)
       clr=math.max(0,clr)
       pix(sx,sy,clr)
      else
       pix(sx,sy,0)
      end
     end
    end
   else
    pix(sx,sy,0)
   end
  end
 end
end
