-- pos: 0,0
sin=math.sin
cos=math.cos
rnd=math.random

for i=0,47 do
	poke(16320+i,i*5)
end

local vqtTable = {}
local smudgeX = 0
local smudgeY = 0
tFR = 0

function TIC()
	
	t=time()*60/1000
	
	for n=0,119 do
		vqtTable[n]=(vqts(n)^(1/3))*67
	end
	
	if tFR > 0 then
		
		smudgeX = 3+1.1*cos(t/64)
		smudgeY = 3+1.1*cos(t/99)
		
	end
	
	for x=0,239 do
		local vqtVal = x<120 and vqtTable[x] or vqtTable[239-x]
		for y=0,135 do
			
			if tFR>0 and math.abs(y-67.5)<vqtVal then
				
				pix(x,y,
					pix(x+smudgeX*(rnd()-.5),y+smudgeY*(rnd()-.5))
					--15
				)
				
			elseif math.abs(y-67.5)<vqtVal+9 then
				pix(x,y,0)
			else
				
				pix(x,y,
					8*
					cos(x/(32+16*sin(t/99))
					+sin(t/24))*sin(y/(32+(3&y+tFR))
					+cos(t/27)+t/64)+t/9
				)
				
			end
			
		end
	end
	
	tFR = tFR + 1
	
end
