-- pos: 0,0
sin=math.sin
cos=math.cos
atan2=math.atan2

local function distance(x0,y0,x1,y1)
	return math.sqrt((x1-x0)^2 + (y1-y0)^2)
end


local function circPattern(px,py,cx,cy,pdist,pIndex)
	
	return (
	pIndex<1
	 and pdist+sin(pdist+t/32)
	or pIndex<2
	 and ((px-cx//1)~(py-cy//1))/(5+2*sin(t/37)*sin(t/53))
	or pIndex<3
	 and py/8+sin(py/9+px/5+t/7)+sin(px/9+t/7)
	or pIndex<4
	 and t/16+(atan2(pdist-px-py,99+(px-py+cx-cy)%32))*8
	or sin(atan2(py-cy+68,px-cx+120)+t/99)*9+vqtTable[pdist]
	)%2
	
end
patternCount = 5

vqtTable = {}



function TIC()
	
	t=time()*60/1000
	
	local circX = 120 + 120*cos(t/64)
	local circY = 68 + 68*sin(t/37)
	
	for n=0,119 do
		vqtTable[n] = vqts(n)
	end
	
	local patternIndex = (t/210)%patternCount
	
	for y=0,135 do
		for x=0,239 do
			local dist = distance(circX,circY, x,y)//1
			
			if dist>=66 then
				pix(x,y,
				dist<68
					and 3
				or (atan2(y-circY,x-circX)*math.pi*4 + vqtTable[dist%120])%1<.5
				 and 12
				or 3)
			else
				pix(x,y,3+ circPattern(x,y,circX,circY,dist,patternIndex))
			end
		end
	end
	
end