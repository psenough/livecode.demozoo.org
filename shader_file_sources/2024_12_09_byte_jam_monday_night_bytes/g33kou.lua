min=math.min
rnd=math.random

star={
0,-3,-2,-2,-1,-4,-3,-5,-1,-5,0,-7,1,-5,3,
-5,1,-4,2,-2,0,-3
}

function poly(p,ox,oy,s,c)
   for i=1,#p-2,2 do
      line(ox+p[i]*s, oy+p[i+1]*s, ox+p[i+2]*s, oy+p[i+3]*s, c)
   end
end

function tree(ox,oy,s)
   for i=0,5 do
      line(ox, oy+y*s, ox+x*s, oy+(y+3)*s, 5)
      line(ox+x*s, oy+(y+3)*s, ox, oy+(y+2)*s, 5)
      line(ox, oy+(y+2)*s, ox-x*s, oy+(y+3)*s, 5)
      line(ox-x*s, oy+(y+3)*s, ox, oy+y*s, 5)
      x=x+1
      y=y+2
   end
end

function snow()
   for i=1,1000 do
      sn[i]={x=rnd(0,240), y=0, s=rnd(1,2)}
   end
end

sn={}
t=0
function TIC()
   cls()
   if t%1300==0 then
      snow()
      j=10
   end
   x=3
   y=0
   tree(200,60,5)
   f=min(fft(0,10),8)
   poly(star,200,60,f,4)
   for i=0,2 do
      poly(star,rnd(20,200),rnd(20,50),rnd(1,3),rnd(2,12))
   end
   for i=1,j do
      pix(sn[i].x,sn[i].y,12)
      sn[i].y = sn[i].y + sn[i].s
      if sn[i].y > 135 then sn[i].y=135 end
   end
   if j<#sn then j=j+1 end
   print("Merry Xmas !",10,100,4,0,2)
   t=t+1
end
