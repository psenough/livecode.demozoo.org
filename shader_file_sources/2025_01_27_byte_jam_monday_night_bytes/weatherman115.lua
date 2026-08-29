t=0S=math.sin
A=table.insert
function SCN(l)for i=24,47 do
poke(16320+i,60+(255&(i*i-l)//1)/1.5)end
j=(l+8)//16Z=(((4.36+(t+l)//16+j)^5.2)%256)-16line(Z,l,Z+15,l,8+(j+x)%8)end
function TIC()for i=0,4e4 do
x=i%240
y=i//240pix(x,y,1+((x+t+8*S(y/6+t/16))//16+(136-y-16*ffts(x*4,x*4+1))//16)%4)end
vbank(1)cls()for Z=0,5 do
P={}for n=0,5 do
r=n//2*2.1+t/24p=(5*(1+S(n*4+t/99+Z)))*(S(r-11)+S(r)*(-1)^n)+(n&1<1 and 60*S(t/99-11+Z)or 68+60*S(t/99+Z))A(P,p)end
A(P,12)tri(table.unpack(P))end
vbank(0)t=t+ffts(1,16)/2
end
-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

