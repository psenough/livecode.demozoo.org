-- hello from gasman!
-- greetings to my fellow jammers
-- catnip, pumpuli, enfys and g33kou!
-- and also to raccoonviolet and
-- dj stormcaller and the rest of the
-- inercia posse

-- alrighty, tonight I'm going to
-- try and get ttri to work, since
-- I've never done that before

for y=0,64 do
 for x=0,64 do
  poke4(0x4000*2+y*8+x,x~y)
 end
end

strings={
 "joooooin","tiiiiiny","cooooode","xmaaaaas!"
}

function TIC()
 cls()
 t=time()
 r4=t/2345

 for y=0,137 do
  for x=0,239 do
   sx=x*math.cos(r4)+y*math.sin(r4)
   sy=y*math.cos(r4)-x*math.sin(r4)
   pix(x,y,
    ((
     ((sx/8+40*math.sin(t/3234))//1)
     ~((sy/8+40*math.sin(t/3345))//1)
    )&3)+12
   )
  end
 end
 ffty=40+200*fft(0)

 r1=t/534
 r2=t/634
 
 r3=t/734
 
 cx=180
 cy=60
 
 tetra(r1,r2,cx+50*math.sin(r3),cy+50*math.cos(r3),50)
 tetra(r1,r2+1,cx+50*math.sin(r3+math.pi*2/3),cy+50*math.cos(r3+math.pi*4/3),50)
 tetra(r1,r2+2,cx+50*math.sin(r3+math.pi*4/3),cy+50*math.cos(r3+math.pi*4/3),50)

 str=strings[
  ((t//2000)%4)+1
 ]

 print(str,16,ffty+2,1,true,4)
 print(str,14,ffty,4,true,4)
 
end

function tetra(r1,r2,cx,cy,s)
 v0={
  {
   math.sin(r1),
   math.cos(r1),
   0
  },
  {
   math.sin(r1+math.pi*2/3),
   math.cos(r1+math.pi*2/3),
   0
  },
  {
   math.sin(r1+math.pi*4/3),
   math.cos(r1+math.pi*4/3),
   0
  },
  {
   0,
   0,
   1
  }
 }
 v={}
 for i=1,4 do
  v[i]={
   v0[i][1]*math.cos(r2)+v0[i][3]*math.sin(r2),
   v0[i][2],
   v0[i][3]*math.cos(r2)-v0[i][1]*math.sin(r2)
  }
 end

 -- maybe these have to be the same
 -- orientation...?
 face(1,2,3,cx,cy,s)
 face(1,4,2,cx,cy,s)
 face(1,3,4,cx,cy,s)
 face(3,2,4,cx,cy,s)
 -- nah, it's just fecked
end

function face(a,b,c,cx,cy,s)
 ttri(
  cx+s*v[a][1],cy+s*v[a][2],
  cx+s*v[b][1],cy+s*v[b][2],
  cx+s*v[c][1],cy+s*v[c][2],
  0,0,8,0,0,8,
  0,-1,
  v[a][3],v[b][3],v[c][3]
 )
end
