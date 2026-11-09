local T=0
local M=math
local S=M.sin
local C=M.cos
local MIN,MAX=M.min,M.max
local PS_TITLE=nil
local PS_AT=nil
local PS_DEADLINE=nil


function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BOOT()
	PS_TITLE=getTextAsPs("ByteWall")
	PS_AT=getTextAsPs("at")
	PS_PARTYNAME=getTextAsPs("Deadline")
	rgb(0,40,10,40)
end

function TIC()
	cls()
	drawPs(PS_TITLE,110,30,4,9)
	drawPs(PS_AT,215,40,3,2)
	drawPs(PS_PARTYNAME,130,56,5,1)
	local xtxt=58
	print("Know TIC-80?",xtxt,70,12)
	print("Want to party code?",xtxt,80,12)
	print("We need your effect!",xtxt,90,12)
	print("Play at the kiosk below",xtxt,100,12)

	print("Idea & Install: RaccoonViolet ~ Code: jtruk",5,120,13)
	print("Powered by Bytejammer",60,130,14)
	T=T+1
end

function getTextAsPs(text)
	cls()
	local w=print(text,0,0,1)
	local h=6
	local ps={}
	for y=0,h-1 do
	 local pLine={}
		for x=0,w-1 do
		 local c=pix(x,y)
			if c>0 then
			 table.insert(ps,{x=x-w/2,y=y-h/2,c=c})
			end
		end
	end
	return ps
end

function rot(a,b,r)
	return a*C(r)-b*S(r),a*S(r)+b*C(r)
end

function drawPs(ps,ox,oy,sc,bc)
	local csz=sc/1.5+1
	local csz2=MAX(csz-1,1)
	for i=1,#ps do
		local p=ps[i]
		local px=p.x
		local py=p.y
		px,py=rot(px,py,S(T*.02+px*.05+py*.05)*.2)
		local dx=ox+sc*px
		local dy=oy+sc*py
		dx=dx+S(dx*.04+T*.06)*2
		dy=dy+S(dy*.04+T*.03)*2
		circ(dx,dy,csz,bc+p.c)
		circ(dx-1,dy-1,csz2,bc+p.c+1)
	end
end
