-- Greetz: Aldroid, Synesthesia
-- T^Bach, Alia, Totetmatt
-- Sofa Jam watchers

MOUSE_LAST_B=false
T=0

TF={
	{9,116,83,44,102,32,138,206,135,197,105,116,83},
	{13,117,83,86,90,95,137,152,137,146,91,117,83},
	{10,117,95,117,86,102,86,86,90,87,102,117,106,146,101,144,90,131,85,117,85},
	{14,118,114,117,103,108,107,113,115,110,137,129,137,122,113,125,106,117,103},
	{3,116,50,109,93,132,92,152,70,157,40,149,18,112,11,80,20,81,55,101,88,109,93},
	{4,98,24,118,38,144,39,157,34,159,22,136,15,115,8,84,14,78,39,92,40,97,24},	
	{4,118,60,119,52,123,52,123,61,125,65,117,65,116,59,118,52},	
	{3,118,47,117,51,105,52,91,49,92,42,105,41,118,46,127,42,144,42,147,48,142,52,125,53,117,51},	
	{12,135,20,125,13,119,15,133,23,150,26,150,22,137,18},	
	-- left eye
	{12,137,49,143,46,132,46,129,52,139,52,145,48,142,46},
	{0,136,49,136,46,132,48,135,51,135,51,138,49,136,46},	
	{4,111,46,112,42,100,40,100,43},	
	-- right eye
	{12,105,48,110,47,104,44,98,45,96,48,105,50,109,50,110,47},
	{0,104,47,104,45,102,48,104,49,106,48,105,45,103,44},	
	{4,134,44,130,47,128,44,139,42,140,45},
	-- mouth
	{2,121,79,120,77,111,77,108,80,109,82,121,81,130,81,131,79,130,76,124,77,120,77},
	
	-- ear
	{2,85,49,84,46,84,53,86,54,85,49},
}

SCRATCH={}

function setCol(c,r,g,b)
	poke(0x3fc0+c*3,r)
	poke(0x3fc0+c*3+1,g)
	poke(0x3fc0+c*3+2,b)
end

function TIC()
 vbank(0)
 cls()
 for i=1,#TF do
  draw(TF[i],i)
 end

	drawScratch()

 local mx,my,lb,mb,rb,msx,msy=mouse()
 if lb and MOUSE_LAST_B==false then
  SCRATCH[#SCRATCH+1]=mx
  SCRATCH[#SCRATCH+1]=my
  
  local str=""
  for i=1,#SCRATCH do
   if i==1 then
    str=string.format("%d",SCRATCH[i])
   else
	   str=string.format("%s,%d",str,SCRATCH[i])
			end
  end
  str=string.format("{%s}",str)
  trace(str)
 end
 MOUSE_LAST_B=lb

 fade=.5+math.cos(T/80)*.5
 r=0*fade+(1-fade)*200
 g=0*fade+(1-fade)*100
 b=120*fade
 setCol(9,r,g,b)
 r=255
 g=255
 b=255
 setCol(10,r,g,b)
 r=255*fade+(1-fade)*200
 g=255*fade+(1-fade)*100
 b=255*fade
 setCol(13,r,g,b)
 r=255*fade+(1-fade)*200
 g=0*fade+(1-fade)*100
 b=0*fade
 setCol(14,r,g,b)

 vbank(1)
 cls()
 local xofs=math.sin(T/20)*20
 for x=-20,300,40 do
  rect(x+xofs,0,10,137,15)
  rect(x+xofs+2,0,3,137,14)
 end

 elli(xofs+12,120,10,20,9)
 elli(xofs+190,120,10,20,9)
 elli(xofs+12,110,5,13,3)
 elli(xofs+190,110,5,13,3)
 for y=0,3 do
	 elli(xofs+20,100+y*6,12,2,3)
	 elli(182+xofs,100+y*6,12,2,3)
 end
 r=0*fade+(1-fade)*200
 g=0*fade+(1-fade)*100
 b=120*fade
 setCol(9,r,g,b)

	T=T+1
end

function draw(trifan,bump)
 local c=trifan[1]
 local x0,y0=trifan[2],trifan[3]
	local xL,yL=trifan[4],trifan[5]

	local bx=math.sin(T/10+bump)
	local by=math.cos(T/10+bump)
	for i=6,#trifan,2 do
		local x,y=trifan[i],trifan[i+1]
		tri(x0+bx,y0+by,xL+bx,yL+by,x+bx,y+by,c)
		xL,yL=x,y
	end
end

function drawScratch()
	for i=1,#SCRATCH,2 do
	 local x,y=SCRATCH[i],SCRATCH[i+1]
	 pix(x,y,12)
	end
end