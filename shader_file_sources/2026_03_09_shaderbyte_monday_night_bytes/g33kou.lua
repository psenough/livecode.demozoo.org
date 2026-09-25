sin=math.sin
cos=math.cos
pi=math.pi

function rot(x,y,a)
   return x*cos(a)-y*sin(a), x*sin(a)+y*cos(a)
end

function BOOT()
   t={}
   a,c=0,0
   dx,dy=120,68
   cls()
end

function TIC()
   cls()
   print("It's Revision soon \\o/",2,2,0)
   print("It's Revision soon \\o/",1,1,c%10+1)
   for i=1,99 do
      t[i]=vqt(i)*80
   end
   for i=1,#t do
      x,y=rot(i-50, t[i]-50, a)
      circ(dx+x, dy-y, 1, i)
      x,y=rot(i-50, t[i]-50, a+pi/2)
      circ(dx+x, dy-y, 1, i)
      x,y=rot(i-50, t[i]-50, a+pi)
      circ(dx+x, dy-y, 1, i)
      x,y=rot(i-50, t[i]-50, a+3*pi/2)
      circ(dx+x, dy-y, 1, i)
   end
   a=a+.01
   c=c+.08
end
