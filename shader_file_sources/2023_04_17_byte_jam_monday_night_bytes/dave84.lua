--dave84
--Greetings everyone!
b={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
angle=0
cls(0)
s=math.sin
c=math.cos
for j=0,47 do
 poke(16320+j,j%3*5*j)
end
function TIC()

for j=0,47 do
 poke(16320+j,j%3*(fft(2))*100*j)
end
for x=1,20 do
 b[x]=b[x]+fft(x-1)
 circ(120+s(x+angle)*b[x]*10,68+c(x+angle)*b[x]*10,s(t)*10*fft(3),t)
 if(b[x] > 10) then  b[x] = 0 end
 for x=0,20 do
  pix(math.random(0,239),math.random(0,136),0)
 end
end

t=t+0.5
angle=angle+0.1
end
t=0