--140d1c1611281516341925401c394c1f525922665c2573532881432a8e2d479c2c6eaa2e85ca49a0d37bbee0aadeeed7
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
pal(14,255,182,0)
pal(4,255,255,255)
pal(15,0,0,0)

exp=math.exp
pow=math.pow
max=math.max
min=math.min
abs=math.abs
sin=math.sin
cos=math.cos
grt={"FEED","YOUR","CATS","NOW!"}
cls(0)
function subPix(i,a)
	local p=peek4(i)
	poke4(min(i,0x3fbf*2),max(p-a,0))
end
function addPix(i,a,of)
	local p=peek4(i-of)
	poke4(min(i+of,0x3fbf*2),min(p+a,15))
end


bpm=162
function timekeep(bpm)
	local s=120/bpm*31.2
	local t=time()//s
	return t
end

function TIC()
	t=timekeep(bpm)
	--[
	i=0
	offx=sin(t)*10
	c=cos(t/10)
	s=sin(t/10)
	for y=0,H do 
		for x=0,W do
			ox=pow(abs(x-W/2),.98)
			oy=y
			rx=x
			ry=y
			
			i=i+1
			fx=fft(ox)*((1000+ox*1000)/5)
			if (fx/1000)>abs(.5-ry/H) then
				pix(rx,ry,max(min(fx,15),0))
			else
				if ox%4==t%5 then
					subPix(i,2)
				else
					addPix(i,-1,fx*.1)
				end
			end
		end 
	end 
	if t%16==0 then
		cls(15)
		pal(14,255*((t/16)%4)//4,255*(((t/16)+1)%4)//4,255*(((t/16)+3)%5)//5)
	end
	w=print(grt[(t//16)%4+1],0,-6)
	sc=4+(t/64%8)
	if t%16>8 then
		print(grt[(t//16)%4+1],W/2-w*sc/2+(t%16*(1-(t/2)%2)),H/2-2*sc,15,1,sc)
	else
		print(grt[(t//16)%4+1],W/2-w*sc/2,H/2-2*sc,4,1,sc)
	end
	i=0
	if (t/32)%8>7.75 then
		cls(0)
		w=print("OwO",0,-6)
		print("OwO",W/2-w/2*4,H/2-4*2,14,1,4)
		
	end
	for x=0,W do
		for y=0,H do
			i=i+1
			if x%2==(t/5)%2 then
				addPix(i,-1,0)
			elseif y%2==(t/5)%2 then
				subPix(i,-1)
			end
		end
	end--]]
	updateBPM()
end

function updateBPM(dbg)
 local bt1=0
 local bt2=0
	if btn(0) then
		bt1=1
		dbg=1
	else
		bt1=0
	end
	if btn(1) then
		bt2=1
		dbg=1
	else
		bt2=0
	end
	bpm=bpm+(bt1-bt2)*.1
	if not(dbg==0 or dbg==nil) then
		rect(0,0,30,6,1)
		print(bpm,0,0,14,1)
	end
end
