t=0
function SCN(scnln)
 poke(0x3ff9,math.random()*4+math.sin(scnln/17+t/16)%4)
end

function TIC()
 --cls()
 poke(0x3ffb,0)
 t=t+1
 for i=0,10000 do
  pix(math.random()*240,math.random()*136,17-math.random()*2)
 end
 for i=-34,34 do
  --circ(120,68+i,5,12)
  circ(120+i,68+i/2,5,12)
  --circ(120+i,68-i/2,5,12)
 end
 for i=-34,0 do
  circ(120+i,68-i/2,5,12)
 end
 for i=-34,-17 do
  circ(120,68-i,5,12)
  circ(120,17-i,5,12)
  circ(117-i,68+i/2,5,12)
 end
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>