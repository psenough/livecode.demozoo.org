-- superogue 
-- bytejam 12/12/2022
f={}t=1vol=199T={"beautiful","   we","   are ","   all"}
function fft(i)return math.random()*math.sin(i*5)*.1 end
function TIC()
cls(0)
s=math.sin(t/19)c=math.cos(t/17)
for i=1,8*64 do f[i]=f[i+8]or 0 end
for i=1,8 do f[64*8+i]=vol*fft(i)end
for y=-63,63 do for x=-63,63 do
   X=x*c-y*s Y=x*s+y*c
   ff=f[(y%64)*8+(x//4%8)+1]
   zs=math.sin(ff)*4
   if (zs>1) then zs=1 end
   if (zs<0) then zs=0 end
   h=(x&y)*zs*ff/8
   z=ff*(math.sin(t/39)+1)
   r=(z+4)/8
   q=z//8
   circ(X*z+120,Y*z/2-h+80,r,(q%13)+8)
end end
for i=0,240,2 do line(0,i,240,i,0)end
ti=(t+f[3]/2)y=64+fft(0)*99
print(T[(ti//4)%4+1],86,y+2,0,1,2,1)
print(T[(ti//4)%4+1],84,y,12+(fft(0)*256)%4,1,2,1)
print("Superogue 2022",92,128,13,1,1,1)
t=t+math.sin((fft(1)+fft(0))*9)
end