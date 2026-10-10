-- F#READY
-- tryout day #5 and live coded
-- byte jam, hackfest 2024

N=10
bobs={}
m=math
r=m.random
for i=1,N do
  table.insert(
  bobs,{r(240),r(136),r(-3,3),r(-3,3)})
end

function TIC()
cls()
print("HACK",30,20,1,true,8)
print("FEST",30,70,2,true,8)
for i=1,N do
  b=bobs[i]
  circ(b[1],b[2],3,9)
  b[1]=b[1]+b[3]
  b[2]=b[2]+b[4]
  b[1]=b[1]%240
  b[2]=b[2]%135
  
  for k=1,N do
    if k~=i then
      p=bobs[k]
      dx=b[1]-p[1]
      dy=b[2]-p[2]
      d=m.sqrt(dx*dx+dy*dy)
      if d<30 then
        line(b[1],b[2],p[1],p[2],4)
      end
    end
  end
end
end
