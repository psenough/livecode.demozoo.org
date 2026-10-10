-- Hello MNB :)
-- Greetz: Suule, Aldroid, HeNeArXn
-- Reality, Polynomial!
-- And you. Greetz to you.
-- Double Greetz if you're one of
-- those mentioned above!

T=0

NMAGS=500
NFILINGS=500

T=0
R,S,C=math.random,math.sin,math.cos
MIN,MAX=math.min,math.max

MAGNET=false

SCENES={}
SCENE=nil

FILINGS={}

function BOOT()
	cls()
	makeScene1()
	SCENES[#SCENES+1]=pluckScene()
	cls()
	makeScene2()
	SCENES[#SCENES+1]=pluckScene()
	cls()
	makeScene3()
	SCENES[#SCENES+1]=pluckScene()
	
	SCENE=SCENES[1]
	
	for i=0,NFILINGS do
	 local x,y=R(239),R(100)
	 FILINGS[#FILINGS+1]={
			x=x,y=y,aimX=x,aimY=y,
			seed=R(1000)/1000
		}
	end

	vbank(0)	
	setRGB(1,250,218,211)
	setRGB(15,0,0,0)

	vbank(1)	
	for i=1,15 do
		local f=i/15*255
		setRGB(i,f,f,f)
	end
end

TSWITCH=100
function TIC()
	if (T//TSWITCH)%2==0 then
	 if T%TSWITCH==0 then
			SCENE=SCENES[R(1,#SCENES)]
			setFilingAims()
		end
		MAGNET=true
	else
		MAGNET=false
	end

	vbank(0)
	cls()
	drawWilly()
		
	vbank(1)
	cls()
	doFilings()
	drawFilings()
	local text="Wooly Willy"
	for iy=-1,1 do
		for ix=-1,1 do
			print(text,63+iy,120+ix,4+ix-iy*3,false,2)
		end
	end
	print(text,63,120,12,false,2)
	print("jtruk",208,129,3)
	T=T+1
end


function makeScene1()
	tri(120,50,150,50,140,70,1)
	tri(120,50,150,50,130,70,1)
	tri(80,40,170,55,150,60,1)
	rect(85,80,70,40,1)
	elli(120,100,20,10,0)
end

function makeScene2()
	rect(95,35,20,10,1)
	rect(125,35,20,10,1)
	circ(80,50,10,1)
	circ(160,50,10,1)
end

function makeScene3()
	tri(110,110,130,110,120,130,1)
	circ(120,20,10,1)
	circ(110,25,10,1)
	circ(130,25,10,1)
end

function pluckScene()
	local ps={}
	for i=1,10000 do
		local x=R(239)
		local y=R(135)
		if pix(x,y)>0 then
			ps[#ps+1]={
				x=x,y=y
			}
		end
		
		if #ps==NMAGS then
			return ps
		end
 end
 return ps
end

function doFilings()
	for i,f in ipairs(FILINGS) do
		if MAGNET then
			f.x=f.x+(f.aimX-f.x)*.1
			f.y=f.y+(f.aimY-f.y)*.1
		else
			f.y=MIN(f.y+1+f.seed,130)
			f.x=MIN(MAX(65,f.x+R(100)/100-.5),175)
		end
	end	
end

function drawFilings()
	for i,f in ipairs(FILINGS) do
		local r=(f.x^4+f.y^7)
		local x1=f.x+S(r)*2
		local x2=f.y+C(r)*2
		local c=8+S(f.x+f.y+r)*7
	 line(f.x,f.y,x1,x2,c)
	end
end

function setFilingAims()
	for i,f in ipairs(FILINGS) do
	 local p=SCENE[R(1,#SCENE)]
		
		f.aimX,f.aimY=p.x,p.y
	end
end

function drawWilly()
	-- ^ No need to worry folks.
	-- trust jtruk!
	rect(60,5,120,130,4)
	elli(120,68,40,50,1) -- face
	elli(80,68,6,20,1) -- left ear
	elli(160,68,6,20,1) -- right ear
	elli(120,95,20,5,12)	-- mouth
	elli(120,88,20,8,1)	-- mouth
	drawEye(106,58)
	drawEye(134,58)
	elli(120,73,20,10,2)	--nose
	elli(120,69,8,3,12)	--nose highlight
end

function	drawEye(x,y)
	elli(x,y,10,12,12)
	elli(x,y,10,12,12)
	elli(x,y+6,6,8,15)
	elli(x,y+5,2,2,12)
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BDR(y)
	vbank(0)
	setRGB(0,100-y/2,0,y)
end