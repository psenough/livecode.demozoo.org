-- superogue here, on 2 now ;-)
-- good luck nusan! 
-- have a nice party! <3
t=0
function TIC()
f=fft(0)+fft(1)
t=t+f*3+.5
P=t//32
for y=0,136 do 
for x=0,240 do
z=math.abs(y-68)+.1
X=((x+y)-120)/z
Y=199/z
-- moving AND pattern ftw! ;-)
c=((X*4-8+t)//1&(X-Y+7)//.5)//1
pix(x,y,P&8+c%4)
end end 
-- what next?
for i=9,0,-1 do
sx=(t-i*24)%240
sy=64+math.sin(i+t/9)*8*fft(2)
f2=fft(2)*4
r=(math.sin(f2+i/4)+1)+sx/7
for s=0,5 do
circ(240-sx-s/2,sy+sx/7-s,r-s*3,-s/1.12)
end
end
end


