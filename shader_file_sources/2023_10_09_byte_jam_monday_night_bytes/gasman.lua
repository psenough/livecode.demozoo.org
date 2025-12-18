-- hello from gasman!
--               ^
-- greetings to ToBach, Suule, Alia
-- and Aldroid!

-- will fft effects work with fantasy
-- console audio? only one way to find
-- out!!!

-- the classic out-of-ideas scanline
-- fade

function BDR(y)
 poke(16320,y/4.5)
 poke(16321,y/3.5)
 poke(16322,y/2)
end

map={}
fftpoints={}
for i=0,255 do
 fftpoints[i]={
  math.random(0,63), --x
  math.random(0,63), --y
  math.random(30,100)/300, --speed
  math.random(0,100)*math.pi/50, --angle
  math.random(-50,50)/5000, --angle change
 }
end

-- oh joy, a random crash
-- ..that isn't happening now

for i=0,0xffff do
 map[i]=0
end

function iter()
 newmap={}
 for y=0,63 do
  for x=0,63 do
   newmap[(y<<6)+x]=(
    map[((y+63&63)<<6)+x]+
    map[(y<<6)+(x+63&63)]-
    2*map[(y<<6)+x]+
    map[(y<<6)+(x+1&63)]+
    map[((y+1&63)<<6)+x]
   )/6.001
  end
 end
 map=newmap
end

function TIC()
 cls()


 iter()
 iter()
 for i=0,64 do
  coords=fftpoints[i]
  coords[1]=(coords[1]+coords[3]*math.cos(coords[4]))%64
  coords[2]=(coords[2]+coords[3]*math.sin(coords[4]))%64
  coords[4]=coords[4]+coords[5]
  ix=(coords[1]//1<<6)+coords[2]//1
  map[ix]=map[ix]+fft(i)*20*(i+1)
 end 
 iter()
 iter()
 
 a=time()/3456

 -- finally!!!!
 for z=0,63 do
  for x=0,63 do
   tz=z-32
   tx=x-32
   tz1=tz*math.cos(a)+tx*math.sin(a)
   tx1=tx*math.cos(a)-tz*math.sin(a)
   mapz=(tz1+32)/64*10
   mapx=tx1/32*10
   scale=2/(mapz+0.05)
   if scale>0 then
    sy=50+scale*30
    sx=120+(mapx*10)*scale
    height=map[(z<<6)+x]
    sy=sy-height
    if tz1<0 then
     circ(sx,sy,1,(height*4)+1)
    else
     pix(sx,sy,(height*4)+1)
    end
   end
  end
 end
end
