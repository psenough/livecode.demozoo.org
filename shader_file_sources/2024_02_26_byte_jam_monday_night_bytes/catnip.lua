sin=math.sin
cos=math.cos
abs=math.abs
rand=math.random
min=math.min
max=math.max

t=0

pointsB={{x=70,y=50},{x=63,y=67},{x=77,y=86},{x=99,y=59},{x=117,y=47},{x=157,y=50},{x=107,y=85},{x=153,y=86},{x=174,y=65},{x=171,y=40},{x=189,y=56},{x=181,y=35},{x=198,y=35},{x=205,y=45},{x=211,y=56},{x=211,y=46},{x=189,y=33},{x=188,y=22},{x=58,y=46},{x=51,y=55},{x=44,y=41},{x=37,y=50},{x=30,y=38},{x=25,y=48},{x=15,y=39},{x=13,y=50},{x=4,y=40},{x=2,y=49},{x=102,y=101},{x=81,y=103},{x=97,y=116},{x=88,y=121},{x=106,y=130},{x=101,y=135},{x=114,y=135},{x=114,y=129},{x=139,y=88},{x=146,y=108},{x=156,y=108},{x=159,y=128},{x=150,y=129},{x=152,y=135},{x=167,y=135},{x=166,y=128},{x=214,y=48}}
points={}
pointsL={}

idxs={
	-- body 1-9
{2,1,3},{1,3,4},{4,1,5},{5,4,6},{4,3,7},{7,6,4},{6,7,8},{6,8,9},{8,7,37},
	-- neck 10-11
{6,9,10},{9,10,11},
	-- head 12-18
{10,11,12},{12,11,13},{13,11,14},{14,11,15},{14,15,16},{12,13,17},{17,12,18},
	-- tail 19-28
{1,2,19},{19,2,20},{19,20,21},{21,20,22},{22,21,23},{23,22,24},{24,23,25},{25,24,26},{25,26,27},{27,26,28},
	-- leg b 29-36
{7,3,29},{3,29,30},{29,30,31},{31,30,32},{31,32,33},{33,32,34},{33,34,35},{35,33,36},
	-- leg f 37-43
{37,8,38},{38,8,39},{39,38,40},{40,38,41},{41,40,42},{40,42,43},{40,43,44},{16,15,45}}

body={1,9}
head={10,18}
tail={19,28}
legR={29,36}
legF={37,43}
cat={body,head,tail,legR,legF}

for j=0,1 do
 vbank(j)
 for i=0,47 do 
  poke(16320+i,i*5*(i%3==1 and 1 or .2))
 end
end

function tx(a,b,c,d,e,f)
	local col=10--(a.x+b.x+c.x)/3
 ttri(
  a.x,a.y,
  b.x,b.y,
  c.x,c.y,
  d.x,d.y,
  e.x,e.y,
  f.x,f.y,
  2
 )
end

memset(0x4000,0,16320)

rp={}
for i=1,50 do
 rp[i]={x=rand()*240,y=rand()*136}
end

function update()
 -- copy last
 for i=1,#pointsB do
  pointsL[i]=points[i] or pointsB[i]
 end
 
 local xo=cos(t/15+1)*20
 local yo=sin(t/20)*10
	--cat={body,head,tail,legR,legF}
	-- iterate through parts
	for j=1,#cat do
	  -- Iterate through triangles
		for i=cat[j][1],cat[j][2] do
			
			if j==1 then --body
			 --y=y+sin(
			end
			
		 local ids=idxs[i]
			for k=1,#ids do
				local id=ids[k]
			 local x=xo
				local y=yo
				local px=pointsB[id].x
				local py=pointsB[id].y
				
				if j==1 then
				 --body
					--local s=max(0,
					 --abs(px-120)-40
						--)/20
					--py=py+sin(t/20+px/10)*20
					--py=py+40
				end
				if px>160 then
				 --head
					--local s=max((px-160),0)/20
					--py=py+sin(t/20+px/10)*20*s
					--py=py-abs(sin(t/20))*5*s
				end
				if j==3 then
				 --tail
					--local s=max(-(px-70),0)/60
					--py=py+sin(t/40+px/10)*20*s
				end
				if j==4 then
				 s=max(0,py-100)/2
				 px=px+cos(t/10)*s-s
				end
				if j==5 then
				 s=max(0,py-100)/2
				 px=px+sin(t/10)*s-s
				end
				
			 points[id]={
				 x=px+x,
					y=py+y-15
				}
			end
		end
	end
end

function TIC()
	cls()
	vbank(0)
	memcpy(0,0x4000,16320)
	
	vbank(1)
	local ofx=-1--sin(t/146)
	local ofy=0--cos(t/149)
	tx(
	 {x=ofx,y=ofy},
	 {x=480+ofx,y=ofy},
	 {x=ofx,y=272+ofy},
	 {x=0,y=0},
	 {x=480,y=0},
	 {x=0,y=272}
	)
	
	update()
	
	for j=1,#cat do
	 for i=cat[j][1],cat[j][2] do
		 local ids=idxs[i]
		 local a=points[ids[1]]
		 local b=points[ids[2]]
		 local c=points[ids[3]]
		 local d=pointsL[ids[1]]
		 local e=pointsL[ids[2]]
		 local f=pointsL[ids[3]]
			tx(a,b,c,d,e,f)
		end
	end
	
	--for i=1,#rp do
	 --pix(rp[i].x,rp[i].y,i+t/8)
		--rp[i].x=(rp[i].x+rand()*2-1)%240
		--rp[i].y=(rp[i].y+1)%136
		
	--for i=0,50 do
	 --elli(
		 --rand()*240,rand()*136,
			--rand()*3,rand()*2,
			--rand()*16
		--)
	--for y=0,17 do
		--for x=0,40 do
	for i=0,5 do
	 local x=rand()*40//1
		local y=rand()*17//1
		 print(
			 string.char(rand(65, 65 + 25)),
			 x*6,y*8,
				rand()*16)
		--end
	end
	
	memcpy(0x4000,0,16320)
	t=t+1
end
