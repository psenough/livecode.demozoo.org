-- happy jam everyone :)
-- let's random some colors

rnd=math.random

function pal(i,r,g,b)
   poke(0x3fc0+i*3,r)
   poke(0x3fc0+i*3+1,g)
   poke(0x3fc0+i*3+2,b)
end

function BOOT()
   r=rnd(3,17)
   g=rnd(3,17)
   b=rnd(3,17)
   cx=120
   cy=68
   cvx=1
   cvy=1
   T=0
   cls()
end

function TIC()
   ff=fft(0,50)
   if T%3==0 and ff>5 then
      r=rnd(3,17)
      g=rnd(3,17)
      b=rnd(3,17)
      for i=1,15 do
         pal(i,i*r,i*g,i*b)
      end
   end
   for i=1,20 do
      pix(rnd(0,240),rnd(0,136),rnd(0,15))
   end
   circ(cx,cy,10+ff*2,0)
   cx=cx+cvx
   cy=cy+cvy
   if cx>240 or cx<0 then cvx=-cvx end
   if cy>136 or cy<0 then cvy=-cvy end
   T=T+1
end
