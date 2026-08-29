-- hello everyone :)
-- happy monday !

draw={}
function tab()
   local i
   for i=0,1023 do
      f=fft(i)*math.log(i)*200
      draw[i]=f
      draw[2047-i]=f
   end
end

function BOOT()
   max=7
   ox=3
   oy=2
   lln=64
   tab()
end

function TIC()
   for   i=0,max do
      y=i//lln
      x=i%lln
      vbank(0)
      cls()
      line(120,136,(240-lln*ox)/2+x*ox,10+y*oy,12)
      vbank(1)
      pix((240-lln*ox)/2+x*ox,10+y*oy,draw[i]%16)
   end

   max=max+8
   if max>#draw then
      max=7
      tab()
   end
end
