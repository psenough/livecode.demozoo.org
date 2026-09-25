sin=math.sin
cos=math.cos
pi=math.pi
rnd=math.random

t1="It's Monday night !"
t2="and almost h0ffman's Monday ;)"
T=0

function BOOT()
   t={}
   for i=1,10 do
      t[i]={x=rnd(240), y=rnd(136), c=rnd(1,16)}
   end
   r=1
   off=.3
end

function TIC()
   T=T+1
   
   vbank(1)
   cls()
   for i=0,#t1 do
      c=(i+T/10)%15+1
      print(t1:sub(i,i),   20+i*6,   50+sin(i+T/10)*3,   c)
   end
   for i=0,#t2 do
      c=(i+T/10)%15+1
      print(t2:sub(i,i),   40+i*6,   70+sin(i+T/10)*3,   c)
   end
   
   vbank(0)
   cls()
   for j=1,#t do
      p=t[j]
      a=2*pi/(4*r)
      for i=0,5*r do
         x=p.x+r*cos(a*i)
         y=p.y+r*sin(a*i)
         pix(x,y,p.c+i)
      end
   end
   
   r=r+off
   if r>50 then
      off=-.3
   end
   if r<0 then
      BOOT()
   end
end
