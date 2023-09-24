m=math
s=m.sin
c=m.cos
tau=m.pi*2
function rot(lx,ly,la)
return lx*c(la)-ly*s(la)
end

function SCN(l)
r=t
for i=0,15 do
poke(0x3fc0+i*3,(r%15)*s(i)*15)
poke(0x3fc0+i*3+1,0)
poke(0x3fc0+i*3+2,((r+10)%15)*i)
end
end

function OVR()
for i=0,47 do
poke(0x3fc0+i,i//3*15)
end
tt=t*10
for i=1,20 do
circb(109,51,((tt+i)*5)%120,math.min(0,15*s(i/5)))
end
print(":         ____  __  ____________      :",5,40,15,true)
print(":    ____/    \\/ o\\/  __\\__  __/___   :",5,48,15,true)
print(":   /___\\   \\_/   /   _/_/   \\____/   :",5,56,15,true)
print(":        \\__/\\\\__/\\__/\\/ \\___/\\       :",5,64,15,true)
print(":         \\_\\/ \\_\\/\\_\\/   \\__\\dc@     :",5,72,15,true)
print(":good jam! planet hacked! now to sleep:",5,80,15,true)
-- noooooooo escape chars!
end
function TIC()t=time()/999
cls()
 for x=-12,12,.2 do 
  for y=-6,6,.1 do
  a=m.atan(x,y)
  d=(x^2+y^2)^2
  q=m.abs(x)+m.abs(y)
  q=q
  X=rot(x,y,s(t*s(d/10)))
  Y=rot(y,-x,s(t*c(d/10)))
  Q=m.abs(X)+m.abs(Y)
  D=s(c(d))*10
   if q%3 > 1 then
   rect(120+D*X,68+D*Y,5,5,Q+t*10)
   elseif q%3 > .5 then
   circ(120+D*X,68+D*Y,5*q%6,Q+t*10)
   else
   line(120+D*X,68+D*Y,125+D*X,63+D*Y,Q+t*10)
   end
  end
 end
 for i=0,500 do
 y=m.random(136)
 x=m.random(240)
 p=pix(x,y)
 for j=1,10 do
 pix(x+j,y,p)
 end
 end
end