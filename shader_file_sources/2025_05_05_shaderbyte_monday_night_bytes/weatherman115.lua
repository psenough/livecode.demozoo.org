sin=math.sin
cos=math.cos
rnd=math.random
pi=math.pi
max=math.max

local asdf=true
local asdf2=true
local fftRandomIndex={}
local fftsSum={}
for n=0,1023 do
	fftsSum[n]=0
end
layer2Add={0,0,0}

vbank(1)
for i=0,47 do
	poke(16320+i,(255-peek(16320+i))/2)
end

function TIC()
	t=time()*60//1000
	
	for n=0,239 do
		fftRandomIndex[n]=rnd()*1024//1
	end
	
	for n=0,1023 do
		fftsSum[n] = fftsSum[n]+ffts(n)
	end
	
	vbank(0)
	if rnd()<.01 then asdf = not asdf end
	if rnd()<.01 then asdf2 = not asdf2 end
	for y=0,135 do
		for x=0,239 do
			pix(x,y, ((pix(x,y)+ffts( fftRandomIndex[asdf and x or y] )*16)%16)-.1 )
		end
	end
	
	for n=0,1023 do
		local x=((t+n*64+4*fftsSum[n])%256)-8
		local y=68+64*sin(t/99+n)
		circ(x,y,16*ffts(n),0)
	end
	
	if rnd()<0.5 then
		x=rnd()*240//1
		y=rnd()*136//1
		c=pix(x,y)
		layer2Add={
			true,
			x,
			y,
			c,
			asdf
		}
	else
		layer2Add[1]=false
	end
	
	vbank(1)
	
	if asdf2 then
		for y=0,135 do
			for x=0,238 do
				pix(x,y,pix(x+1,y))
			end
		end
		for n=0,7 do
		pix(239,rnd()*136,0)
		end
	else
		for y=0,134 do
			for x=0,239 do
				pix(x,y,pix(x,y+1))
			end
		end
		for n=0,7 do
		pix(rnd()*240,135,0)
		end
	end
	
	if layer2Add[1] and layer2Add[4]>0 then
		local _,x,y,c = table.unpack(layer2Add)
	 dir = asdf2
		for n=0,1 do
			if not dir then
				line(x+n,0,x+n,135,c)
			else
				line(0,y+n,239,y+n,c)
			end
		end
	end
	
	for n=0,9 do
		circ(rnd()*240,rnd()*136,rnd()*3,0)
	end
	
	circ(240-16,136-16,fft(0,1023)/2,6)

end
