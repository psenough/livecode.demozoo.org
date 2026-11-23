t=0
m=math
ft={}

function BOOT()
 for x=1,255 do
  poke(16320+x%48,x%48*5*(1-(bass+x%3)/3))
  ft[x]=0
 end
 cls()
 for i=0,240 * 136 do
  pix(i%240,i//240,i>>3)
 end
end

function rot2D(v,a)
 return {
  x=m.cos(a)*v.x+m.sin(a)*-v.y,
  y=m.cos(a)*v.y+m.sin(a)*v.x
 }
end

bass=0
snare=0
function TIC()
 poke(0x3ffb,255)
 for x=0,20 do
  if x<10 then
   bass=bass+fft(x)
  else 
   snare=snare+fft(x)
  end
 end
 t2=bass/8
 --c
 o={x=t%280-20,y=68}
 l0={x=o.x+m.sin(t2)*6+12,y=o.y-32+m.cos(t2)*4}
 r0={x=o.x+m.sin(t2+1.5)*6+24,y=o.y-32+m.cos(t2+1.5)*4}
 tri(o.x,o.y,l0.x,l0.y,r0.x,r0.y,15)
 elli((l0.x+r0.x)/2+7,l0.y-10,4,6,15)
 --ul
 t2=bass/32
 l1={x=o.x-m.sin(t2*2)*16,y=o.y+26+m.cos(t2*2)*4}
 r1={x=o.x-m.sin(t2*2+3)*16,y=o.y+26+m.cos(t2*2+3)*4}
 tri(o.x+6,o.y,o.x,o.y,l1.x,l1.y,15)
 tri(o.x-6,o.y,o.x,o.y,r1.x,r1.y,15)
 --ll
 l2={x=l1.x-m.sin(t2*2)*8-8,y=l1.y+22+m.cos(t2*2)*4}
 r2={x=r1.x-m.sin(t2*2+3)*8-8,y=r1.y+22+m.cos(t2*2+3)*4}
 tri(l1.x+5,l1.y,l1.x,l1.y,l2.x,l2.y,15)
 tri(r1.x-5,r1.y,r1.x,r1.y,r2.x,r2.y,15)
 --ua
 t2=snare/8
 l1={x=l0.x+m.sin(t2)*8-14,y=l0.y+22+m.cos(t2*2)*4}
 r1={x=r0.x+m.sin(t2+3)*8-14,y=r0.y+22+m.cos(t2*2+3)*4}
 tri(l0.x+4,l0.y,l0.x,l0.y-4,l1.x,l1.y,15)
 tri(r0.x+4,r0.y,r0.x,r0.y-4,r1.x,r1.y,15)
 --la
 l2={x=l1.x+m.sin(t2)*6-10,y=l1.y+12+m.cos(t2*2)*4}
 r2={x=r1.x+m.sin(t2+3)*6-10,y=r1.y+12+m.cos(t2*2+3)*4}
 tri(l1.x+3,l1.y,l1.x,l1.y-3,l2.x,l2.y,15)
 tri(r1.x+3,r1.y,r1.x,r1.y-3,r2.x,r2.y,15)
 
 t=t+.5
end

function SCN(y)
 for x=0,240 do
  pix(x,y,m.max(0,pix((x+2)%239,y)-x%3%2))
 end
end
