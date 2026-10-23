-- HEELLLLOOOOOOO

-- Let's have fun !
-- #TeamNoCLS
m=math 
s=m.sin 
c=m.cos
rnd=m.random
function TIC()
t=time()/32
w=240//2
h=136//2
mv=c(t/20+math.sin(t/10))*100+63
rect(0,90,240,30,15)

rect(0+mv,90,110,42,15)
for x=0,.99,.01 do
   x=x*6.28+t
   z=c(x+t*.44)
   tt =t/64
   zz =.13*x*c(t*.1)
   si = 150   
   line(
   w+c(x)*si,
   h+s(x)*si,
   w+c(x+tt+zz)*si,
   h+s(x+tt+zz)*si,
   5+x/2+tt
   )
   end
for x=0,.99,.5 do
x=x*6.28+t//2
a={"mantratronic","totetmatt","tobach","gasman","djh0ffman"}
print(a[1+t//50%5],w-75+rnd(),h*rnd()*15,15-t//2%5,false,3)

end
q={"W","e","l","c","o","m","e"," ","T","o"," ","F","F","X"," ","C","a","s","u","a","l","s"}
for x=22,1,-1 do
xx=23-x
print(q[xx],-15+xx*11,90+c(x+t/30)*5,t/5+5+xx%3,true,3+(t/10+x)%3)

end

print("livecode.demozoo.org",0+mv,120,4)
print("nanogems.demozoo.org",0+mv,125,3)
end

function SCN(l)poke(0x3FF8,l/20+t/100) end