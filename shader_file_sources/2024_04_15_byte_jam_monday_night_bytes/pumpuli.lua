SMOOTH=0.8
W=240
H=136
fc={}
fm={}
fn={}
function BOOT()
    for i=0,255 do
        fc[i]=0
        fm[i]=0
        fn[i]=0
    end
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

for i=0,15 do
	pal(i,i*32,i*32,i*32)
end
vbank(1)
for i=0,15 do
	pal(i,i*32,i*32,i*32)
end
vbank(0)

function eft(a)
    return fft(math.exp(a/255*6))
end

function ffts(a,b)
    local f=0
    if a==b then 
        f=eft(a)
    else 
        for i=a,b,SMOOTH do 
            f=f+eft(i)
        end
        f=f/((b-a)*(1/SMOOTH))
    end
    return f
end
function sfft(f,s)
    return ffts(f-s,f+s)
end

min=math.min
max=math.max
abs=math.abs
rnd=math.random
sin=math.sin
cos=math.cos

grt={"F","I","E","L","D","F","X"}

function subpx(i,a)
	local p=peek4(i)
	poke4(i,max(p-a,0))
end	
function subpx2(i,a)
	local p=peek4(i)
	poke4(i-(1-rnd(2)*2),max(p-a,0))
end	
cls(0)

function TIC()
poke(0x3FFB,0)
	t=time()//320
	for i=0,255 do
  fc[i]=sfft(i,(256-i)/32+1)*.1
  if fc[i]>fm[i] then 
  	fm[i]=fc[i] 
  else 
  	fm[i]=fm[i]*0.999 
  end
  fn[i]=fc[i]/fm[i] 
 end 
	for i=1,240*136 do
		subpx(i,rnd(5))
	end
	for y=0,136 do 	
		for x=0,240 do
			X=x/W-.5
			Y=y/H-.5
			X=X*W
			Y=Y*H
			d=min(255,max(0,abs(X*2.1)))
			dy=min(255,max(0,abs(X*2.1)))
			ff=fn[d//1]*30
			fy=fn[dy//1]*30
			p=max(0,min(15,abs(Y/fy)+rnd(2)))
			if abs(Y)>ff*2 then 
				pix(x,y,min(ff//1,p))
			elseif abs(Y)>ff*2-2 then 
				pix(x,y,15)
			else
				pix(x,y,1)
			end
		end 
	end
	
	for i=0,15 do	
		r = i*(32*sin(t))
		g = i*(32*sin(t*1.1+.25))
		b = i*(32*sin(t*.8+9))
		pal(i,r,g,b)
	end
	pal(15,255,255,255)
	
	vbank(1)
	for i=1,240*136 do
		subpx2(i,rnd(5))
	end
	for i=0,14 do	
		r = i*(32*-sin(t))
		g = i*(32*-sin(t*1.1+.25))
		b = i*(32*-sin(t*.8+9))
		pal(i,r,g,b)
	end
	for i=1,7 do
		w=W/2-80+(i-1)*23
		h=10+fn[(2+i*16)]*20
		ox=fn[i*16]*4
		oy=fn[i*16]*5
		print(grt[i],w+ox,h+oy,2,1,4)
		print(grt[i],w,h,10,1,4)
		print(grt[i],w-ox,h-oy,15,1,4)
	end	
	vbank(0)

end