sin=math.sin
cos=math.cos
min=math.min

s="This is not performed by a professional, please try this at home :)"
sp=240

function rot(x,y,a)
   rx=x*cos(a)-y*sin(a)
   ry=x*sin(a)+y*cos(a)
   return rx,ry
end

function rline(x,y,c,a)
   rx,ry=rot(x,y,a)
   line(120,68,120+rx,68-ry,c)
end

t=0
function TIC()
   t=t+1
   if t<10 then return end

   vbank(0)
   cls()
   print(s,sp,0,3)
   if sp<-#s*6 then sp=240 else   sp=sp-1 end

   vbank(1)
   f1=min(fft(0,10)*100,40)
   f2=min(fft(10,40)*100,60)
   f3=min(fft(100,300)*100,80)
   if c1==11 then
      c1=0
      c2=0
      c3=0
   else
      c1=11
      c2=10
      c3=9
   end
   rline(f3,0,c3,t/250)
   rline(f2,0,c2,t/150)
   rline(-f1,0,c1,t/100)
end
