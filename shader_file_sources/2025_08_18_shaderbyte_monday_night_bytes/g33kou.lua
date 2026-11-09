-- Hello everyone :)
-- Back from Evoke \o/

rnd=math.random
sin=math.sin
cos=math.cos
min=math.min
abs=math.abs

function BOOT()
   TP={}
   for i=1,1500 do
      TP[i]={x=0,y=0,a=rnd(628)/100,v=rnd(100)/100,h=0}
   end
   A=0
end

function rot(x,y,a)
   return x*cos(a)-y*sin(a), x*sin(a)+y*cos(a)
end

function part(p)
   local rx,ry
   A=A+fft(25)/4000
   p.x=p.x+cos(p.a)*p.v
   p.y=p.y+sin(p.a)*p.v
   rx,ry=rot(p.x,p.y,A)
   pix(120+rx,68+ry,min(abs(p.v)*10,11)+1)
   if p.h==0 then
      if p.v>-.5 then p.v=p.v-.008 else p.h=1 end
   else
      if p.v<.5 then p.v=p.v+.005 else p.h=0 end
   end
end

function TIC()
cls()
   for i=1,#TP do
      part(TP[i])
   end
end
