-- Monday Night Bytes \o/

sin=math.sin
cos=math.cos
rnd=math.random
sqr=math.sqrt
pow=math.pow
abs=math.abs

function BOOT()
   T=0
   t={}
   for i=1,1500 do
      t[i]={x=120,y=68,c=3}
   end
end

function TIC()
   cls()
   T=T+1
   for i=1,#t do
      p=t[i]
      pix(p.x,p.y,p.c)
      a1=abs(sin(T/100))*fft(0,50)*10//10
      a2=abs(cos(T/100))*fft(0,50)*10//10
      p.x=p.x+rnd(-a1,a2)
      p.y=p.y+rnd(-a1,a2)
      p.c=sqr(pow(p.x-120,2)+pow(p.y-68,2))/10+1
      if p.x>240 or p.x<0 or p.y>136 or p.y<0 then
         p.x=120
         p.y=68
      end
   end
end
