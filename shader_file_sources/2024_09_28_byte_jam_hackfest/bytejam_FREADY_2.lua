-- F#READY
-- second try
-- scan text pixels and draw as circles
-- prepared code
-- byte jam, hackfest 2024

cls()
print("HACK",0,0,1)
print("FEST",0,8,1)
tab={}
w=0
for y=0,15 do
  for x=0,31 do
    c=pix(x,y)
    if (c>0) then
      table.insert(tab,{x,y})
			 end
		end
end
cls()

function TIC()
  cls()
	 t=time()/300
  i=1
  for k,v in pairs(tab) do
    x=v[1] y=v[2]
    s=math.sin(t+i/50)*8
    circ(10+x*10,8+y*10,s,1)
    i=i+1
  end
  w=w+1
end

function pal(i,r,g,b)
		poke(0x3fc0+(i*3),r)
		poke(0x3fc0+(i*3)+1,g)
		poke(0x3fc0+(i*3)+2,b)
end

function SCN(l)
  c=l*1.5
  pal(1,192,c,w)
  pal(0,l/2,l/2,l/2)
end
