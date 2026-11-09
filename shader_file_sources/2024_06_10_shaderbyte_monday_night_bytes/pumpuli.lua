W=240
H=136
PI=3.14

sqrt=math.sqrt
abs=math.abs
atan=math.atan
min=math.min
max=math.max
rnd=math.random

function pal(i,r,g,b)
	if i<0 then i=0 end
	if i>15 then i=15 end
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
for i=0,15 do
	pal(i,i*50,i*30,i*i*2)
end

function sdCir(x,y,r)
	return sqrt(x*x+y*y)-r
end

function subPix(x,y,a,f)
	local i=x+y*W
	local p=peek4(i)
	poke4(min(i-f,0x3fbf*2),max(p-a,0))
end

function TIC()
	t=time()/32
	b=fft(10)*10
	for y=0,H do 
		for x=0,W do
			X=x/W-.5
			Y=y/H-.5
			Y=Y/(W/H)
			d=abs(atan(Y/X)/PI)*100
			f=fft(min(1024,max(0,d+10)))*10
			if (sdCir(X,Y,.1)-t*.002)%.2<f*.1 then
				pix(x,y,11)
			else
				subPix(x,y,rnd(3),2-rnd(4))
			end
		end 
	end 
	vbank(1)
	cls(0)
	print("pumpuli",W/4,H/2-2-b,2,1,3)
	print("pumpuli",W/4,H/2-4-b,4,1,3)
	vbank(0)
end
