sin=math.sin
cos=math.cos
abs=math.abs
max=math.max
min=math.min
pi=math.pi

t=0
offset=0
cls(8)

function uwu()
	-- head
	elli(120-20+2,60+offset+2,10,60,14)
	elli(120+20+2,60+offset+2,10,60,14)
	elli(120+2,100+offset+2,40,50,14)
	elli(120-20,60+offset,10,60,12)
	elli(120+20,60+offset,10,60,12)
	elli(120,100+offset,40,50,12)
	
	-- hat
	elli(120+1,70+offset+3,35,22,7)
	elli(120,70+offset+2,35,22,6)
	rect(120-40+1,70+offset+1,80,4,7)
	rect(120-40,70+offset,80,4,6)
	rect(120-35,74+offset,71,25,12)
	
	-- eyes
	ellib(120-16,90+offset,8,15,15)
	ellib(120+16,90+offset,8,15,15)
	elli(120-16,90+offset,6,7,15)
	circ(120-14,87+offset,2,12)
	circ(120-18,93+offset,1,12)
	elli(120+16,90+offset,6,7,15)
	circ(120+14,87+offset,2,12)
	circ(120+18,93+offset,1,12)
	
	-- snoot
	circb(120-10,120+offset,10,15)
	circb(120+10,120+offset,10,15)
	rect(120-20,109+offset,41,11,12)
	
	-- uniforms? What is this glsl
	circ(120,160+offset,20,12)
 rect(120-22,145+offset,20,6,6)
 rect(120+2,145+offset,20,6,6)
 rect(120-30,151+offset,60,60,7)
 line(120-3,151+offset,120-3,145+offset+60,6)
 for y=0,5 do
  circ(120,160+offset+y*8,2,15)
 end
 for y=0,1 do
  for x=0,8 do
  	rect(120+5+x*1,160+offset+y*3,2,3,(x*3+y*3)%14+1)
  end
 end
 
 for x=0,2 do
 	rect(120+4+x*5,170+offset,3,4,2)
 	elli(120+5+x*5,175+offset,1,2,4)
 end
 
 -- arms
 elli(120-30+sin(t/30*pi)*2,
		 172+offset,10,20,12)
 elli(120+30+sin(t/30*pi+pi/2)*2,
		 172+offset,10,20,12)
	
	-- very shorts
	local w=sin(t/30*pi)*3
	elli(120+17,266+offset,6+w,4+w,15)
	local w=sin(t/30*pi+pi/2)*3
	elli(120-17,266+offset,6+w,4+w,15)
	elli(120+17,241+offset+sin(t/30*pi)*5,10,20,12)
	elli(120-17,241+offset+sin(t/30*pi+pi/2)*5,10,20,12)
	rect(120-30,211+offset,60,30,6)
	tri(
		120-3,211+30+offset,
		120+3,211+30+offset,
		120,211+20+offset,0)
end

function TIC()
	
	vbank(1)
	cls()
	local str="General Uwu"
	for i=1,#str do
		local x=sin(t/20+i/4)*ffts(i,i+10)*10+20
		local y=i*20+sin(t/40)*100-50
	 print(str:sub(i,i),x+2,y,15,0,3)
	 print(str:sub(i,i),x,y,12,0,3)
	 print(str:sub(i,i),220-x+2,y,15,0,3)
	 print(str:sub(i,i),220-x,y,12,0,3)
	end
	uwu()
	
	vbank(0)
	offset=sin(t/40)*85-70
	t=t+1
end

function SCN(y)
	local p=((y-offset)^.5)+t/16
	local col=(p%2)*255
	poke(0x03FC0+8*3+0,col*(ffts(y/8,y/8+10)*.1))
	poke(0x03FC0+8*3+1,col*(ffts(y/8+10,y/8+20)*.1))
	poke(0x03FC0+8*3+2,col*(ffts(y/8+20,y/8+30)*.1))
end