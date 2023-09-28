mAbs=math.abs
mSqrt=math.sqrt
mClamp=function(a,min,max)
 if a<min then
  return min
 elseif a>max then
  return max
 else
  return a
 end
end
mRandom=math.random
mFRandom=function(min,max)
 return min+mRandom()*(max-min)
end
mLerp=function(a,min,max)
 return min+a*(max-min)
end
mSin=math.sin
mCos=math.cos
mPi=math.pi
mTwoPi=mPi*2

startTime=tstamp()
function TIC()
 local bpm=180
 local t=time()/1000*bpm/60
 local ta=t%1
 local tm=t//1
 math.randomseed(startTime+tm)
 math.randomseed(mRandom()*12345)

 local numHubs=mRandom(3,10)
 local numSpokes=mRandom(8,15)
 local minD=mFRandom(-40,10)
 local maxD=mFRandom(100,180)
 local minSize=mRandom(1,10)
 local maxSize=mRandom(1,10)
 local minTwist=mFRandom(-5,.5)
 local maxTwist=mFRandom(-5,.5)

 dots={}
 local angleBase=mSin(2.32+0.75*t)+mSin(3.19+0.26*t)
 for hub=1,numHubs do
  local hubA=(hub-1)/(numHubs-1)
	 local d=mLerp(hubA,minD,maxD)
		local size=mLerp(hubA,minSize,maxSize)
		local twist=mLerp(hubA,minTwist,maxTwist)
	 for spoke=1,numSpokes do
	  local spokeA=spoke/numSpokes
	  local angle=angleBase+twist+mTwoPi*spokeA
	  local x=mSin(angle)*d
	  local y=mCos(angle)*d
			dots[#dots+1]={x,y,size}
	 end
 end

 local maxSizeMod=mFRandom(0,2)
 local maxOfs=mFRandom(-2,2)

 cls(0)
 local cx=120+mSin(5.32+0.34*t)*10+mSin(8.23+0.61*t)*10
 local cy=68+mSin(5.42+0.52*t)*10+mSin(7.41+0.39*t)*10
 for i=0,15 do
  local iA=i/15
  local ofs=iA*maxOfs
  local sizeMod=(15-i)*maxSizeMod
	 for _,dot in ipairs(dots) do
	  local x=dot[1]
	  local y=dot[2]
	  local size=dot[3]
		 circ(cx+x+x*ofs,cy+y+y*ofs,size+sizeMod,i)
	 end
 end

 local r0=mLerp(mSin(3.21+0.32*t)*.5+.5,-5,5)
 local r1=mLerp(mSin(5.42-0.53*t)*.5+.5,12,25)
 local g0=mLerp(mSin(3.90+0.65*t)*.5+.5,-5,0)
 local g1=mLerp(mSin(5.43-0.71*t)*.5+.5,7,15)
 local b0=mLerp(mSin(4.03+0.86*t)*.5+.5,-2,2)
 local b1=mLerp(mSin(1.90-0.74*t)*.5+.5,10,16)
 for i=0,15 do
  local iA=i/15
  poke(0x3fc0+i*3+0,mClamp(mLerp(iA,r0,r1),0,15)*16)
  poke(0x3fc0+i*3+1,mClamp(mLerp(iA,g0,g1),0,15)*16)
  poke(0x3fc0+i*3+2,mClamp(mLerp(iA,b0,b1),0,15)*16)
 end

 local buf={}
 for i=0,136*240 do
  buf[i]=peek4(i)
 end


 local xReflect=mRandom()>.5
 local yReflect=mRandom()>.5
 local brightMod=(1-ta)^3*10
 local fish=mLerp(ta^.2,5,.1)
 for y=0,135 do
  local cy=y-68
  --if yReflect and cy>=0 then cy=-cy end
  if yReflect then cy=mAbs(cy) end
  local dy=cy^2
  for x=0,239 do
	  --if xReflect and cx>=0 then cx=-cx end
	  if xReflect then cx=mAbs(cx) end
   local cx=x-120
   local dx=cx^2
   local d=mSqrt(dx+dy)+0.00001
   local nx=dx/d
   local ny=dy/d
   local dist=(d/140)^fish
   local sx=120+cx*dist
   local sy=68+cy*dist
   local dc=(1-d/140)^.5
   local c=buf[sx//1+sy//1*240]
   c=c*dc
   c=c+mRandom()*1
   c=c+brightMod
   pix(x,y,mClamp(c,0,15))
  end
 end

 if t<16 then
	 if ta<.25 then
		 local txts={'YOU','KNOW','THE','SCORE'}
		 for i,txt in ipairs(txts) do
		  local y=-5+i*25
			 local w=print(txt,-500,500,0,false,4)
		 	print(txt,120-w/2,y,0,false,4)
		 end
		end
	end
end