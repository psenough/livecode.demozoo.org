function SCN(l)
vbank(0)
mg=l/135
mg=mg^2
for c1=0,3 do
 o = 40
 for c2=0,3 do
  c=o+c1+c2*40
  c = c* mg
  poke(0x3fc0+c1*4*3+c2*3,c)
  poke(0x3fc1+c1*4*3+c2*3,c)
  poke(0x3fc2+c1*4*3+c2*3,c)
 end
end
end

function r(x,y,a)
 ca=C(a)
 sa=S(a)
 return (x*ca-y*sa),(y*ca+x*sa)
end

function pt(x,y,z)
 tr=time()/500
 dst=8
 scl=400
 x=x-5
 y=y+2
 x,z=r(x,z,0.15+S(tr/13)*0.04)
 y,z=r(y,z,0.5)
 z = z + C(tr/7)
 X=x*scl/(dst+z)
 Y=y*scl/(dst+z)
 return 120+X,68+Y
end