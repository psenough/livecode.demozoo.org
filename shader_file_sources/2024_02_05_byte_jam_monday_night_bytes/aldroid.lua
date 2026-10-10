-- aldroid here!
-- glhf everyone :)

-- no plan as usual, no brain cells

-- this is a total experiment, i'm
-- nervous doing it live but you'll
-- support me i'm sure :)

cls()
S=math.sin

function SCN(l)
blif = fft(35)*2000/(l/20+4+S(t)*2)
for i=0,15 do

poke(0x3fc0+i*3,math.max(i*240/15-blif,0))
poke(0x3fc1+i*3,math.max(i*240/15-blif,0))
poke(0x3fc2+i*3,math.min(i*240/15+blif,255))
end
end


worbs = {
"YOU",
"WOULD",
"LOVE",
"A",
"BYTE"
}

function TIC()
t=time()/100
worb = worbs[1+t//10%#worbs]
print(worb,20+math.sin(t)*2,30,fft(5)*200,false,8)


for y=0,135 do 
ox = math.max(0,S(t/200+y/100)*2)*2

for x=0,239 do
outerval = 0
outzone = 9+4*S(t*0.81)
inzone = 5+3*S(t*0.782)
for i=-outzone,outzone,5.5+S(t+x) do for j=-outzone,outzone,4.5+S(t+y) do
outerval = outerval + pix(x+ox+i,y+j)
end end

innerval = 0
for i=-inzone,inzone,5.5+S(t+x) do for j=-inzone,inzone,5.5+S(t+y) do
innerval = innerval + pix(x+ox+i,y+j)
end end

pv = math.max((outerval-innerval)/(26-fft(1)*44),0)

pix(x,y,pv)

end end
if fft(5)*200>14 then
print(worb,20+math.sin(t)*2,30,0,false,8)
end
end
