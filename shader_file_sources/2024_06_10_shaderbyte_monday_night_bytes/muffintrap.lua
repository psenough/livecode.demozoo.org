sin=math.sin
cos=math.cos
abs=math.abs
random=math.random

cx=120
cy=68
sw=240
sh=136
deltatime=1/60

balls=4
ballist={}
for b=1,balls do
	ballist[b]={x=-1+(b/balls)*2,y=-1+(b/balls)*2,z=0,
	vx=0.04,vy=0.001,vz=0.005,
	c=4+b%5}
end
gravity=0.01
offz=0.2
minz=0.001
maxz=1.0

--wallnumbers
BACK=0
LEFT=1
RIGHT=2
TOP=3
BOTTOM=4
hits={}

function addHit(wall)
	col=1+random(15)
	table.insert(hits,
			{w=wall,c=col,t=2.0})

	return col
end


function TIC()
	cls(0)
	t=time()//32
	
	-- Draw the room???
	tz=offz+minz
	blx=cx+-1.0*cx*tz
	brx=cx+1*cx*tz
	bby=cy+1*cy*tz
	bty=cy-1*cy*tz
	
	flx=cx-1*cx*maxz
	frx=cx+1*cx*maxz
	fby=cy+1*cy*maxz
	
	removehit=0
	for h=1,#hits do
		--draw the wall	
		hi=hits[h]
		hi.t=hi.t-deltatime
		if hi.t>0 then
			if hi.w==BACK then
				tri(blx,bby,
						blx,bty,
						brx,bty, hi.c)
				tri(blx,bby,
						brx,bby,
						brx,bty, hi.c)
			elseif hi.w==LEFT then
				tri(blx,bby,
						flx,fby,
						flx,fty, hi.c)
				tri(flx,fty,
						blx,bty,
						blx,bby, hi.c)
			elseif hi.w==RIGHT then
				tri(brx,bby,
						frx,fby,
						frx,fty, hi.c)
				tri(frx,fty,
						brx,bty,
						brx,bby, hi.c)
			elseif hi.w==BOTTOM then
				tri(blx,bby,
						brx,bby,
						frx,fby, hi.c)
				tri(flx,fby,
						blx,bby,
						frx,fby, hi.c)
			end
		else
			removehit=h
		end
	end
	if removehit>0 then
		table.remove(hits,h)
	end
	
	
	line(blx,bby,brx,bby,12)
	line(blx,bty,brx,bty,12)
	line(blx,bby,flx,fby,12)
	line(brx,bby,frx,fby,12)
	line(blx,bby,blx,bty,12)
	line(brx,bby,brx,bty,12)
	line(blx,bty,flr,fty,12)
	line(brx,bty,frx,fty,12)
	
	
	
	for b=1,#ballist do
		bi=ballist[b]
		bi.x=bi.x+bi.vx
		
		bi.vy=bi.vy+gravity
		bi.y=bi.y+bi.vy
		
		bi.z=bi.z+bi.vz

		if bi.x>2 then
			bi.x=2
			bi.vx=bi.vx*-1
			bi.c=addHit(RIGHT)
		elseif bi.x<-2 then
			bi.x=-2
			bi.vx=bi.vx*-1
			bi.c=addHit(LEFT)
		end
		
		if bi.y>1 then
			bi.y=1
			bi.vy=-0.2
			bi.c=addHit(BOTTOM)
			
		end
		
		-- Dont divide by zero
		-- and drive
		if bi.z<=minz then
			bi.z=minz
			bi.vz=bi.vz*-1
			table.insert(hits,
			{w=BACK,c=4+random(4),t=1.0})
		elseif bi.z>0.8 then
			bi.z=0.8
			bi.vz=bi.vz*-1
		end
		
		dz=bi.z
		
		dx=bi.x*dz
		dy=bi.y*dz
		
		circ(
			cx+dx*cx,
			cy+dy*sh,
			5+bi.z*30,bi.c)
		circ(
			cx+(dx-0.015)*cx,
			cy+(dy-0.015)*sh,
			bi.z*20,12)
	end
	table.sort(ballist, ballsorter)
	
	print("Henlo",cx-22,20,12)
	
end 

function ballsorter(a,b)
	return a.z < b.z
end
	
