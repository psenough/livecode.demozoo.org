rand=math.random
sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs

t=0

-- greets 2 roeltje, enfys, pumpuli
-- geekou, aldroid, xenearxn, lynn and
-- racoonviolet <3 (and and you)

-- h=32
function mnt(y,h,n)
 local xs=240/n
 rect(0,y+h*.6,240,h*.4,6)
 
 for i=0,n do
  tri(
   i*xs,y+h,
   (i+1)*xs,y+h,
   (i+.5)*xs,y,
   7)
  clip(0,y,240,h/3)
  tri(
   i*xs,y+h,
   (i+1)*xs,y+h,
   (i+.5)*xs,y,
   12)
  clip()
 end
end

function blt(sy,sh,dx,dy,dh)
 dx=dx%240
 ttri(
  0,dy,
  240,dy,
  0,dy+dh,
  dx,sy,
  240+dx,sy,
  dx,sy+sh,
  2,0)
 ttri(
  240,dy,
  0,dy+dh,
  240,dy+dh,
  240+dx,sy,
  dx,sy+sh,
  240+dx,sy+sh,
  2,0)
end

function fr(y,h,s)
 rect(0,y+h/2,240,h/2,7)
 clip(0,y,240,h)
	for i=0,h*30 do
	 local xp=rand()*240
		local yp=rand()*(h-4)+4
		circ(xp,y+yp,s,5)
		circ(xp,y+yp,s-1,6)
	end
	clip()
end

function ct(y,h,s)
--trace(y+h)
 rect(0,y+h/2,240,h/2,15)
 clip(0,y,240,h)
 local hs=s/2
 
	for yp=y,y+h do
	 for i=0,15 do
		 local w=rand()*hs*.5+hs*.5
			local h=rand()*hs+hs
		 local xp=rand()*240-hs/2
			--local yp=rand()*(h-4)
			rect(xp,y+yp,w,h,14)
			rect(xp+1,y+yp+1,w-2,h-2,13)
		end
	end
	clip()
end

function gr(y,h)
 rect(0,y+h/2,240,h/2,7)
 for x=0,239,.5 do
  line(
   x,y+h,
   x+rand()*4-2,
   y+rand()*h/2,
   6+rand()*2)
 end
end

function BOOT()
	cls()
	mnt(0,32,10)
	mnt(32,48,7)
	fr(80,16,2)
	fr(96,16,3)
	fr(112,16,4)
	memcpy(0x4000,0,16320)
	cls()
	ct(0,24,16)
	ct(24,24,32)
	gr(48,12)
	gr(60,12)
	gr(72,12)
	rd(84)
	rd(88)
	rd(92)
	memcpy(0x8000,0,16320)
	cls()
end

function rd(y)
 for yp=y,y+4 do
  for x=0,239 do
   pix(x,yp,rand()*3+13)
  end
 end
end

function TIC()
	-- prep src
	vbank(1)
	cls()
	memcpy(0,0x4000,16320)
	
	-- clr dst
	vbank(0)
	cls()
	
	-- copy layers
	-- mnt 0+24, 24+32
	blt(0,32,t,5,24)
	blt(32,48,t*1.2,0,48)
	
	-- clr src again
	vbank(1)
	cls()
	memcpy(0,0x8000,16320)
	
	-- ct 0,24 
	vbank(0)
 blt(0,24,t*1.3,30,24)
	--blt(24,24,t*1.9,40,24)
	
	-- clr src again
	vbank(1)
	cls()
	memcpy(0,0x4000,16320)
	
	-- dst
	vbank(0)
	-- fr 80+16
	blt(80,16,t*1.4,40,16)
	blt(96,16,t*1.5,48,16)
	blt(112,16,t*1.6,56,16)
	
	-- clr src again
	vbank(1)
	cls()
	memcpy(0,0x8000,16320)
	
	vbank(0)
	--gr 48 72+12
	blt(48,12,t*1.7,62,12)
	blt(60,12,t*1.8,70,12)
	blt(72,12,t*1.9,78,12)
	blt(48,12,t*2,86,12)
	blt(60,12,t*2.1,92,12)
	blt(72,12,t*2.2,100,12)
	
	-- rd84 92
	blt(84,4,t*2.3,108,4)
	blt(88,4,t*2.4,112,4)
	blt(92,4,t*2.5,116,4)
	blt(84,4,t*2.6,120,4)
	blt(88,4,t*2.7,124,4)
	blt(92,4,t*2.8,128,4)
	blt(84,4,t*2.9,132,4)
	
	vbank(1)
	cls()
	
	b=fft(0,10)
	--print("=^^=",7,32-b*10,0,0,10)
	--print("=^^=",5,30-b*10,12,0,10) 
	
	vbank(0)
	
	rect(80,110,80,15,3)
	rect(100,110-20,30,20,3)
	rect(102,110-18,26,16,14)
	circ(90,125,7,14)
	circ(90,125,5,13)
	circ(150,125,7,14)
	circ(150,125,5,13)
	
	elli(110,100,8,6,13)
	elli(118,101,8,2,13)
	elli(125,100,1,1,15)
	circ(112,97,2,12)
	circ(112,97,1,15)
	
	--92
	elli(130+46,72,52,8,12)
	ellib(130+46,72,52,8,15)
	
	--circ(128,93,1,10)
	tri(
	 150,78,
		160,78,
		128,93,
		12)
	line(150,78,128,93,15)
	line(160,78,128,93,15)
	print("GOIN TO BUELFEST!",130,70,15)
	--print("GOIN TO BUELFEST!",129,70,12)
	t=t+2
end

function SCN(y)
	poke(16320,128)
	poke(16321,128)
	poke(16322,255-y)
end