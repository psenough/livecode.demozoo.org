T=0
M=math
S,C=M.sin,M.cos

CAMX,CAMY,CAMZ=0,0,0

function rgb(i,r,g,b)
 local a=16320+i*3
 poke(a,r)
 poke(a+1,g)
 poke(a+2,b)
end

function BDR(y)
	vbank(0)
 poke(0x3FF9,S(y*.2+T*.1)*3+S(y)*6)
 local r=100+S(2+y*.4)*50+S(T*.1+y//8)*50
 rgb(0,r,0,0)
 rgb(1,32,32,128)
 rgb(2,128,32,32)

	vbank(1)
 poke(0x3FF9,-S(y*.3+T*.1)*3)
 rgb(1,64,64,128)
 rgb(2,255,r,r)
end

function TIC()
 poke(0x3ffb,0)
 local sp=10+S(T*.0002)*10
 local ofs=T*.2
 local nDots=50
 for v=0,1 do
  vbank(v)
	 cls()
	 for i=0,nDots do
	  local a=i*sp
	  local x=S(a)
	  local y=C(a)
	  local z=(i-T*.1)%nDots
	  x,y,z=proj(x,y,z)
	  local sz=math.min(6*z^.5,20)
			if v==1 then
			 x=x+z
			 y=y+z
			end
	  circ((i+y+x+ofs*sp)%240,(i+y-x+ofs)%140,sz,1)
	  circ(x,y,sz,2)
	 end
	end
 T=T+1
end

function proj(x,y,z)
	local projScale=2
	local zD=projScale/(z-CAMZ)
	local pixScale=80
	return
		120+(x-CAMX)*zD*pixScale,
		68+(y-CAMY)*zD*pixScale,
		zD
end