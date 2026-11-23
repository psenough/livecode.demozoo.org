W=240
H=136
SKIP = 1
ADDR = 0x3FC0
palette = 0

function addLight()
 for i=0, 15 do
  for j=0, 2 do
   poke(ADDR+(i*3)+j, palette*15)
  end
  palette = palette + 1
 end
end

function subPix(i,a,f)
	local p=peek4(i)
	poke4(min(i-f,0x3fbf*2),max(p-a,0))
end
function addPix(i,a,of)
	local p=peek4(i-of)
	poke4(min(i+of,0x3fbf*2),min(p+a,15))
end

addLight()
poke(ADDR+4*3,  128)
poke(ADDR+4*3+1,100)
poke(ADDR+4*3+2,80)

poke(ADDR+12*3,  220)
poke(ADDR+12*3+1,100)
poke(ADDR+12*3+2,190)

abs=math.abs
exp=math.exp
min=math.min
max=math.max
rnd=math.random
flr=math.floor
gr={"PET","ALL","BNY","NOW"}
cls(0)
BPM=171
function TIC()
	t=time()//31*BPM
	b=0
	ft=fft(0)*100
	
	for i=0,100 do
		x=rnd(W)
		y=rnd(H)
		circ(x,y,i/10,ft)
		circb(x,y,i/10,0)
	end
	vbank(1)
	cls(0)
	for y=0,H do 
		for x=0,W do
			fq=abs(x-W/2)/30
			f=fft(exp(fq+1.5))*150
			yy=abs(y-H/2)
			if f>yy then 
				pix(x,y,2)
			end
			if f>yy and f<yy+2 then 
				pix(x,y,12)
			end
		end 
	end 
	vbank(0)
	tt=(t//1000)%4+1
	c=(t//10)%8*2
	w=print(gr[tt],0,-60,0,1,8)
	if c>5 then
		print(gr[tt],W/2-w/2+9,H/2-12*2+((c%3)*24-12)*3,c*(t),1,8)
	end
	for i=0,W*H,SKIP do
		subPix(i+t%SKIP,rnd(5)-2,ft/10)
	end
end

function BDR(row)
	a=abs((row-3)-H/2)
	fff=fft(exp(a/15+.5))*50
	vbank(1)
	off=min(fff,15)-8
	if row%2==0 then 
		poke(0x3FF9,off/2)
	else
		poke(0x3FF9,(off/2)*-1)
	end
	vbank(0)
	poke(0x03FF8,min(fff,15))
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>