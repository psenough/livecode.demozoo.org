m=math
s=m.sin
c=m.cos
C=circ
Z=120
function TIC()t=time()/100
cls()r=t/4
for a=0,6.2,.3 do
for b=0,6.2,.3 do
C(Z-32*(b+2)/4*(a-3),80+b*4+8*s(a+t),2,9)
x=60*s(a)*s(r+b)z=30*c(a)y=10*s(t)
C(Z+x,65+z+y,2,4)
C(Z+60*s(r)+x/3,45+z/3+y,2,4)
end end end