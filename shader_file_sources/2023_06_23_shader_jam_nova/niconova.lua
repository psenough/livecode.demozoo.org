```
-- yo it's nico
-- representing cats
-- let's try an idea inspired
-- by something else happening at this
-- party (greets to maple!)

-- this set is banging
-- FFT is being funky so this will not be
-- music synced. Sorry if that is
-- a problem for anybody
-- accurate to some IIDX charts though
-- :P

notes = {}
notenow = 1

sin = math.sin
cos = math.cos
function TIC()t=time()//32

keycolor = 12
cls()

-- bg effect
for x=0,240 do
	for y=0,138 do
		pix(x,y,sin(x/16+t/16)+sin(y/8+t)+(t/32)*2)
	end
end

rect(80,0,90,120,0) -- note lanes

if (t%10==0 and notenow==1) then
	pos = math.random(8)-1
	notes[#notes+1] = {
		col = pos,
		position = 0
	} -- god I hate lua
end

for i=1,#notes do -- draw notes
	color = 12
	if notes[i]["col"]%2 == 0 then
		color = 10
	end
	if notes[i]["col"] == 0 then 
		rect(80,notes[i]["position"],18,2,3)
	else
		rect(98+(notes[i]["col"]*8),notes[i]["position"],8,2,color)
	end
	notes[i]["position"] = notes[i]["position"]+2
end

fftboop = fft(0)+fft(1)+fft(2)+fft(3)+fft(4)
if fftboop>0.5 then
	keycolor = 6
end
rect(80,115,90,50,14) -- base

	color = 15
	for j=1,#notes do -- adding a comment every time lua is a pain
		if (notes[j]["col"] == 0  
		and notes[j]["position"] >= 110 
		and notes[j]["position"] <= 120) then
			color = 5
			rect(80,0,18,118,12)
		end
	end
	
circ(88,127,6,color) -- turntable

 -- turntable spinning
line(88,122,88,128,12)
-- couldn't make it rotate in time

line(80,0,80,115,12) -- guides
line(80+6*3,0,80+6*3,115,12) -- guides

for i=1,4 do
	color = 12
	for j=1,#notes do -- adding a comment every time lua is a pain
		if (notes[j]["col"]~=0 and notes[j]["col"]%2 == 1 and notes[j]["col"]//2+1 == i 
		and notes[j]["position"] >= 110 
		and notes[j]["position"] <= 120) then
			color = 5
			rect(90+(i*16),0,8,118,12)
		end
	end
	rect(90+(i*16),124,8,10,color) -- low keys
	line(90+(i*16),0,90+(i*16),115,12)
	line(90+(i*16)+8,0,90+(i*16)+8,115,12)
end

for i=1,3 do
	color = 10
	for j=1,#notes do -- adding a comment every time lua is a pain
		if (notes[j]["col"]//2 == i 
		and notes[j]["col"]%2 == 0
		and notes[j]["position"] >= 110 
		and notes[j]["position"] <= 120) then
			color = 5
			rect(90+(i*16)+8,0,8,118,12)
		end
	end
	
	rect(90+(i*16)+8,124-8,8,10,color) -- high keys
end

end
```