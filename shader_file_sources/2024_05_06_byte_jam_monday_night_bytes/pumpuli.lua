W=240
H=136
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
	pal(i,i*i,i*i,i*i)
end


ffo={}
ffn={}
ffm={}
for i=0,1023 do
	ffo[i]=0
	ffn[i]=0
	ffm[i]=0
end
min=math.min
max=math.max
rnd=math.random
exp=math.exp

function subPix(i,a,f)
	local p=peek4(i)
	poke4(min(i-f,0x3fbf*2),max(p-a,0))
end
function divPix(i,a,of)
	local p=peek4(i)
	if p/a<=2 then p=0 end
	poke4(min(i-of,0x3fbf*2),min(p/a,15))
end
cls(0)
f=0
fx=0
function TIC()
	f=f+1
    for i =0,W*H,2 do
	    	divPix(i+f%2,1,1)
    end
    for i=0,1023 do
     local x=i/1023*136
								ffo[i]=fft(exp(i/200+1.5)/2)
								if ffo[i]>ffm[i] then ffm[i]=ffo[i] else ffm[i]=ffm[i]*.9999 end
								ffn[i]=ffo[i]/ffm[i]
								
        local fftsv=ffn[i]*10
        line(W,H-x,W-1,H-x,min(15,fftsv*15))
    end
    vbank(1)
    cls(0)
    fx=fft(10)*50
    print("PUMPULI",40-fx,58-fx,3,1,4)
    print("PUMPULI",40,58,0,1,4)
    vbank(0)
end