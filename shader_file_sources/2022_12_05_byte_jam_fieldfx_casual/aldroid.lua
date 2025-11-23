-- pos: 1,55
--aldroid here! love to all the coders

-- let's try writing something with
-- ONLY cls :)

S=math.sin
P=math.pi

function SCN(l)
-- obviously we need to cheat somehow
c=0
t=time()/200
offs = 68 + S(t/2.3) *40
-- i want better colour hmm...
for i=0,3 do
  if S(t + i*P/2) * 20 + offs > l and S(t + (i+1)*P/2) *20 +offs < l then
  c = 20+S(t-(i+1.5)*P/2)*150
  end
end
poke(0x3fc3,c)
end

cova = {}
for i = 0,3*16-1 do
cova[i]=peek(0x3fc0+i)
end


function TIC()
  t=time()/20
  
  if (t//20%20)>10 then
    for i=0,15 do
      poke(0x3fc1+i*3,cova[1+i*3])
      poke(0x3fc2+i*3,cova[2+i*3])
    end
  else
    for i=0,15 do
      c=peek(0x3fc0+i*3)
      poke(0x3fc1+i*3,c)
      poke(0x3fc2+i*3,c)
    end
  end
  
  if (t//10%20) <1 then cls(1) end
  for x = 0,240 do for y = 0,136 do
    if S(x+y) > -0.5 then
    pix(x,y, pix(x,y+5*S(y+x/4+t/40)))
    end
  end end
  for x = 0,4 do for y = 0,3 do
    rect(45+x*30,10+y*30, 20,20,0+(x+y+t//40)%3)
  end end
end
