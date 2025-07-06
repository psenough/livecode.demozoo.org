-- Boom bap original cat
-- Greets to violet, vurpo, aldroid,
-- mantratronic and jtruk. AND YOU


 poke(0x03FC0+6,255)
 poke(0x03FC0+7,150)
 poke(0x03FC0+8,150)
 
cls(1)
elli(120,80,40,40,3)
elli(120-25,15,8,10,3)
elli(120-25,15,6,8,4)
elli(120+25,15,8,10,3)
elli(120+25,15,6,8,4)
elli(120,40,40,30,3)
elli(121,39,38,27,4)
elli(120,60,10,6,3)
elli(121,59,8,5,4)
elli(120-8,60,1,4,12)
elli(120+8,58,1,4,12)
elli(120-10,50,12,8,3)
elli(120+10,50,12,8,3)
elli(120-9,49,10,7,4)
elli(120+11,49,10,7,4)

elli(120-10,30,6,8,12)
elli(120+10,30,6,8,12)
ellib(120-10,30,6,8,3)
ellib(120+10,30,6,8,3)
circ(120,45,4,2)

line(120-15,47,120-30,40,12)
line(120-15,50,120-32,50,12)
line(120-15,53,120-30,60,12)
line(120+15,47,120+30,40,12)
line(120+15,50,120+32,50,12)
line(120+15,53,120+30,60,12)

px=2 py=2
ppx=120 ppy=68
lx=ppx ly=ppy
t=0
sp=15

function TIC()
	vbank(0)
	-- table
	rect(0,70,240,66,14)
	vbank(1)
	cls()
	for x=0,2 do
	 for y=0,2 do
		 ox=x*60+60
			oy=y*20+80+4
		 elli(ox,oy,20,8,15)
			if px==x and py==y then
			 h=sp/4-math.abs(t%sp-sp/2)/2
			 elli(ox,oy,18,6,2)
				rect(ox-18,oy-h,37,h,2)
			 elli(ox,oy-h,18,6,2)
				line(ox-12,oy+4,ox-12,oy+4-h,12)
				line(ox-14,oy+3,ox-14,oy+3-h,12)
			end
		end
	end
	
	-- eyes
	ox=(px-1)*2
	oy=(py)+2
	elli(120-10+ox,30+oy,3,3,15)
	elli(120+10+ox,30+oy,3,3,15)
 t=t+1
 if t%sp==0 then
  lx=px
  ly=py
  px=math.random()*3//1
  py=math.random()*3//1
 end
 
 -- bapper
 int=(t%sp)/sp
 bx=(px*int)+(lx*(1-int))
 bx=bx*60+60
 by=(py*int)+(ly*(1-int))
 by=by*20+74
 by=by-math.abs(math.sin(int*3))*20
		 --ox=x*60+60
			--oy=y*20+80+4
 tri(
  120,70,
  bx,by,
  bx+20,by,
  3
 )
 tri(
 	120,70,
  160,70,
  bx+20,by,
  3
 )
 tri(
 	155,60,
  160,70,
  bx+20,by,
  3
 )
 elli(bx,by,20,14,3)
 elli(bx+1,by-1,18,12,4)
 elli(bx,by+8,10,7,3)
 elli(bx+1,by-1+10,8,5,4)
 elli(bx-20,by+8,10,7,3)
 elli(bx-20+1,by-1+10,8,5,4)
 elli(bx+20,by+8,10,7,3)
 elli(bx+20+1,by-1+10,8,5,4)
 vbank(0)
end

function SCN(y)
 poke(0x03FC0+3,math.sin((t/60+y/40))*128+128)
 poke(0x03FC0+4,math.sin((t/60+y/40+2))*128+128)
 poke(0x03FC0+5,math.sin((t/60+y/40+4))*128+128)
end