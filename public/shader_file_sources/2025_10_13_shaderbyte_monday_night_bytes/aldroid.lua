-- hello!
 clip(0,0,0,0)
 a = 0
 a = print("IDEA",120-a/2,20,4,true,10)
clip()
function dlg(ca,cb)
 cls(ca)
 elli(120,68,120,68,cb)
 print("IDEA",120-a/2,40,ca,true,10)
end
dlg(9,5)
 
dir=0

cldn=0
lft = 0
function TIC()
 if time()//1000>lft then
  dir=(dir+1)%4
 end
 if dir == 0 then
  mx =1
  my =0
 elseif dir == 1 then
  mx =0
  my =1
 elseif dir == 2 then
  mx =-1
  my =0
 else
  mx =0
  my =-1
 end
 for rx=0,239,4 do for ry=0,135,4 do
  x= rx+math.random(0,4)
  y= ry+math.random(0,4)
  pix(x,y,pix(x+mx,y+my)) 
 end end
 t=time()
 
 if fft(0,10)>0.9 and t - cldn > 500 then 
  cldn = t
		clip(math.random(0,220),math.random(0,120),math.random(60,180),math.random(10,90))
c1=		math.random(0,15)
c2 =math.random(0,15)
if c1==c2 then c2 = c2 + 1 end
		dlg(c1,c2)
		clip()
 end
end