-- aldroid here!
-- glhf to tobach + nico, catnip,
-- jtruk and bigups to polynomial
-- thanks again to violet hosting!

-- no plan, only jam

S=math.sin
C=math.cos
mags = {}
for i=0,255 do
mags[i]=0
end
t=0

words={
"eat",
"sleep",
"rave",
"rept",
"drum",
"bass",
"jungl",
"fear"
}

sewo={}
for i=0,3 do
sewo[i]={12,i+1}
end

function wore(x,y,i)
clip(x,y,x+120,y+68)
if sewo[i][1]<0 then
  sewo[i][2]=math.random(1,#words)
  sewo[i][1]=10+math.random()*4
end
print(words[sewo[i][2]],x+5,y+10,15,false,4)
sewo[i][1]=sewo[i][1]-0.1
end

blop=0

-- to / from
function rectl(x1,y1,x2,y2,x3,y3)
 dy = y1-y3
 for y=y1,y2 do
  memcpy(x1//2+y*120,0x4000+x3//2+(y-dy)*120,(x2-x1)//2)
 end
end



function TIC()
 cls()
 
 wore(0,0,0)
 wore(120,0,1)
 wore(0,68,2)
 wore(120,68,3)
 clip()
 
 for i=0,240,24 do 
 rectl((t+i)%240,10,(t+i)%240+10,126,((t+i)+50+t*0.2)%240,10)
 end
 r=40
 if blop > 0 then
   circ(120,68,r-5,15-blop)
   blop = blop - 0.03/fft(1)
   clip(0,t%136,240,(t+10)%136)
   circ(120,68,r-5,0)
   
 end
 clip()
 if (fft(5)>0.04) then blop=4 end
 
 t=t+fft(1)*10
 ti=t//1%256
 tf=t%1
 for i=0,255 do
   mags[i]= mags[(i+ti+256)%256]*0.6 + fft((i-ti)%256)*(1+i)/255
 end
 for ic=0,255 do
  i=(ic+t*2)%256//1
  for j=1,5 do
  x1=C(i*2*math.pi/255)*(1+mags[i]*(20-4*j))
  y1=S(i*2*math.pi/255)*(1+mags[i]*(20-4*j))
  x2=C((i+1)*2*math.pi/255)*(1+mags[(i+1)%256]*(20-4*j))
  y2=S((i+1)*2*math.pi/255)*(1+mags[(i+1)%256]*(20-4*j))
  line(120+x1*r,68+y1*r,120+x2*r,68+y2*r,3+j)
  end
 end
 if t%10 < 1 then
 memcpy(0x4000,0,120*136)
 end
end
