-- hello jammers \o/
-- let's explore fireworks

rnd=math.random
sin=math.sin
cos=math.cos

function addfw()
   local x,y
   local c={}
   local p={}
   x=30+rnd(200)
   y=rnd(70)
   c[1]=1+rnd(10)
   c[2]=1+rnd(10)
   for i=1,1000 do
      p[i]={x=x,y=y,a=rnd(628)/100,v=rnd(100)/100,
         c=c[rnd(2)],d=30+rnd(70)}
   end
   return p
end

function BOOT()
   TF={}
   for i=1,4 do
      TF[i]=addfw()
   end
   T=0
   last=0
end

function TIC()
   local p
   T=T+1
   cls()
   for i=1,#TF do
      for j=1,#TF[i] do
         p=TF[i][j]
         if p.d>0 then
            p.x=p.x+cos(p.a)*p.v
            p.y=p.y+sin(p.a)*p.v
            pix(p.x,p.y,p.c)
            p.d=p.d-1
         else
            if T-last>30+rnd(70) and fft(0,50)>.9 then
               TF[i]=addfw()
               last=T
            end
         end
      end
   end
end
