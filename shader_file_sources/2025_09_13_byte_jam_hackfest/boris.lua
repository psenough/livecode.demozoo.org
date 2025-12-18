s = math.sin
c = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi
t=0

function TIC()
 ff = fft(0,20)
 t=t+1
 for y = 0,135 do
  for x = 0,239 do
    yy = y - 68
    xx = x - 120
    ang = atan(xx,yy) + t
    dist = sqrt(xx*xx + yy*yy)
    c1 = 0.1*s(0.5*dist*s(2*ang)) 
      + 0.1*(dist+ff+1*s(0.1*ff))
      -8*s(s(0.02*(t+ff))*0.1*x + 1*s(0.2*t))
      +8*c(c(0.015*(t+ff))*0.12*y + 1*s(0.2*t))
    c2 =
        0.2*c(dist*s(0.02*t))
      + 0.1*s(dist+t)
      +3*c(s(0.052*t)*0.21*(x))
      +5*s(s(0.014*t)*0.19*(y+0.5*t))
      +4*s(s(0.01*t)*0.6*dist)
    c1 = c1 + 0*s(2*pi*(ang+ff))
    c2 = c2 + 0*c(0.1*pi*(dist+ff))
    col = 0 + c1 % 4
    if c2 > 3 and c2 < 9 then col = 5 + c2%8 end
    pix(x,y,col)
  end
 end    
end