--no pink in default palette ouhg,,
poke(0x3fc3,255)
poke(0x3fc4,200)
poke(0x3fc5,255)

cols={10,1,12,1,10}
function TIC()
 cls()
 for i=1,5 do
  rect(0,26*i-26,240,26,cols[i])
 end
 for i=-1,1 do
  for j=-1,1 do
    print("enfys was here",36+i,60+j,15,true,2)
  end
 end
 print("enfys was here",36,60,12,true,2)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>