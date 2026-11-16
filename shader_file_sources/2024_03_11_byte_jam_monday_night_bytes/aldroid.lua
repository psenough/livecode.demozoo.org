-- hello and thanks to mallard, 
-- raccoonviolet, and my co-coders!
-- Vurpo, Pumpuli, and Catnip

-- no plan. never any plan...

S=math.sin
C=math.cos

function src(x,y,r,c)
 for i=0,90 do
  a=math.random()*math.pi*2
  rr=math.random()
  rr=rr*r*(1+math.exp(-rr*rr))/2
  pix(x+C(a)*rr,y+S(a)*rr,c)
 end
end

function TIC2()t=time()//32
vbank(0)
for y=0,136 do for x=0,240 do
pix(x,y,(x+y+t)>>3)
end end 
t=time()/32
vbank(1)
poke(0x03FF8,1)

rect(115+120*S(t/64),0,10,136,0)

bf1 = S(t/3)
src(120+bf1*20+S(t/30)*90,68-bf1*60,
30-bf1*bf1*20,1)
end

function proj(x,y,z)
X=x/(30-z)
Y=y/(30-z)

return X*100,Y*100
end


function quad(x1,y1,x2,y2,height,c)

	tx1,ty1=proj(x1,height,y1)
	tx2,ty2=proj(x2,height,y1)
	tx3,ty3=proj(x1,height,y2)
	tx4,ty4=proj(x2,height,y2)
	tri(
	 120+tx1,68+ty1,
		120+tx2,68+ty2,
		120+tx3,68+ty3,
 	c)
	tri(
	 120+tx2,68+ty2,
		120+tx4,68+ty4,
		120+tx3,68+ty3,
 	c)
end

function tch(ch,px,py,c)
 chn=string.byte(ch)
 for y=0,7 do
  row=peek(0x14604+chn*8+y)
  for x=0,7 do
   if (row>>x)&1 ==1 then
    quad(x+px,-y+py,x+1+px,-y+1+py,-12,c)
   end
  end
 end
end

msgs = {
"A long",
"time ago",
"in a",
"galaxy",
"far far",
"away"
}

stars = {}

function TIC()
 cls()
 
 if #stars < 20 then
  table.insert(stars,{math.random(-10,10),math.random(10,30)})
 end
 for i=1,#stars do
  x,y=proj(stars[i][1],3,stars[i][2])
  pix(120+x,68-y,14)
 end
 
 for i=-1,1 do
 line(0,68+i*2,240,68+i*2,15-fft(i)*10)
 end
 t=time()/100
 for mi=1,#msgs do
  msg=msgs[mi]
	 for i=1,#msg do
		 tch(msg:sub(i,i),
			-35+i*8,
			-60+(t-mi*8)%80,4)
	 end
 end
 for i=1,15 do
  xo=-90
  yo=-3
	 quad(
		xo+i*12,yo,
		xo+(i+1)*12,yo+1-fft(i*20)*8000,
		18,i)
 end
 
 for i=1,#stars do
  stars[i][2]=stars[i][2]-0.2
  if stars[i][2]<0 then
   table.remove(stars,i)
   break
  end
 end
end