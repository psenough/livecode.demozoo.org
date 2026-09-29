m=math
function TIC()t=time()
for sy=0,135 do for sx=0,239 do
a=4*m.sin(t/2000)
sx1=sx-120+30*m.sin(t/634)
sy1=sy-68+30*m.sin(t/876)
scale=16+8*m.sin(t/555)
tx=(sx1*m.cos(a)+sy1*m.sin(a))/scale
ty=(sy1*m.cos(a)-sx1*m.sin(a))/scale
y=ty/(m.sqrt(3)/2)
x=tx-ty
-- screw it, let's jam with this thing
q=(1-x%1>(y%1))
ix=x//1
iy=y//1
pal=t//5000
if q then
 pix(sx,sy,((ix%3)+pal)%16)
end
end end end
