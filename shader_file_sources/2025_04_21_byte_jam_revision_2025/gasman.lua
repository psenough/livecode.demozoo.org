-- hello from gasman
-- i was going to be doing spectrum
-- jamming until 10 seconds ago,
-- so I have no idea what to do lol

sin=math.sin
cos=math.cos
pi=math.pi

-- did I say cls was for losers?
-- i never said that. cls is great
cls()

function orb(xoff1,xoff2,scl)
 xr=t/534
 zr=t/678
 yr=t/765

 for i=0,29 do
  for j=0,29 do
   -- didn't expect that.
   -- let's run with it :-D
   x0=sin(j*pi/15)+xoff1
   z0=cos(j*pi/15)
   yr0=i*pi/15
   y1=sin(yr0)
   x1=x0*cos(yr0)+xoff2
   -- sin was quite nice,
   -- let's interp between them
   z1a=z0*cos(yr0)
   z1b=z0*sin(yr0)
   zt=sin(t/345)/2+0.5
   z1=z1a*zt+z1b*(1-zt)
   
   x2=x1
   y2=y1*cos(xr)+z1*sin(xr)
   z2=z1*cos(xr)-y1*sin(xr)
   
   x3=x2*cos(zr)+y2*sin(zr)
   y3=y2*cos(zr)-x2*sin(zr)
   z3=z2
   
   -- doesn't look like perspective
   -- looks cool anyway
   x5=x3*(1/(z3+.5))
   y5=y3*(1/(z3+.5))
   
   circ(120+scl*x5,68+scl*y5,2+z3/2,t/123+8*z3)
  end
 end
end

poke(16320,0)
poke(16321,0)
poke(16322,0)

function TIC()
 t=time()

 -- palette cycling
 pt=t/845
 poke(16323,32+32*sin(pt))
 poke(16324,32+32*sin(pt+1))
 poke(16325,32+32*sin(pt+2))
 
 --cls is for losers.
 --cls()
 for sy=0,137 do
  for sx=0,239 do
   ran=math.random()
   if ran<0.3 then
    --i think some rotating
    -- feedback would
    -- work nicely here
    x=sx-120
    y=sy-68
    r=-.02
    x1=(x*cos(r)+y*sin(r))*0.95
    y1=(y*cos(r)-x*sin(r))*0.95
    pix(sx,sy,
     pix(
      (x1+120)//1,
      (y1+68)//1
     )
    )
   elseif ran<0.4 then
    x=sx-120
    y=sy-68
    sec=math.atan2(x,y)*4//pi
    r=math.sqrt(x*x+y*y)/10
    v=(r-t/123+sec)%3
    if v>=2 then
     pix(sx,sy,1)
    else
     pix(sx,sy,0)
    end
   end
  end
 end

 s=20+15*sin(t/200)

 orb(1.5,3,s)
 orb(1.5,-3,s)
end
