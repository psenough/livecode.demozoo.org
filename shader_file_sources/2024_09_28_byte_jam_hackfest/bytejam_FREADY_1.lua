-- F#READY, first try
-- plasma variant
-- byte jam, hackfest 2024

t=0
m=math
s=m.sin
function TIC()
  cls()
		for x=0,239 do
		  for y=0,135 do
				  k=t/50
				  c=s(k+x/20)+s(k+y/15)+s(x/30)
				  pix(x,y,(c*3//1)&3)
				end
		end
		

  t=t+1

		f=t//5
		p=10*m.sin(t/50)

  print("HACK",30,20+p,15,true,8)
  print("FEST",30,70+p,15,true,8)

end

function OVR()
end

function pal(i,r,g,b)
		poke(0x3fc0+(i*3),r)
		poke(0x3fc0+(i*3)+1,g)
		poke(0x3fc0+(i*3)+2,b)
end

function SCN(l)
  c=l*8
  pal(15,c,c,c)
end