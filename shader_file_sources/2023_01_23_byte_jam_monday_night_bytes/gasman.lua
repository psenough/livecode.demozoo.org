-- g'day folks! gasman here...
-- greetings to Kii, Nico, Synaesthesia
-- and Aldroid!!!

-- no grand plan tonight, except
-- "use FFT", because I have a TIC-80
-- build with it, like all the cool
-- kids :-D
-- (thanks Kii for the device select
-- patch!)

-- oh good, the amplitude on the stream
-- is about the same as locally.
-- that's helpful.

frm=0
buckets={}
for z=0,31 do
 buckets[z]={}
 for i=0,15 do
  buckets[z][i]=0
 end
end

stars={}
for s=0,50 do
-- if i'm really quick nobody will
-- notice that I'm looking up
-- the lua docs for math.random lol
-- ok, range from 0..1 hopefully
 stars[s]={
  math.random(),math.random(),math.random()}
end

function TIC()
cls()
buckets[frm]={}
for i=0,15 do
 buckets[frm][i]=0
end
for i=0,255 do
 b=(math.sqrt(i/239)*15)//1
 buckets[frm][b]=buckets[frm][b]+fft(i)
end

a=8*math.sin(time()/4000)

-- if in doubt, add a starfield.
-- but do it before the other stuff
for s=0,50 do
 star=stars[s]
 sz=(star[3]-time()/1000)%1
 zout=1+2*math.cos(a)*(sz-0.5)+math.sin(a)*(star[1]-0.5)
 circ(
  120+240*(math.cos(a)*(star[1]-0.5)+math.sin(a)*(sz-0.5)),
  65+60*(math.cos(a)*(sz-0.5)-math.sin(a)*(star[1]-0.5))+120*(star[2]-0.5),
  1,
  12+zout
 )
end


-- how about some isometric stuff
-- naah, let's go for proper 3D
-- this really needs to scroll
-- as it goes...
-- let's make this symmetrical
-- since it's all a bit bass-heavy
for z=0,31 do
 for x=0,15 do
  y=buckets[(z+frm)%32][x]*8
  sx=120+8*x*math.cos(a)+8*(z-16)*math.sin(a)
  sy=88+2*(z-16)*math.cos(a)-2*x*math.sin(a)-y*4
  circ(sx,sy,4,y+1)
  sx=120+8*-x*math.cos(a)+8*(z-16)*math.sin(a)
  sy=88+2*(z-16)*math.cos(a)-2*-x*math.sin(a)-y*4
  circ(sx,sy,4,y+1)
 end
end
-- that's probably about it for the
-- ground plane thingy
-- so how about... a flying thing?
-- hmm
z=-4
x=0
yb=math.sin(time()/200)*4
y=yb+5 + buckets[frm][0]*4
yc=20*math.sin(time()/500)
sx1=120+8*z*math.sin(a)
sy1=48+2*z*math.cos(a)+yc
z=4
sx2=120+8*z*math.sin(a)
sy2=48+2*z*math.cos(a)+yc
z=-8
x=6
sx3=120+8*z*math.sin(a)+8*x*math.cos(a)
sy3=48+2*z*math.cos(a)-2*x*math.sin(a)-y*4+yc
x=-6
sx4=120+8*z*math.sin(a)+8*x*math.cos(a)
sy4=48+2*z*math.cos(a)-2*x*math.sin(a)-y*4+yc
clr=12-buckets[frm][0]*8
trib(sx1,sy1,sx2,sy2,sx3,sy3,clr)
trib(sx1,sy1+1,sx2,sy2+1,sx3,sy3+1,clr)
trib(sx1,sy1,sx2,sy2,sx4,sy4,clr)
trib(sx1,sy1+1,sx2,sy2+1,sx4,sy4+1,clr)
trib(sx1,sy1+10,sx2,sy2,sx3,sy3,clr)
trib(sx1,sy1+11,sx2,sy2+1,sx3,sy3+1,clr)
trib(sx1,sy1+10,sx2,sy2,sx4,sy4,clr)
trib(sx1,sy1+11,sx2,sy2+1,sx4,sy4+1,clr)

frm=(frm+1)%32

end
