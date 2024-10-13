f={}
fmax={}
for i=1,256 do
	f[i]=0
	fmax[i]=0.000001
end

cls()
t=0
bass=0

function TIC()
	vbank(1)
	memcpy(0x8000,0,16320)
	
	vbank(0)
	for x=0,240//8 do
		local v=fft(x*8)
	 fmax[x+1]=math.max(fmax[x+1],v)
		v=(v/fmax[x+1])+(f[x+1]*.8)
		f[x+1]=v
		
		if x>0 then
			local c=v*3
			tri(
				x*8-8,136,
				x*8,136,
				x*8-8,136-f[x]*10,
				c
			)
			tri(
				x*8-8,136-f[x]*10,
				x*8,136,
				x*8,136-f[x+1]*10,
				c
			)
		end
	end
	
 bass=0
 for i=1,10 do
 	bass=bass+f[i]
 end
	
	
	local len=120*135-1
	memcpy(0x4000,121,len)	
	
	cls()
	memcpy(0,0x8000,16320)
	local strl={"=^^=","NOVA","GRTz","NICO","TBCH","GMAN","eViL","dave","f3ll","mntr","jtrk","dBoy","andU","trans","rhts"}
	local str=strl[t//10%#strl+1]
	print(str,6,51+math.sin(t/10)*20,15,0,10)
	print(str,5,50+math.sin(t/10)*20,12,0,10)
	
	vbank(1)
	ttri(
		0,0,
		480,0,
		0,136*2,
		math.sin(t/12)*10,math.sin(t/8)*4,
		480+math.sin(t/10)*4,math.sin(t/7)*4,
		math.sin(t/11)*14,136*2+math.sin(t/9)*4,
		2
	)
 
	vbank(0)
	memcpy(0,0x4000,len)
 
	vbank(1)
 
 t=t+bass/80 
 print("alia",4,129,15)
 print("alia",3,130,12)
end

function SCN(y)
 vbank(1)
 for x=0,239 do
  pix(x,y,math.max(0,
  pix(x,y)-(x%2+y%2)%2+((bass/12)*(t//16%1))
  ))
 end
 local v=f[(y+t//1)%135+1]
 poke(0x3ff9,v*10)
 poke(0x3ffa,v*10)
end