sin=math.sin
cos=math.cos
abs=math.abs

for y=0,136 do 
	for x=0,240 do
		pix(x,y,(x+y)>>3)
	end 
end

t=0
ft=0

fmax={}

for j=0,47 do
	poke(16320+j,sin(j)^2*255)
end
vbank(1)
memcpy(0x4000,0x3FC0,48)

for j=0,47 do
	poke(16320+j,peek(16320+j)*.7)
end
memcpy(0x4000+48,0x3FC0,48)

function TIC()
	for i=0,1023 do
		local v=ffts(i)
		fmax[i+1]=math.max(fmax[i+1] or 0, v)
	end
	
	vbank(0)
	memcpy(0,120,135*120)

	local lh=0
	local nh=0
	local intv=8
	for x=0,239 do
		local h=0
		if x%intv==0 then
			for i=0,intv do
				h=h+(ffts(x+i)/fmax[x+i+1])
			end
			lh=nh
			nh=h
		end
		local m=(x%intv)/intv
		h=nh*m+(lh*(1-m))
			--local h=ffts(x*4) --[x+1]
			--rect(x*2,135-h,2,h*16,h*16)
			--local h=ffts(x)
			line(x,135,x,135-h*8,h*3)
			--pix(x,135-h*8,h*16)
		--end
		--yL0=yL1
	end	
	
	vbank(1)
	cls()
	for i=0,15 do 
		print("=^^=",
			25+sin(ft*.2+i/12)^7*15,
			20+sin(ft*.1+i/12)^7*15,
			(i+11)%15+1,0,8)
	end
	
	--vbank(0)
	--poke(0x03FFa,-t%136-68)
	
	t=t+1
	local tft=0
	for i=0,32 do
		tft=tft+fft(i)
	end
	
	ft=ft+tft/16
end

function SCN(y)
	vbank(1)
	local f=0--ffts(y*3+t%1024)*100
	if y>68 then
		local w=sin((y-67)^.25*16+t/10)*y
		memcpy(0x3FC0,0x4000+48,48)
		poke(0x03FFa,135-y*2-f+w/32)
		poke(0x03FF9,w/8+f)
	else 
		memcpy(0x3FC0,0x4000,48)
		poke(0x03FF9,f)
		poke(0x03FFa,f)
	end
end
