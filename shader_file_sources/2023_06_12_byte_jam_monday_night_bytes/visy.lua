t = 0
curr = {}
last = {}

function init()
	for i=1,255 do
		curr[i] = 0
		last[i] = 0
	end
end

init()

function fft_update()
	for i=1,255 do
		curr[i] = last[i] + fft(i)
		last[i] = curr[i]
	end
end

-- NES 2A03 <3

cy = 0

function pal(c0,c1)
 if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
 else poke4(0x3FF0*2+c0,c1) end
end

function scanline(s)
tt = (8+math.abs(math.cos(t*0.01+s*2)*8)) % 8
poke(0x3fc0,curr[s*0.3//(tt+1)+10]*100)
poke(0x3fc1,curr[s*0.4//(tt+1)+10]*10)

poke(0x3fc2,curr[s*0.5//(tt+1)+10]*100)
end

function TIC()t=time()//32

	f=0
	fft_update()
	cc = curr[16]+curr[32]+curr[160]
	cc = cc*0.1
	f = fft(15)
	cls(0)
	pal(0,0)
	cy=-cy+f*100
	for y=cy,cy+460,1 do
		sy = (y-cy+f)
		x1 = -256+sy%8 * 64+t*2%240
		y2 = sy+64
		sx = 64+math.cos(sy+t*0.1)*32

		tri(x1-64,128+sy-math.cos(t*0.1)*32,-32+x1+sx,64+y2+math.cos(t*0.1)*32,x1,32+math.cos(t*0.2+sy%8)*15,sy-cc)
--		trib(x1-33,127+sy-math.cos(t*0.1)*32,-32+x1+sx,64+y2+math.cos(t*0.1)*32,x1,32+math.cos(t*0.1)*3,sy%8)
		circ(x1,sy,sy*0.4-16+math.cos(t*0.04+sy%8)*32,cc+sy+t*0.2)
	
	end

 end
