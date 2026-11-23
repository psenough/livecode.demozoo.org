FFT_SIZE=1023
STARS=10
STEP=4
fc={}
fm={}
fn={}
star={}
str={}
for i=1,30 do
	star[i]={}
	str[i]=0
end
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
vbank(0)
for i =0,15 do
	pal(i,i*i*5,i*i*2.2,i*20)
end
vbank(1)
for i =0,15 do
	pal(i,i*i*2.2,i*i*5,i*20)
end


W=240
H=136
min=math.min
max=math.max
exp=math.exp
rnd=math.random
abs=math.abs
function BOOT()
	for i=1,FFT_SIZE do
		fc[i]=0
		fm[i]=0
		fn[i]=0
	end	
	for i=1,STARS do
		str=star[i]
		str[0]=rnd(W)
		str[1]=rnd(H)
		str[2]=rnd(-10,10)
		str[3]=rnd(-10,10)
	end
end
function subPix(i,a,f)
	local p=peek4(i)
	poke4(min(i-f,0x3fbf*2),max(p-a,0))
end
function divPix(i,a,of)
	local p=peek4(i)
	if p/a<=2 then p=0 end
	poke4(min(i-of,0x3fbf*2),min(p/a,15))
end
vbank(0)
cls(0)
vbank(1)
cls(0)
function TIC()
	vbank(0)
	for y=0,H do
		line(0,y,W,y,fft(abs(y-H/2))*20+fft(10)*20)
	end
	vbank(1)
	t=time()//32
	off=fft(1,10)
	tt=t//14
		if off>1 then
			for i=1,STARS do
				str=star[i]
				str[2]=rnd(-10,10)
				str[3]=rnd(-10,10)
			end
		end
	for i=1,FFT_SIZE-1 do
		fc[i]=fft(i,i+1)
		if fc[i]>fm[i] then fm[i]=fc[i] else fm[i]=fm[i]*.9999 end
		fn[i]=fc[i]/fm[i]
	end
	for i=0,W*H,STEP do
		subPix(i+((t-i*.01)*3)%STEP,4,0)
	end
	for y=0,136 do 	
		for x=0,240 do
			X=x/240-.5
			X=abs(X)*300
			f=exp((X*3+80)*.01+.5)//1
			f=min(max(1,f),FFT_SIZE-3)
			fs=fft(f+1,f+3)
			fs=fs*8/((X*.02+1)*.10)
			if fs*3>y then
				pix(x,y,min(fs*2,15)+off//2)
			end
		end 
	end 
 for i=1,STARS do	
 	str=star[i]
  str[4]=str[0]
  str[5]=str[1]
 	str[0]=str[0]+str[2]
 	str[1]=str[1]+str[3]
  str[2]=str[2]*.95
  str[3]=str[3]*.95+.9-off
  
  if str[0]+str[2]<0 or str[0]+str[2]>W-1 then
  	str[2]=-str[2]
	 	str[0]=str[0]+str[2]*2
  end
  if str[1]<0 or str[1]>H-1 then
  	str[3]=-str[3]
	 	str[1]=str[1]+str[3]*2
  end
  x1=str[0]
  y1=str[1]
  x2=str[4]
  y2=str[5]
  x3=str[0]+str[2]*2
  y3=str[1]+str[3]*1.5
  line(x1,y1,x2,y2,14)
  circ(x1,y1,off*10,14)
 end
end

function BDR(i)
	vbank(0)
	poke(0x3ff8,fft(abs(i-H/2-4))*100)
	vbank(1)
end