abs=math.abs
sin=math.sin
cos=math.cos

function BOOT()
	cls(14)
	for i=0,10 do
	 print("BUDDY",40+i,15+i,i,0,4)
	 print("SALTERTON",10+i,45+i,i,0,4)
	end
	for y=89,135 do
	 for x=0,239 do
			local v=(x-120) / ((y-89)/80+1)
			pix(x,y,4-(v%8<2 and 1 or 0))
		end
	end
end

function SCN(y)
	vbank(0)
	if y<85 and y>10 then
		poke(0x03FF9,sin(time()/400+y/40)*100%240-120)
		poke(0x03FFa,(sin(-time()/100)*5))
	else
	 poke(0x03FF9,0)
	 poke(0x03FFa,0)
	end
end

function TIC()
 t=time()//32
 vbank(1)
 cls()
 
 fposl={
  x=abs(t%400-200)+20,
  y=130-abs(sin(t/8)*10)
 }
 fposr={
  x=abs((t+36)%400-200)+20,
  y=130-abs(cos(t/8)*10)
 }
 
 elli(fposl.x,fposl.y,10,5,15)
 elli(fposr.x,fposr.y,10,5,15)
 
 bpos={
  x=(fposl.x+fposr.x)/2,
  y=60-abs(cos(t/4)*10)
 }
 elli(bpos.x,bpos.y,30,35,2)
 elli(bpos.x-1,bpos.y-2,27,32,3)
 elli(bpos.x-2,bpos.y-4,24,28,4)
 
 tri(
 	bpos.x,bpos.y-30,
  bpos.x-4,bpos.y,
  bpos.x+4,bpos.y,
 	15
 )
 tri(
 	bpos.x,bpos.y+6,
  bpos.x-4,bpos.y,
  bpos.x+4,bpos.y,
 	15
 )
 a={
  x=12,
  y=30
 }
 fposl.y=fposl.y-5
 fposl.x=fposl.x-5
 fposr.y=fposr.y-5
 fposr.x=fposr.x+5
 for i=0,.5,.1 do
  circ(
   mix(bpos.x+a.x+10*i,fposl.x,i),
   mix(bpos.y+a.y,fposl.y,i),
   5,4-i*4)
  circ(
   mix(bpos.x-a.x-10*i,fposr.x,i),
   mix(bpos.y+a.y,fposr.y,i),
   5,4-i*4)

  circ(
   mix(bpos.x+a.x+10*(.5-i),fposl.x,i+.5),
   mix(bpos.y+a.y,fposl.y,i+.5),
   5,2+i*4)
  circ(
   mix(bpos.x-a.x-10*(.5-i),fposr.x,i+.5),
   mix(bpos.y+a.y,fposr.y,i+.5),
   5,2+i*4)
 end
 
 hpos={
  x=bpos.x,y=bpos.y-30-abs(sin(t/8))*10
 }
 elli(hpos.x,hpos.y+2,12,14,2)
 elli(hpos.x,hpos.y,12,14,4)
 elli(hpos.x,hpos.y+6,6,4,12)
 rect(hpos.x-6,hpos.y+2,12,4,4)
 elli(hpos.x-4,hpos.y-2,3,2,12)
 elli(hpos.x-4,hpos.y-2,1,1,15)
 elli(hpos.x+4,hpos.y-2,3,2,12)
 elli(hpos.x+4,hpos.y-2,1,1,15)
 elli(hpos.x-4,hpos.y-11,6,4,15)
 elli(hpos.x+5,hpos.y-10,5,3,15)
 elli(hpos.x-8,hpos.y-7,4,6,15)
 elli(hpos.x+8,hpos.y-7,4,6,15)
 rect(hpos.x-10,hpos.y,3,7,15)
 rect(hpos.x+7,hpos.y,3,7,15)
 elli(hpos.x,hpos.y+1,2,4,2)
 
 -- arms
 a={
  x=23,
  y=-20
 }
 armr={
 	x=bpos.x+a.x+sin(t/10)*20,
  y=bpos.y+a.y+sin(t/7.57)*20,
 }
 armr2={
 	x=armr.x+sin(t/8.246)*16,
  y=armr.y+sin(t/12.57)*16,
 }
 arml={
 	x=bpos.x-a.x+cos(t/10)*20,
  y=bpos.y+a.y+cos(t/7.57)*20,
 }
 arml2={
 	x=arml.x+cos(t/8.246)*16,
  y=arml.y+cos(t/12.57)*16,
 }
 for i=0,.5,.1 do
 	circ(
 		mix(bpos.x+a.x,armr.x,i*2),
  	mix(bpos.y+a.y,armr.y,i*2),
  	5,2+i*4)
 	circ(
 		mix(armr.x,armr2.x,i*2),
  	mix(armr.y,armr2.y,i*2),
  	5,2+i*4)
 	circ(
 		mix(bpos.x-a.x,arml.x,i*2),
  	mix(bpos.y+a.y,arml.y,i*2),
  	5,2+i*4)
 	circ(
 		mix(arml.x,arml2.x,i*2),
  	mix(arml.y,arml2.y,i*2),
  	5,2+i*4)
 end
end

function mix(a,b,t)
	return a*(1-t)+b*t
end