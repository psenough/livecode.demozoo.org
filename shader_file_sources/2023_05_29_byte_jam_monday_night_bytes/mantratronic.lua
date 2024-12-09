-- mt
-- gonna try a flow field
-- greets to all

m=math
s=m.sin
c=m.cos
r=m.random
tau=m.pi*2

p={} -- x,y
np=500

ff={}
fs=10

speed=1
curve=0.5 --LOL mispelt curve as curse

function BDR(l)
 vbank(0)
 ra=5*s(t/100)
 ga=5*s(t/110)
 ba=5*s(t/130)
 if l==1 then
  for i=0,15 do
   j=15-i
   poke(0x3fc0 + i*3,255-i*(10+ra))
   poke(0x3fc0 + i*3 + 1,255-i*(10+ga))
   poke(0x3fc0 + i*3 + 2,255-i*(10+ba))
  end
 end
end

function BOOT()
cls()
for i=1,np do
p[i]={x=r(240),y=r(136)}
end

for x=0,240/fs+1 do
 ff[x]={}
 for y=0,136/fs+1 do
  ff[x][y]=s(x*curve)+c(y*curve)
 end
end
end
t=0

first=true

function TIC()t=t+1
 if t == 600 then
  t=0
  first=true
 end
--[[
 vbank(1)
 cls()
for i=1,#ff do
 for j=1,#ff[i] do
  line((i-1)*fs,(j-1)*fs,(i-1)*fs+2*s(ff[i][j]),(j-1)*fs+2*c(ff[i][j]),3)
 end
end
--]]
 vbank(0)
 if first == true then
  curve = r()
  cls()
  len=print("monday",240,0,15,false,5)
  print("monday",120-len/2,10,15,false,5)
  len=print("night",240,0,15,false,5)
  print("night",120-len/2,50,15,false,5)
  len=print("bytes",240,0,15,false,5)
  print("bytes",120-len/2,90,15,false,5)
  p={}
  while #p < np do
   x=r(240)-1
   y=r(136)-1
   if pix(x,y) == 15 then
    table.insert(p,{x=x,y=y})
   end
  end
  first=false
 end
 

 for i=1,8000 do
  x=r(240)-1
  y=r(136)-1
  col=pix(x,y)
  if col == 0 then
  else
   pix(x,y,col-1)
  end
 end
 if t%4 == 0 then
 for x=0,240/fs+1 do
  ff[x]={}
  for y=0,136/fs+1 do
   ff[x][y]=s(x*curve+t/100)+c(y*curve+t/300)
  end
 end
 end
 for i=1,np do
  x = p[i].x 
  y = p[i].y
  
  fx=x//fs
  fy=y//fs
  
  if fx < 0 or fx > #ff or fy < 0 or fy > #ff[fx] then
   x = r(240)
   y = r(136)
   fx=x//fs
   fy=y//fs
   p[i].x = x
   p[i].y = y
  end
   fa = ff[x//fs][y//fs]
  
   x = x+speed*s(fa)
   y = y+speed*c(fa)
  
   p[i].x = x
   p[i].y = y
   pix(p[i].x,p[i].y,15)
 end
end
