-- mt here
-- gonna just tune it a bit now

cls(0)

osize=10

bt=0
function TIC()t=time()/300
ta=5*math.sin(t/10)
tb=5*math.sin(t/10+math.pi*2/3)
tc=5*math.sin(t/10+math.pi*4/3)
for i=0,15 do
poke(0x3fc0+i*3,i*(10+ta))
poke(0x3fc0+i*3+1,i*(10+tb))
poke(0x3fc0+i*3+2,i*(10+tc))
end

rect(0,0,240,10,0)

size=osize+10*(fft(0)+fft(1)+fft(2)+fft(3)+fft(4))
circ(120,68,size,0)

bt=bt + .5*(fft(0)+fft(1)+fft(2)+fft(3)+fft(4))

for i=0,127 do
 ft=fft(i*2+1)+fft(i*2+2)
 ft=ft*2000*(i/127 + 0.25)
 
 a=i/127*math.pi*2+bt
 
 x=(size)*math.sin(a)
 y=(size)*math.cos(a)
 
 pix(120+x,68+y,math.min(ft,15))
-- line(120,68,120+i,10,math.min(ft,14)+1)
-- line(120-i,10-ft/2,120-i,10,math.min(ft,14)+1)
end

for i=0,1000 do
d=size+math.random(100)
a=math.random()*math.pi*2
x=d*math.sin(a)
y=d*math.cos(a)
pix(120+(d+1)*math.sin(a),68+(d+1)*math.cos(a),pix(120+x,68+y))
end

for i=0,1000 do
d=size+math.random(100)
a=math.random()*math.pi*2
x=120+d*math.sin(a)
y=68+d*math.cos(a)
pix(120+(d+1)*math.sin(a),68+(d+1)*math.cos(a),math.min(15,math.max(0,(pix(x,y)+pix(x+1,y+1)+pix(x+1,y-1)+pix(x-1,y+1)+pix(x-1,y-1))/4.45)))
end

tp=t%60
if tp < 5 then
print("monday",84,100,4,true,2,false)
elseif tp <25 then
elseif tp <30 then
print("night",94,110,8,true,2,false)
elseif tp <45 then
elseif tp <50 then
print("casual",84,120,12,true,2,false)
end
--getting confused here, 
--trying something that worked
end