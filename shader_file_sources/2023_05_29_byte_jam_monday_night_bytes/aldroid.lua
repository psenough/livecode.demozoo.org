for i=0,45,3 do
poke(0x3fc0+i,i*16)
if i < 13 then 
poke(0x3fc1+i,i*16)
end
poke(0x3fc2+i,i*16)
end

function TIC()t=time()//32
print("beep",10+math.sin(time()/200)*10,20,8,8,8)
print("boop",60,80-fft(1)*30,8,8,8)
dx = math.sin(time()/1000)
dy = math.sin(time()/631)
for y=0,136,2 do for x=0,240,2 do
px=x+t//2%2
py=y+t//4%2
if math.pow(y-68+dy*68,2)+math.pow(x-120+dx*120,2) < 1500 then 
pix(px,py,(x-t|y)+t>>3)
else
if py < 50 and math.random() > 0.95 then
 pix(px,py,15)
else
pix(px,py,pix(x+math.random()*1.04,y-2)/1+y/160)
end
end
end end end
