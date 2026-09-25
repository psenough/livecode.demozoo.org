-- cheers jammers & others :)
-- joyeux anniversaire RaccoonViolet !!!

sin=math.sin
abs=math.abs
min=math.min

rac={
-- ears
-6,1,-7,6, -7,6,-4,4,
6,1,7,6, 7,6,4,4,
-- head
-4,4,-3,5, -3,5,3,5, 3,5,4,4, 4,4,6,1, 6,1,7,-2, 7,-2,1,-6, 1,-6,-1,-6, -1,-6,-7,-2, -7,-2,-6,1, -6,1,-4,4,
-- left
-3,5,-2,1, -2,1,-7,-2,
-2,1,-2,-1, -2,-1,-4,-4,
-2,-1,-1,-2,
-- right
3,5,2,1, 2,1,7,-2,
2,1,2,-1, 2,-1,4,-4,
2,-1,1,-2,
-- nose
-1,-2,1,-2, 1,-2,1,-3, 1,-3,0,-4, 0,-4,-1,-3, -1,-3,-1,-2,
-- mouth
-4,-4,-3,-4, -3,-4,-1,-5, -1,-5,1,-5, 1,-5,3,-4, 3,-4,4,-4,
}

function poly(x,y,p,m,c,ff)
   for i=1,#p,4 do
      line(x+p[i]*m,y-p[i+1]*m-ff,x+p[i+2]*m,y-p[i+3]*m-ff,c)
   end
end

t=0
function TIC()
   t=t+1
   ff=fft(0,40)*2
   h=10*abs(sin(t/60))
   v=10
   l={
      h={-h,v,-h,-v, -h,0,h,0, h,v,h,-v},
      a={-h,-v,0,v, 0,v,h,-v, -h/2,0,h/2,0},
      p={-h,-v,-h,v, -h,v,h,v, h,v,h/2,0, h/2,0,-h,0},
      y={-h,-v,h,v, -h,v,0,0},
      b={-h,-v,-h,v, -h,v,h/2,v, h/2,v,0,0, -h,0,h,0, h,0,h/2,-v, h/2,-v,-h,-v},
      i={0,v,0,-v},
      r={-h,-v,-h,v, -h,v,h,v, h,v,h/2,0, h/2,0,-h,0, 0,0,h,-v},
      t={0,v,0,-v, -h,v,h,v},
      d={-h,v,-h,-v, -h,v,h,3/4*v, h,3/4*v,h,-3/4*v, h,-3/4*v,-h,-v},
   }
   hap={l.h,l.a,l.p,l.p,l.y}
   day={l.b,l.i,l.r,l.t,l.h,l.d,l.a,l.y}
   cls()
   poly(200,100,rac,5,12,ff)
   scl=h*2.6*abs(sin(t/60))
   for i=1,#hap do
      poly(i*scl,20,hap[i],1,3,1)
   end
   for i=1,#day do
      poly(i*scl,50,day[i],1,4,1)
   end
end
