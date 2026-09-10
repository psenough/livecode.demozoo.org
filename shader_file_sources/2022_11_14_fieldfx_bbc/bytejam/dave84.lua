l="FIELD-FX MONDAY NIGHT BYTES!"
function TIC()
t=time()/999
cls()
print(l,6-t*70,45+40*s(t),1,false,10)
for x=0,240 do
 for y=0,136 do
  cl=(s((x+t*20)/50)+s((y+t)/50))*s(t)*16
  if pix(x,y)~= 0 and y%2==0 then
    pix(x,y,(cl+(x~y)/10)//1&11)
  else
    pix(x,y,0)
  end
 end
end
end
s=math.sin
-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

