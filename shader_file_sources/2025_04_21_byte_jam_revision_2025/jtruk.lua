local T=0
local M=math
local mPi,mCos,mSin=M.pi,M.cos,M.sin
local mTau=mPi*2
local mRand=M.random
local mMax,mMin=M.max,M.min
local R0,G0,B0=0,0,0
local R1,G1,B1=255,255,255
local R2,G2,B2=255,255,255
local NDOTS
local SPREAD
local SHAPE={}

function shuffle()
 R0=mRand(0,100)
 G0=mRand(0,100)
 B0=mRand(0,100)
 R1=mRand(50,255)
 G1=mRand(50,255)
 B1=mRand(50,255)
 R2=mRand(50,255)
 G2=mRand(50,255)
 B2=mRand(50,255)
 NDOTS=mRand(20,100)
 ZD=mRand(3,10)
 SPREAD=mRand(-200,200)
 SHAPE[0]=mRand(0,1)
 SHAPE[1]=mRand(0,1)
end

function BDR(y)
 vbank(0)
	local yS=.6+mSin(y*.02+T*.03)*.4
	local nyS=1-yS
 rgb(0,R0*yS,G0*yS,B0*yS)
	local rd,gd,bd=R1-R0,G1-G0,B1-B0
	for i=1,15 do
	 local v=i/15
		rgb(i,R0+(v*rd)*yS, G0+(v*gd)*nyS, B0+v*bd)
	end

 vbank(1)
	local rd,gd,bd=R2-R0,G2-G0,B2-B0
	for i=1,15 do
	 local v=i/15
		rgb(i,R0+v*rd, G0+(v*gd)*yS, B0+(v*bd)*nyS)
	end
end

function TIC()
 if T%200==0 then
  shuffle()
 end

 for v=0,1 do
	 vbank(v)
	 cls()
	 local nDots=30
	 local dmax=50+mSin(T*.08+(v+1)*T*.01)*50
		for i=1,NDOTS do
		 for zD=0,ZD do
				local ua=i/nDots*mTau+zD
				local ud=1+mSin(v*2+ua*mTau*2+T*.02)*.2
				local d=ud*dmax
				local a=ua+T*.01
				local x=mSin(a+v)*d+v*SPREAD-SPREAD/2
				local y=mCos(a+v*2+zD*.1)*d+ffts(v*50)*50
				local z=zD*4
				x,z=rot(x,z,T*.01+v*.3)
				y,z=rot(y,z,T*.015+v*.2)
				x,y=rot(x,y,T*.018+v*.5)
				local c=1+(d*.1+zD)%15
				local r=3+mSin(ud*7-zD)*5
				x,y,z=proj(x,y,0)
				draw(v,x,y,r,c)
			end
		end

		for y=0,135 do
			for x=0,239 do
			 local c=pix(x,y)
				if c>0 then
					c=c+mSin(x*.1)*2+mSin(y*.1+T*.2)*2
					c=mMin(mMax(c,1),15)
					pix(x,y,c)
				end
			end
		end
	end
	
	T=T+1
end

function draw(v,x,y,r,c)
 x,y=x%240,y%136
 local shape=SHAPE[v]
 if shape==0 then
		circb(x,y,r,c)
		circ(x,y,r-2,c-1)
	else
		rect(x-r/2,y-r/2,r,r,c)
	end
end

function rot(a,b,r)
 return
 	mSin(r)*a-mCos(r)*b,
 	mCos(r)*a+mSin(r)*b
end

function proj(x,y,z)
 local zD=5/(3-z)
 return 120+x*zD, 68+y*zD, zD
end

function rgb(i,r,g,b)
 local a=16320+i*3
 poke(a,r)
 poke(a+1,g)
 poke(a+2,b)
end