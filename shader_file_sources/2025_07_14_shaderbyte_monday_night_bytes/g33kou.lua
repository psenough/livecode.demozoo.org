-- hello all <3
-- just testing some coloring stuff tonight ^^'

sin=math.sin
abs=math.abs
pi=math.pi

function col(x,y,c)
   local c0,c1
   c0=pix(x,y)
   for i=x,240 do
      c=c+1
      for j=y,136 do
         c1=pix(i,j)
         if c1==c0 then   pix(i,j,c)   else   break   end
      end
      for j=y-1,0,-1 do
         c1=pix(i,j)
         if c1==c0 then   pix(i,j,c)   else   break   end
      end
   end
end

T=0
function TIC()
   T=T+1
   cls()
   for i=0,240 do
      pix(i,70+abs(sin(i/10+        T/50)  *20),3)
      pix(i,60-abs(sin(i/10+ pi/4   -T/50) *10),4)
      pix(i,40-abs(sin(i/10+ 2*pi/4 +T/50) *10),5)
      pix(i,25-abs(sin(i/10+ 3*pi/4 -T/50) *20),6)
   end
   col(0,25,(T/5))
   col(0,40,fft(0,50))
   col(0,60,(T/5))
end
