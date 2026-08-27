t=0W=120z=16R=math.random
S=math.sin
cls()memcpy(24576,16320,48)function TIC()if R()<.3then
x=R()*256-z
y=R()*152-z
rect(x,y,z,z,R()*3)print('*',x,y,9)end
vbank(1)if R()<.1then cls()end
for i=0,9 do
F=fft(i*z,i*z+15)x=50*S(i+t/9-11-F)*S(i-F/9)+50*S(i*t/99)+W
y=50*S(i+t/9+F)+68line(x,y,W,68,i)circ(x,y,7,i+3)Z=print('bitrate',x-19,y,i)end
vbank(0)t=t+1
end
function SCN(l)
for i=0,47 do
poke(16320+i,(t+i+l*S(l/8)//1)~(peek(24576+i)+(ffts(l+i)*256))//1)end
if R()<.01then L=R()*8-4memcpy(l*W+L,l*W,W-L)end
end