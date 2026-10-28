--lynn here!! ^-^
--idk i'm just a cat

-- thank fuck there's no size limit (:
function SCN(l)
	poke(0x03ff9,math.sin(t/2+(l/8))*8)
end

xoff=240
q=0
function TIC()cls()t=time()/64
	
	if q<10 then blobs()
	elseif q<20 then moire()
	elseif q<30 then kefrens()
	else q=0 end
 q=q+.1
 dycp()
end

function blobs()
	for i=8,0,-1 do
		for j=1,16 do
			x=(math.sin(j*2+(t/16))*96)+120
			y=(math.cos(j*7+(t/17))*64)+68
			s=(math.cos(t/16)*7)+16
			
		 circ(x,y,i*s,i)
	 end		
	end
end

function dycp()
	xoff=xoff-1
	x=xoff
 str="meow? meow! meow meow meow meow!!!"
 len=string.len(str)
 s=4
 for i=1,len do
 	y=(math.sin((t/8)+(i/5))*32)+68
  for j=0,1 do
 	 print(string.sub(str,i,i),(x+(i*(s*6)))-(j*3),y-(j*3),j*12,true,s)
 	end
 end
end

function moire()
s1=(math.sin(t/8.1)*32)+120
c1=(math.cos(t/7.3)*32)+68
s2=(math.sin(t/5.4)*32)+120
c2=(math.cos(t/4.9)*32)+68

s=8
for i=0,64 do
	for j=1,s/2 do
		circb(s1,c1,j+(i*s),8)
		circb(s2,c2,j+(i*s),9)
	end
end
end

function kefrens()
--they're KEFRENS bars :P
--(photon don't @ me)
for y=42,120 do
	for j=0,5 do
		x=(math.sin(t/12+(y/12))*(y/16)*8)+120
	 line(x+j,y,x+j,136,1+j)
	end
end
end