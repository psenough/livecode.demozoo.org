-- aldroid here!
-- thanks to violet and polynomial
-- for hosting
-- glhf to doop, lex and catnip!

function len3(x,y,z)
  return (x^2+y^2+z^2)^0.5
 end
 
 function SCN(l)
 poke(0x3fc2,math.max(0,135-l))
 end
 
 max = math.max
 C=math.cos
 S=math.sin
 
 function rot(x,y,a)
  return x*C(a)+y*S(a),y*C(a)-x*S(a)
 end
 
 function cube(x,y,z)
  x=math.abs(x)-1
  y=math.abs(y)-1
  z=math.abs(z)-1
  return max(x,max(y,z))
 end
 
 function m(x,y,z)
  x = x + S(time()/900)*2
  y,z=rot(y,z,S(time()/2000)*3)
  x,z=rot(x,z,time()/1000)
  return cube(x,y,z)
 end
 
 function gn(x,y,z)
  e=0.01
  d=m(x,y,z)
  dx=d-m(x+e,y,z)
  dy=d-m(x,y+e,z)
  dz=d-m(x,y,z+e)
  nv=len3(dx,dy,dz)
  return dx/nv,dy/nv,dz/nv
 end
 
 for i=0,15 do
  poke(0x3fc0+3*i+0,255/15*(i))
  poke(0x3fc0+3*i+1,255/15*(i >10 and i or 0))
  poke(0x3fc0+3*i+2,255/15*(i < 4 and i or 0))
 end
 
 qc=0
 ql=0
 cls(0)
 function TIC()
  if qc > 0 then
   qc = qc - 1
  elseif ql < fft(1) then
   qc=500
   cls(15)
  else
   ql=fft(1)
  end
  for i=0,240*136 do
    px=peek4(i)
    px=math.max(px-1,0)
   poke4(i,px)
  end
  lx=3
  ly=-4
  lz=3
  ln=len3(lx,ly,lz)
  lx=lx/ln
  ly=ly/ln
  lz=lz/ln
  scaler = 185+fft(1)*200
  for X=0,240,8 do for Y=0,135,8 do
   x=(120-X)/scaler
   y=(68-Y)/scaler
   z=-10
   
   lp=len3(x,y,1)
   
   xd=x/lp
   yd=y/lp
     zd=1/lp
     
     x=0
     y=0
     
     t=0
     d=0
     while t<20 do
      d=m(x+t*xd,y+t*yd,z+t*zd)
       if d<0.1 then break end
       t = t +d
     end
     
     if t < 20 then
       nx,ny,nz=gn(x+t*xd,y+t*yd,z+t*zd)
       lm=lx*nx+ly*ny+lz*nz
       lm=math.max(0,lm)
 --			pix(X,Y,1+lm*10)
      circ(X,Y,1+lm*4,2+lm*13)
     end
   
  end end
 end
 