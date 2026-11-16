-- hello jammers \o/
-- let's try another "firework" stuff ^^

rnd=math.random
sin=math.sin
cos=math.cos
min=math.min
abs=math.abs

function BOOT()
   T=0
   t={}
   for i=1,1000 do
      t[i]={x=120,y=68,c=3,a=0}
   end
   cls()
end

function TIC()
   T=T+1
   cls()
   for i=1,#t do
      p=t[i]
      ff=min(fft(0,50)/4,2)
      npx=cos(p.a)+rnd(-1,1)*ff
      npy=sin(p.a)+rnd(-1,1)*ff
      p.a=p.a+.01
      p.x=p.x+npx
      p.y=p.y-npy
      p.c=T/200+abs(npx+npy)+1
      pix(p.x,p.y,p.c)
      if p.x>240 or p.x<0 or p.y>136 or p.y<0 then
         p.x=120
         p.y=68
         p.c=0
      end
   end
end
