mPi=math.pi
mRandom=math.random
mSqrt=math.sqrt
mSin=math.sin
mCos=math.cos
mAbs=math.abs
mAtan=math.atan
mFloor=math.floor
function mLerp(a,b,v)
 return a+(b-a)*v
end
function mClamp(a,min,max)
 if a<min then return min end
 if a>max then return max end
 return a
end
function cheapAssBloom(limit,size,color)
 local i=0
 for y=2,131+2,6 do
 for x=2,239+2,6 do
  if charBuffer[i]>limit then
      circ(x,y,size,color)
           end
       i=i+1
  end
 end
end
   
-- charset magic
charSetSrc="  `'->|=:{;!*x@XKq2#W"
charSet={}
for i=0,#charSetSrc-1 do
 charSet[i]=string.sub(charSetSrc,i+1,i+1)
end
charSetMod=#charSetSrc-1
   
-- palette
for i=0,15 do
 local v=(i/15)^1.3
 poke(0x3fc0+i*3+1,mClamp(mLerp(0,455,v),0,255))
 poke(0x3fc0+i*3+0,mClamp(mLerp(0,205,v),0,255))
 poke(0x3fc0+i*3+2,mClamp(mLerp(0,105,v),0,255))
end
   
function TIC()
 cls(0)
   
 -- textmode fx
 local t=time()/1000
 math.randomseed(t/10)
 local arcs=mRandom(1,10)
   local offX=mSin(5.451+t*0.82)*20+mSin(7.413+t*0.31)*20
   local offY=mSin(8.953+t*0.99)*20+mSin(5.483+t*0.58)*20
 local rot=mSin(2.321+t*0.32)*5
 local travel=-t
 local twist=mSin(4.123+t*0.51)*.02
 local bright=mSin(1.453+t*0.52)*.25+.25
 for y=0,136,6 do
  local dy=136/2-y+offY
  for x=0,239,6 do
   local dx=239/2-x+offX
   local dist=mSqrt(dx*dx+dy*dy)
   local ang=mAtan(dx,dy)+rot+dist*twist
   local v=mSin(ang*arcs)
   v=v*mSin(dist*.025+travel)
   v=v+bright
   v=mClamp(v,0,1)^2
   v=mFloor(v*charSetMod)
   print(charSet[v],x,y,1,true)
  end
end
   
 -- greets text
 rect(3*6,3*6,13*6,3*6,0)
 print("Textmode <3",4*6,4*6,1,true)
   
 -- capture tet
    screenBuffer={}
 for i=0,136*240 do
  screenBuffer[i]=peek4(i)
 end
   
 -- blurred cells
 charBuffer={}
 local i=0
 for y=0,136,6 do
  for x=0,239,6 do
   local v=0
   for cy=y,y+5 do
    for cx=x,x+5 do
     v=v+pix(cx,cy)
    end
   end
   charBuffer[i]=v
   i=i+1
  end
 end
   
 -- cheap-ass bloom
 cheapAssBloom(3,20,1) 
 cheapAssBloom(5,10,2) 
 cheapAssBloom(10,5,3) 
 cheapAssBloom(12,3,4) 
 cheapAssBloom(14,2,5) 

 -- elements assemble! 
 math.randomseed(time())
 local i=0
 for y=0,135,2 do
  local cy=mSin(y/135*mPi)^.4
  for x=0,239 do
   local cx=mSin(x/239*mPi)^.4
   local v=screenBuffer[i]*8
   v=v+peek4(i)+mRandom()*2
   pix(x,y,v*cx*cy)
   i=i+1
  end
  y=y+1
  for x=0,239 do
   local cx=mSin(x/239*mPi)^.4
   local v=screenBuffer[i]*8
   v=v+peek4(i)+mRandom()*2
   pix(x,y,v*cx*cy*.8)
   i=i+1
  end
 end
end
--lastT=0
--function OVR()
 --local newT=time()
 --print(1000/(newT-lastT),202,1,12)
 --lastT=newT
--end
