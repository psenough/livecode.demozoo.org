function tile(x,y,z)
 if (x+8&18==0)~=(y+8&18==0) then
  return 3+z
 else
  return 13+z
 end
end

function rot(x,y,t)
 return x*math.cos(t)-y*math.sin(t), x*math.sin(t)+y*math.cos(t)
end

function BOOT()
    for i=0,15 do
        poke(16320+3*i,i*16)
        poke(16321+3*i,50)
        poke(16322+3*i,math.min(128-i*8,128+i*8))
    end
end

function TIC()
 t=time()/1000
 f=fft(1)
 for x=0,239 do for y=0,136 do
  x0 = x-120
  y0 = y-68
  l = math.sqrt(x0*x0+y0*y0)/100
  x1,y1 = rot(x0,y0,-2/(l+0.1)*f*2+t)
  pix(x,y,tile(
      math.floor(x1),
   math.floor(y1),
   -f*3-l*7
  ))
 end end
 circ(120,68,15+f*40,-f*5)--3+f*6+l+t)
end