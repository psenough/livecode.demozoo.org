-- hello and greetings from Finland !

W=240
H=136
cls()
STEP=4
FBK=0
abs=math.abs
min=math.min
max=math.max
rnd=math.random
sin=math.sin
flr=math.floor
function pal(i,r,g,b)
	--sanity checks
	if i<0 then i=0 end
	if i>15 then i=15 end
	--returning color r,g,b of the color
	if r==nil and g==nil and b==nil then
		return peek(0x3fc0+(i*3)),peek(0x3fc0+(i*3)+1),peek(0x3fc0+(i*3)+2)
	else
		if r==nil or r<0 then r=0 end
		if g==nil or g<0 then g=0 end
		if b==nil or b<0 then b=0 end
		if r>255 then r=255 end
		if g>255 then g=255 end
		if b>255 then b=255 end
		poke(0x3fc0+(i*3)+2,b)
		poke(0x3fc0+(i*3)+1,g)
		poke(0x3fc0+(i*3),r)
	end
end

function green(i)
	local r,g,b=0,0,0
	b=min(255,i*10.2+20)
	r=min(255,i*i*.5+(b/(16-i))*2)
	g=min(255,i*i+i*2.5+20)
	return {r,g,b}
end
function red(i)
	local r,g,b=0,0,0
	b=min(255,i*8.2+20)
	g=min(255,i*i*.5+(b/(16-i))*2)
	r=min(255,i*i+i*8.5+20)
	return {r,g,b}
end
c={}
for i =0,15 do
	c=green(i)
	pal(i,c[1],c[2],c[3])
end
vbank(1)
for i =0,15 do
	c=red(i)
	pal(i,c[1],c[2],c[3])
end
vbank(0)

function subpix(i,a,f)
	local p=peek4(i)
	poke4(math.min(i-f,0x3fbf*2),math.max(p-a,0))
end
function addpix(i,a,of)
	local p=peek4(i-of)
	poke4(math.min(i+of,0x3fbf*2),math.min(p+a,15))
end
function flip()
	if VBK==0 then 
		VBK=1
		for i =0,15 do
			c=green(i)
			pal(i,c[1],c[2],c[3])
		end
	else
		VBK=0
		for i =0,15 do
			c=red(i)
			pal(i,c[1],c[2],c[3])
		end
	end
end

function TIC()
	t=time()//32
	b=fft(0.1)*20
	for i=0,W*H,STEP do
		subpix(i-t%STEP,b,-1+flr(b))
	end
	for y=0,H do 
		for x=0,W do
			X=x/W-.5
			Y=y/H-.5
			d=abs(X*W/(1+sin(t)))
			f=fft(d)*(2+d*.2)
			if f>abs(Y) then
				subpix(x+y*W,-3-f,0)
			else
				if (t/4)%3==0 then
					subpix(x+y*W,1,W)
				elseif (t/4)%3==1 then
					subpix(x+y*W,1,0)
				else
					subpix(x+y*W,1,-W)
				end
			end
		end
	end
end


function BDR(i)
	local ii=abs(H/2-i)*.4
	sn=fft(200,280)*100
	if sn>0.3 then 
		flip()
	end
	local ft=fft(ii,ii+2)*(11-sn)
	poke(0x3FF9,ft*2)
	--poke(0x3FF8,ft*4)
end