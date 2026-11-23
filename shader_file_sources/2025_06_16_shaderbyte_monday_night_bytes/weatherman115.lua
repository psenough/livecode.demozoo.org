sin=math.sin
cos=math.cos
rnd=math.random
atan2=math.atan2

for i=0,47 do
	poke(16320+i,i*3)
end

local fftsMax={}
for n=0,1023 do
	fftsMax[n]=0
end


yLower=math.pi*9*(4-1/6)
yUpper=math.pi*9*(2-1/6)

circle={
	r=12,
	x=68,
	xRoot=0,
	xNext=0,
	y=yUpper
}

vbank(1)cls()

tLag=0
function TIC()
	t=time()*60/1000
	
	for n=0,1023 do
		if ffts(n)>fftsMax[n] then
			fftsMax[n]=ffts(n)
		end
	end
	
	vbank(0)
	for y=0,135 do
		local fftShift = 0
		for n=0,6 do
			fftShift = fftShift+ffts(y*7+n)/fftsMax[y*7+n]
		end
		local atanY = (y/9)%(2*math.pi)>(math.pi) and y or 0
		local sinY = sin(y/9)
		for x=0,239 do
			
			pix(x,y,(4)*atan2(sinY,cos(t/4+x+atanY+2*fftShift)))
			
		end
	end
	--cls()
	
	
	
	vbank(1)cls()
	
	--line(0,yLower,239,yLower,4)
	--line(0,yUpper,239,yUpper,4)
	
	local tBase=(
		(tLag%120<60)
		and tLag%60
		or 60-(tLag%60)
	)/60
		
	if tLag%60==0 then
		circle.xRoot = circle.xNext
		circle.xNext = 20+200*rnd()
		
		circle.x = circle.xRoot
	else
		circle.x = circle.xNext*(tLag%60)/60 + circle.xRoot*((60-tLag)%60)/60
	end
	
	circle.y = yUpper*tBase+yLower*(1-tBase) - 160*tBase*(1-tBase)
	
	for n=1,4 do
		circ(
			circle.x-n/2,
			circle.y-circle.r-n/2,
			
			circle.r-n+1,
			n)
	end
	
	tLag=tLag+1
	--print(t-tLag,0,0,12)
	
end
