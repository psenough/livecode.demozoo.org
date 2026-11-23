-- Superogue @ MCH2022 Bytejam!
-- Theme: Unicorns and/or Lamas
t=0m=math
T={
"May Contain Hackers",
"  May Contain LUA",
" May Contain Demos!",
" May Contain Gasman",
"May Contain Unicorns"
}
function TIC()
for y=0,136 do
for x=0,240 do
sx=x-120sy=y-68
a=m.atan(sx,sy)*8/m.pi
r=199/m.sqrt(sx*sx+sy*sy)+.1
c=a+r+t
pix(x,y,(c+t)%8+8)
end end
-- unicorn, narwall?
ux=120+m.sin(t/5)*16
uy=64+m.sin(t/7)*16
s=32
elli(ux,uy,s,s*.8,0)
b=m.abs(m.sin(t))*4
for i=0,13 do
 elli(ux-16-i,uy+18+i,(s+i)/3,s/3,0)
 elli(ux+16+i,uy+18+i,(s+i)/3,s/3,0)
 elli(ux,uy-20-i*2,9-i,3,i-t)
 circ(ux-16,uy-b,8-i,12)
 circ(ux-16,uy-b,4,0)
 circ(ux+16,uy-b,8-i,12)
 circ(ux+16,uy-b,4,0)
end
p=(t//8)%5
print(T[1+p],5,121,0,2,2)
print(T[1+p],4,120,t,2,2)
t=t+.2
end