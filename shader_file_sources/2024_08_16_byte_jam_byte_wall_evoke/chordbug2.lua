-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon

function rnd(n)
 return math.floor(math.random()*n)
end
function p(t,x,y,s)
	print(t,x-1,y,0,false,s)
	print(t,x+1,y,0,false,s)
	print(t,x,y-1,0,false,s)
	print(t,x,y+1,0,false,s)
	print(t,x,y,12,false,s)
	
end

function TIC()
	local t=time()*.002
	cos=math.cos sin=math.sin atan2=math.atan2
	min=math.min max=math.max
	
	local pal={4,3,5,1,12}
	for yy=0,0 do
		for x=0,239 do
			c=0
			line(x,0,x,140,0)
			for i=1,8 do
	  	sx=60+5*i
		  mx=230-15*i
				k=sin(t)+1.4
				h=(sin(t+x/sx)*.4+x/mx+i*k/14)*99-12
				-- if rnd(99)<3 then h=h+2-rnd(3) end
				-- h=2*math.floor(h/2)
				line(x,h,x,140,i)
		  --if h<y then c=i+7 end
			end
			--pix(x,y,8+math.sin(d*.1+a-t)*3)
		end
	end
	w=240
	h=135
	line(5,5,15,5,12)
	line(5,5,5,15,12)
	line(w-5,5,w-15,5,12)
	line(w-5,5,w-5,15,12)
	
	line(5,130,15,130,12)
	line(5,130,5,120,12)
	line(w-5,130,w-15,130,12)
	line(w-5,130,w-5,120,12)
	
	p("PLAY " .. (time()%2000<1000 and ">" or""),15,15,1)
	minute = tstamp()/60%60
	hour = (tstamp()/3600+2)%24
	ts = ("%02d:%02d"):format(math.floor(hour),math.floor(minute))
	p("AUG 17 2024 "..ts, 15,115,1)
	p(" foldr.moe", 170,15,1)

 poke(0x14604+62*8+0,2)
 poke(0x14604+62*8+1,6)
 poke(0x14604+62*8+2,14)
 poke(0x14604+62*8+3,6)
 poke(0x14604+62*8+4,2)
 for y=0,135 do
  if  rnd(19)<sin(t/2+y/77)*9 then
  memcpy(y*120, y*120+2-rnd(3), 118)
  end
 end
end