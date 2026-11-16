-- superogue at revision 2025
--
-- Sorry my shader showdown entry
-- crashed/didnt come trough properly
-- yesterday :(
--
-- Hope this will make up for it a bit
-- Love you all!
t=0 C=math.cos
function TIC()
t=t+fft(0)*64+1
f=math.random(255) >224 and 1 or 0
pan=math.sin(t/64)+.5
for o=t%2,32639,1.87 do
b=o%240/50-3;
bank=math.sin(t/32+fft(2)*2)*b/4+pan
a=-(o/11600-.5)+bank
z=t/3;k=16
x=0;y=C(z/8)*8;d=k 
while (k>0 and d>.1) do
X=-x%20 Y=y%10-5 Z=z%10-5
d=C((X*X+Y*Y+Z*Z)/(34))
x=x+d*a y=y+d*b
z=z+(d+d)
k=k-1
end
sc=f>0 and 12 or (5-x/1.2%4)
poke4(o,a>0 and -x*2+fft(1)*32 or k/3+x%1+x/3)
end
for i=0,5 do
			sx=(t*4)%400-80
			sy=C(sx)*32+64
  	circ(sx,sy,-i/2,i/2)
end

end
