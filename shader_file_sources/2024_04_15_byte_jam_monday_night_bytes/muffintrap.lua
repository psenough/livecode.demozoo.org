--[[
	Thank you Aldroid for organizing!
	
	It was really intense and fun :D

	-muffintrap
]]--


S=math.sin
C=math.cos
NF={}
for y=0,128 do
	table.insert(NF,0)
end

lines={}
linering=1

for l=1,100 do
	table.insert(lines,{p=0})
end

function normalFFT()
	for y=0,128 do
		NF[y]=fft(y*2)*(2+y*0.65)
	end
end

function BASS()
 local	ba=0
	for b=0,60 do
		ba=ba+fft(b)
	end
	return ba
end

function LOMID()
	local ba=0
	for b=10,30 do
		ba=ba+fft(b)*b
	end
	return ba
end

function TIC()
	normalFFT()
	t=time()//32
	for y=0,136/4 do
		rect(0,y*136/4,240,136/4,1+y)
	end
	
	bass=BASS()
		lm=LOMID()
	if bass>2.5 then
		lines[linering].p=lines[linering].p+1
		linering=1+(linering+1)% #lines
	end

	
	for x=0,240 do
		for y=0,136 do
			line(x,68+fft(x)*100,
			x,68-fft(x+2)*100,1+(x%4))
		end
	end
	
	ramount=40
	ringstep=math.pi*2/ramount
	ringspeed=(t+bass*10)/40
	for rl=0,ramount do
	
		xo=S(ringspeed+rl*ringstep)*50
		yo=C(ringspeed+rl*ringstep)*50
		circb(120+xo,68+yo,20+bass*10+fft(60+rl*4)*100,7+rl%6)
	end
	
	
	for li=1,#lines do
		if lines[li].p > 0 then
			lines[li].p = lines[li].p+1
			ly=lines[li].p

	
			line(0,60-ly,240,60-ly,12-(ly%4))
			line(0,90+ly,240,90+ly,12-(ly%3))
			if ly>136 or ly < 0 then
				lines[li].p=0
			end
		end
	end
	
	dstep=240/12
	sx=-120
	line(0,90,240,90,12)
		line(0,60,240,60,12)
	for d=-60,60 do
		dx=sx+d*dstep
		line(120+dx/3,90,d*dstep,136,12)
		line(120+dx/3,60,d*dstep,0,12)
	end
	
--	print("MUFFINTRAP",60,80,12,12,2)
end
