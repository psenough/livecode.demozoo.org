lbt = time()

function plotfft()
  for x =0,240 do
    line(x,0,x,fft(x)*100,5)
  end
end

window={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
wintot=0
windex=0
function beat()
 p=0
 for x=0,10 do
   p=p+math.floor(fft(x)*100)
 end

 wintot = wintot + p - window[windex+1]
 window[windex+1] = p
 windex = (windex + 1)%#window
 local p2 = wintot/#window
 if (time()-lbt) < 300 then
  return {false, p/p2}
 end

 b = p>(p2*1.3)
 if b then
   lbt = time()
 end

 return {b, p/p2}
end
sin=math.sin
function line1(x)
 return sin(x)+sin(2*x)+sin(3*x)+sin(x+(1.4*x))
end
function line2(x)
 return -(sin(x-2.9)+sin(4*x)+sin(1.3*x)+sin(x+(1.4*x)))
end
function line3(x)
 return sin(x+4)+sin(2*x)+sin(1.4*x)+sin(x+(1.8*x))
end

a=true

function node(x,y,a,p)
	if a then
 	circ(x,y,p,3)
 else
 	circ(x,y,p,6)
 end
end

bx=5
by=0
function TIC()
 cls()
 --plotfft()
	t=time()/10
	local be = beat()
	local b = be[1]
	local p = math.max(0,be[2]*10)
	local ox=t/8
	local oy=t/5

 scale=10
 s2=30
 tt=62.832*scale
 dx=ox % tt
 dy=oy % 80
 ls = 4
 p3 = (p+3)/2
 
 ptx1=0
 ptx2=0
 ptx3=0
 pty1=0
 pty2=0
 pty3=0 
 
 pc3={}
 
 if b then
  if p%1>0.5 then
   bx=bx+1
  else
   by=by+1
  end
 end

 for i=0,3 do
  for x=0,(240*2)/s2 do
   dy2=dy+((i-2)*80)
   tx = (x*s2)-(dx%240)
   ty1 = dy2+-30+68+ls*line1(((x*s2)+dx)/scale)
   ty2 = dy2+    68+ls*line2(((x*s2)+dx)/scale)
   ty3 = dy2+ 30+68+ls*line3(((x*s2)+dx)/scale)
   tx1 = tx+(5*sin(tx))
   tx2 = tx+(5*sin(tx+1))
   tx3 = tx+(5*sin(tx+2))

   node(tx1,ty1,a,p3)
   node(tx2,ty2,a,p3)
   node(tx3,ty3,a,p3)

   bi = ((1+math.floor(oy/80))+by) % 9

   if x == (bx%11)+4 and i == (bi//3) then
    ay=ty1
    if bi % 3 == 1 then
     ay=ty2
    end
    if bi % 3 == 2 then
     ay=ty3
    end
    circ(tx2,ay,3*p3,2)
   end
   line(tx1,ty1,tx2,ty2,4)
   line(tx2,ty2,tx3,ty3,4)
   if x>0 then
   line(tx1,ty1,ptx1,pty1,4)
   line(tx2,ty2,ptx2,pty2,4)
   line(tx3,ty3,ptx3,pty3,4)
   end
   ptx1=tx1
   ptx2=tx2
   ptx3=tx3
   pty1=ty1
   pty2=ty2
   pty3=ty3
   if i>0 then
    line(tx1,ty1,pc3[x+1][1],pc3[x+1][2],4)
   end
   pc3[x+1]={ptx3,pty3}
  end
  
 end

	if b then
		a = not a
	end
end
