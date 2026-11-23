-- hello there :)
-- Tonight's theme is SIN and PAL  \o/

sin=math.sin
cos=math.cos
abs=math.abs
rnd=math.random
PAL=0x3fc0

function draw(x,y,c,a)
   for i=0,x do
      local rx,ry=rot(i-120, abs(sin(i/10))*10, a)
      pix(120+rx, y-ry, c)
   end
end

function rot(x,y,a)
   return x*cos(a)-y*sin(a), y*cos(a)+x*sin(a)
end

function BDR(l)
   local i=12
   if l==120 then
      poke(PAL+i*3, 0)
      poke(PAL+i*3+1, 0)
      poke(PAL+i*3+2, 0)
   else
      r=peek(PAL+i*3)
      g=peek(PAL+i*3+1)
      b=peek(PAL+i*3+2)
      poke(PAL+i*3, r+l)
      poke(PAL+i*3+1, g+(T/10)%100)
      poke(PAL+i*3+2, b+l*2)
   end
end

cls()
T=0
function TIC()
   T=T+1
   for i=0,800 do pix(rnd(241)-1,rnd(100),0) end
   rect(0,100,240,40,0)
   local v=sin(T/20)/10
   draw(T%240, 30+fft(400,800), 12, v)
   draw(240, 50+fft(100,400)*1.5, 12, 0)
   draw(T%240, 80+fft(50,100), 12, -v)
   draw(T%240, 110+fft(0,50)*2, 12, 0)
end
