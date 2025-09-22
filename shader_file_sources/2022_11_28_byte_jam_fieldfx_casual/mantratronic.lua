-- mt here, 
--  no idea what i'm doing this tim
-- big ups to hoff, aldroid, visy,
--  truck, tobach
m=math
s=m.sin
c=m.cos
col={1,2,3,4,12,11,10,9,8}

function clamp(x,e1,e2)
return m.max(e1,m.min(x,e1))
end
cls()
function TIC()t=time()/32
for y=-4+t%5,136,4 do for x=-4+t%4,240,4 do
xp=x-120
yp=y-68
xc=(xp//16)--+(s(x+t)+1)*4
yc=(yp//16)
d=m.sqrt(xc^2+yc^2)
xy=(xc+yc+t//60)%2*4
mc=1+c(c(xp)/12+s((yp)/13)+t/30)
a=t/30
xr=yp*c(a)-xp*s(a) +120
yr=xp*c(a)+yp*s(a) +68
xe=(xr-120)/((s(t/50)*.5)+1.8)+120
ye=(yr-68)/((c(t/95)+1)*3)+68
pix(xe,ye,col[((d+mc)*4//1)%9+1])
end 

end 

for i=1,30 do
pix(m.random(240)-1,m.random(136)-1,0)
end
mx=t%240
my=3*s(t/10)
cc=(t/10)
elli(230-mx,120+my,10,4,cc)
circ(220-mx,118+my,4,cc)
circ(239-mx,117+my,1,cc)
circ(239-mx,116+my,1,cc)
circ(239-mx,115+my,1,cc)
circ(239-mx,114+my,1,cc)
circ(238-mx,112+my,1,cc)
tri(221-mx,110+my,222-mx,118+my,218-mx,118+my,cc)
line(236-mx,120+my,236-mx+my,126+my,cc)
line(224-mx,120+my,224-mx-my,126+my,cc)
print("meeeeooooow",248-mx,116+my,cc,false,2,false)
end

-- <TILES>
-- 001:1234cba91234cba91234cba91234cba91234cba91234cba91234cba91934cba9
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

