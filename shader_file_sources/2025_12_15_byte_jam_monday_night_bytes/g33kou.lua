-- hi everyone \o/

pi=math.pi
cos=math.cos
sin=math.sin

s='hello there \\o/'
t={}
T=0
cls()
C=0
A=.4

function col(v)
   return v%6+7
end

function TIC()
   T=T+1
   if T==1 or #t>400 then
      cls()
      C=C+1
      A=A+.05
      t={
         {x=121,y=68,a=0,c=col(C)},
         {x=120,y=67,a=pi/2,c=col(C)},
         {x=119,y=68,a=pi,c=col(C)},
         {x=120,y=69,a=-pi/2,c=col(C)},
      }
   end
   for i=1,#t do
      local p=t[i]
      p.x=p.x+cos(p.a)
      p.y=p.y-sin(p.a)
      pix(p.x,p.y,p.c)
      if T%12==0 then
         t[#t+1]={x=p.x,y=p.y,a=p.a+A,c=col(p.c+1)}
         t[#t+1]={x=p.x,y=p.y,a=p.a-A,c=col(p.c+1)}
      end
   end
   for i=1,#s do
      print(string.sub(s,i,i),i*6,5,(T/10+i)%10+1)
   end
end
