W=240
H=136
RES=2
FFT_LEN=1023
VBK=0
fc={}
fm={}
fn={}
function BOOT()
    for i=0,FFT_LEN do
        fc[i]=0
        fm[i]=0
        fn[i]=0
    end
end

abs=math.abs
min=math.min
max=math.max
exp=math.exp
rnd=math.random

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

for i =0,15 do
	r=min(255,i*8.2+20)
	g=min(255,i*i*.5)
	b=min(255,i*i+i*8.5+20)
	pal(i,r,g,b)
end
vbank(1)
for i =0,15 do
	r=min(255,i*8.2+20)
	b=min(255,i*i*.5)
	g=min(255,i*i+i*8.5+20)
	pal(i,r,g,b)
end
vbank(0)



function subPix(i,a,f)
	local p=peek4(i)
	poke4(min(i-f,0x3fbf*2),max(p-a,0))
end
function addPix(i,a,of)
	local p=peek4(i-of)
	poke4(min(i+of,0x3fbf*2),min(p+a,15))
end
function flip()
	if VBK==0 then 
		VBK=1
		for i =0,15 do
			r=min(255,i*8.2+20)
			b=min(255,i*i*.5)
			g=min(255,i*i+i*8.5+20)
			pal(i,r,g,b)
		end
	else
		VBK=0
		for i =0,15 do
			r=min(255,i*8.2+20)
			g=min(255,i*i*.5)
			b=min(255,i*i+i*8.5+20)
			pal(i,r,g,b)
		end
	end
end
cls(0)
function TIC()
	t=time()//32
	bm=fft(0,40)*.8
	--cls(bm//1)
	RES=max(2,min(10,10-fft(0,40)*2))//1
	if RES>4 then 
		cls(16)
	end
	sn=fft(200,280)*50
	if min(15,sn*.01)>14 then 
	end
	for i=0,FFT_LEN-2 do
		fc[i]=fft(i,i+2)
  if fc[i]>fm[i] then fm[i]=fc[i] else fm[i]=fm[i]*0.999 end
  fn[i]=fc[i]/fm[i]
 end 
	for i=0,W*H,(RES-1) do
		subPix(i,rnd(2),bm*10)
	end
	for y=0,H,RES do 
		for x=0,W,RES do
			X=x/W-.5
			Y=y/H-.5
			xx=X*200--exp(abs(X*10)+1.5)
			f=fc[abs(xx)//1]*8
			fs=fc[abs(xx)//1]*8
			--fs=ffts(abs(xx),abs(xx)+5)*4
			if abs(Y)<fs*.1 then 
				rect(x,y,RES,RES,fs//1+1)
			end
		end 
	end 
	for i=0,FFT_LEN-1 do
		--pix(i,0,(fft(i,i+1)*100)//1)
	end
end

function BDR(i)
	local ii=i
	sn=fft(200,280)*10
	if sn>14 then 
		flip()
	end
	local ft=fft(ii,ii+2)*(11-sn)
	poke(0x3FF9,ft*10)
	poke(0x3FF8,ft*4)
end