
s = math.sin
c = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi

t=0
h = 136
w = 240
x = w/2
y = h/2

cls(0)
function TIC()

  --cls(13)
  for i = 0,20 do
    ii= (2.0+0.01*t)*i
    tt = 0.15*t
    n = 0.08*(ii + 0.9*tt)
    m = 0.09*(0.8*ii + tt)
    o = 0.13*(1.2*ii + 1.1*tt)
    p = 0.14*(1.3*ii + 1.2*tt)
    col = 1 + 0.25*(2.0*i+t) % 13
    --if col<2 then col = 2 end
    for flip = 0,1 do
     f = 1
     if flip==1 then f = -1 end
     uvx = f*0.8*x*s(o)
     uvy =	f*0.8*y*c(p)
     uvlen = sqrt(uvx*uvx + uvy*uvy)
     mx = atan(uvx / uvy) / 3.14159265;
     my = 1 / uvlen * .2;
     uvx = uvx + x + 30*mx
     uvy = uvy + y + 30*my

     circ(
       uvx,
       uvy,
       0.18*y + 0.05*y*s(8.0*m), col)
     circ(
       x+f*0.8*x*s(o),
       y+f*0.8*y*c(p),
       0.15*y + 0.05*y*s(8.0*m), col+1)
     circ(
       x+f*0.8*x*s(o),
       y+f*0.8*y*c(p),
       0.10*y + 0.08*y*s(8.0*m), col+2)
    end
    --line(
    --  x+0.8*x*s(n),
    --	 y+0.8*y*c(m),
    --		x+0.3*x*s(o),
    --		y+0.3*y*c(p),col)
    --line(
    --  x-0.8*x*s(n),
    --	 y+0.8*y*c(m),
    --		x-0.3*x*s(o),
    --		y+0.3*y*c(p),col)
  end
  t=t+1

  for yy = -1,135 do
    for xx = 0,239 do
      col = pix(xx,yy+1)
      if (col > 0 
      and rand()>0.75+0.25*s(0.025*t)) then
        pix(xx,yy,col)
      end
      if (col > 0 
      and rand()>0.25+0.25*c(0.015*t)) then
        pix(xx,yy+1,col-1)
      end
    end
  end
end
