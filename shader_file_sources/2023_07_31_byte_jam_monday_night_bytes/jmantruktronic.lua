-- Bytejam 20230731
-- jtruk+Mantratronic
T=0
function BDR(y)
	vbank(0)
	for i=1,15 do
		local addr=0x3fc0+i*3
		local r=math.sin(i+T*.05+y*.01)
		local g=math.sin(1+i+T*.04)
		local b=math.sin(2+i+T*.03)
		poke(addr,127+r*127)
		poke(addr+1,127+g*127)
		poke(addr+1,127+b*127)
	end
	--[[
	vbank(1)
	for i=1,15 do
		local addr=0x3fc0+i*3
		local r=math.sin(i+T*.05+y*.01)
		local g=math.sin(1+i+T*.04)
		local b=math.sin(2+i+T*.03)
		poke(addr,127+r*127)
		poke(addr+1,127+g*127)
		poke(addr+1,127+b*127)
	end
	--]]
end

function TIC()
	vbank(0)
	cls()
	for i=0,70 do
		local c=(i%2==1)and 0 or 1+(i%10)
		local a=math.sin(i*.08+T*.03)
		local z = 200 - (i/70)^2*200
		local d=200-i*3--math.sin(i*.2+T*.1)*30
		local x=120+math.sin(i*.05+T*.02)*60
		local y=68+math.cos(i*.05+T*.02)*40
		doRect(x,y,c,a,z)
		
		if i%5 == 0 then
		 circ((i*30+T)%240, (i*24 + 1000*fft(i))%136, 70-i,i)
		elseif i%7 == 0 then
 		doRect((i*5+T*0.1)%240,136-(i+T+fft(i)*200)%170,c,a,d/2)
		end
	end
	--[[
	for i=0,25 do
	 x=math.random()*240
	 y=20+math.random()*116
		vbank(0)
	 c=pix(x,y)
		d=fft(i)*100
		a = T*0.01 + i/25
		x1=x - d/2*math.sin(a)
		x2=x + d/2*math.sin(a)
		y1=y - d/2*math.cos(a)
		y2=y + d/2*math.cos(a)
		vbank(1)
		-- this should do something... hmm
		line(x1,y1,x2,y2,c)
		line(x1,y2,x2,y1,c)
	end--]]
	
	vbank(1)
	--if (T//120)%2 == 0 then
 	cls()
 --end
 --rect(0,0,240,15-math.abs(math.sin(T*.004))*10,0)
	doText("jtruk+mantratronic: Hi to Aldroid, The Wolf, MrSynAckster, Alia, Gasman, ps, and Byte Jam viewers!")
	T=T+1
end

function doRect(x,y,c,a,d)
	a=a+math.pi*.25
	local	x0,y0=rotP(x,y,a,d)
	local	x1,y1=rotP(x,y,a+math.pi*.5,d)
	local	x2,y2=rotP(x,y,a+math.pi,d)
	local x3,y3=rotP(x,y,a+math.pi*1.5,d)
	tri(x0,y0,x1,y1,x2,y2,c)
	tri(x2,y2,x3,y3,x0,y0,c)
end

function rotP(xc,yc,a,d)
	return
		xc+math.sin(a)*d,
		yc+math.cos(a)*d
end

function doText(s)
	local t=time()
	local w=print(s,240,0,0)
	local x=math.sin(t*.0008)*math.min((220-w)/2,0)
	local y=10-math.abs(math.sin(t*.004))*10
	print(s,120+x-w/2+1,y+1,15)
	print(s,120+x-w/2,y,12)
end