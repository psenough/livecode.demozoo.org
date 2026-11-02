cls()
s=math.sin
k=math.random
max=math.max
t=0
t2=0

function mix(a,b,t)
 return a*t+(b*(1-t))
end

function TIC()
 t=t+1
 for i=1,10 do
  t2=t2+fft(i)
 end
 
 vbank(0)
 memcpy(1,0,240*136/2-1)
 for j=0,20 do
  local y=k()*136
  local baseC=7+(j%2)*8 --13/5
  for i=0,2 do
   circ(0,y,4-i,baseC-i)
  end
 end
 
 vbank(1)
 cls()
 for j=0,7 do
  x=(j*40+t*4)%320-30
  y=68-max(0,s(j+t/10))+s((t/16)+j)*15
  for i=1,3 do
   elli(x+i*2,y-i*1.5,30-i*6,20-i*4,i) --1-4
  end
  
  for g=0,7 do
  	for i=1,3 do
  	 circ(
     x-g-2+s(t2/5+g)*g/2,
     y-i*1.5-g*2-15,
     7-(g^0.5)*2,
     7+i) --1-4
  	end
  end
  
  local ex=x+s(j+t/10)*20
  local ey=100-(max(0,s(j+t/10-11))*10)
  local mx=(x+ex)/2
  local my=(y+ey)/2-20
  for i=0,1,0.1 do
   local x=mix(x,mx,i)
   local y=mix(y+7,my,i)
   for f=0,2 do
    circ(x,y,3+i*2-f,2+f)
   end
  end
  for i=0,1,0.1 do
   local x=mix(mx,ex,i)
   local y=mix(my,ey,i)
   for f=0,2 do
    circ(x,y,3+i*2-f,2+f)
   end
  end
 end
end
