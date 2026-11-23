local T=0
local M=math
local S=M.sin
local C=M.cos
local MAX=M.max
local PS_TITLE=nil
local PS_AT=nil
local PS_EVOKE=nil


function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BOOT()
	PS_TITLE=getTextAsPs("ByteWall")
	PS_AT=getTextAsPs("at")
	PS_EVOKE=getTextAsPs("Evoke")
	rgb(0,20,40,50)
end

function TIC()
	cls()
	drawPs(PS_TITLE,110,30,4,2)
	drawPs(PS_AT,65,50,2,3)
	drawPs(PS_EVOKE,160,56,5,5)
	sp=1+((T>>4)%2)*2
	spr(sp,20,62,14,3,0,0,2,2)
	print("Know TIC-80?",80,70,12)
	print("Want to party code?",80,80,12)
	print("We need your effect!",80,90,12)
	print("Play at the kiosk below",80,100,12)

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
	local csz=sc/2+1
	for i=1,#ps do
		local p=ps[i]
		local px=p.x
		local py=p.y
		px,py=rot(px,py,S(T*.02+px*.05+py*.05)*.2)
		local dx=ox+sc*px
		local dy=oy+sc*py
		dx=dx+S(dx*.04+T*.06)*2
		dy=dy+S(dy*.04+T*.03)*2
		circ(dx+1,dy+1,csz,bc+p.c-1)
		circ(dx,dy,csz,bc+p.c)
		--rect(dx,dy,sc+1,sc+1,bc+p.c)
	end
end
