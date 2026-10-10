-- F#READY
-- try day #4
-- prepared code
-- byte jam, hackfest 2024

p1=90
q1=40
p2=100
q2=40
m=math

function TIC()
t=time()/900
cls()

x1=120+m.sin(t)*p1
y1=68+m.cos(t+20)*q1
x2=120+m.sin(t+10)*p2
y2=68+m.cos(t)*q2

for y=0,135 do
 for x=0,239 do
   dx1=m.abs(x-x1)
   dy1=m.abs(y-y1)
   dx2=m.abs(x-x2)
   dy2=m.abs(y-y2)

   c=100/m.sqrt(dx1*dx1+dy1*dy1)
   c=c+(60/m.sqrt(dx2*dx2+dy2*dy2))
   pix(x,y,m.min(c,8))
 end
end
end
