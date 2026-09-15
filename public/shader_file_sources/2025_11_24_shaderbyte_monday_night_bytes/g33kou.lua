sub=string.sub
sin=math.sin
rnd=math.random
min=math.min

function BOOT()
   s="Hello jammers \\o/"
   t={}
   for i=1,200 do
      t[i]={x=120,y=68,c=rnd(1,11)}
   end
   d=0
   cls()
end

function TIC()
   ff=min(fft(0,50)/20,10)
   vbank(1)
   cls()
   for i=1,#s do
      print(sub(s,i,i),20+i*10,10+sin(i*ff/1.5)*6,14)
      print(sub(s,i,i),19+i*10,9+sin(i*ff/1.5)*6,12)
   end
   vbank(0)
   ff=min(fft(0,50),2)/2
   for i=1,#t do
      p=t[i]
      p.x=p.x+rnd(-1,1)*ff
      p.y=p.y-rnd(-1,1)*ff
      pix(p.x,p.y,p.c)
      if p.x>240 or p.x<0 or p.y>136 or p.y<0 then
         p.x=120
         p.y=135
         p.c=rnd(1,11)
      end
   end
   d=d+fft(0,20)
   circb(120,68,d%150,0)
end
