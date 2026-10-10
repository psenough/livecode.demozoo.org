sin=math.sin
cos=math.cos
random=math.random

function rotate(x,y,r)
	return x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)
end

function setcolor(num, r, g, b)
	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)
end

setcolor(0,0,0,0)
setcolor(15,255,255,255)
vbank(1)
for i=0,47 do
	poke(16320+i,i*5)
end
setcolor(0,0,0,0)
local pixTable={}
for x=-120,119 do
	pixTable[x]={}
	for y=-68,67 do
		pixTable[x][y]=true
	end
end

function TIC()
	tFloat=time()*60/1000
	
	vbank(0)
	if tFloat%24<1 then
		for i=3,44 do
			poke(16320+i,0)
		end
		for n=0,2 do
		setcolor(1+random()*14//1,random()*255,random()*255,random()*255)
		end
	end
	
	local rot=0
	for i=3,9 do
		rot=rot+sin(tFloat/(i*i))/4
	end
	for py=-68,67 do
		for px=-120,119 do
			local x,y=rotate(px,py,rot)
			x=(x+tFloat)//16
			y=y//16
			pixTable[px][py]=(x~y)&1<1 and 1+(x*5~y*6)%14 or 0
		end
	end
	
	cls()
	for py=-68,67 do
		for px=-120,119 do
			if pixTable[px][py]>=1 then
				pix(px+120,py+68,pixTable[px][py])
			end
		end
	end
	
	local lightX=65*cos(tFloat/32)
	local lightY=32*sin(tFloat/20)
	
	vbank(1)cls()
	for py=-68,67 do
		for px=-120,119 do
			if pixTable[px][py]<1 then
				local distToLight=math.sqrt( (px-lightX)^2+(py-lightY)^2 )
				local lightColOut=math.max(0,15-distToLight/4)
				pix(px+120,py+68,lightColOut)
			end
		end
	end
	
end