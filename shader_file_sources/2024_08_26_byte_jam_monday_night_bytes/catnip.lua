-- pos: 0,0
sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi
rand=math.random
max=math.max

for i=0,15 do
 if i==15 then
 	poke(16320+i*3+0,255)
 	poke(16320+i*3+1,200)
 	poke(16320+i*3+2,0)
 else
 	poke(16320+i*3+0,i*8)
 	poke(16320+i*3+1,i*8)
 	poke(16320+i*3+2,i*7.5)
 end
end
vbank(1)
for i=0,15 do
 if i==15 then
 	poke(16320+i*3+0,255)
 	poke(16320+i*3+1,200)
 	poke(16320+i*3+2,0)
 else
 	poke(16320+i*3+0,i*8)
 	poke(16320+i*3+1,i*8)
 	poke(16320+i*3+2,i*7.5)
 end
end

t=0

function cl()
	--if fft(0,10)<0.7 then
	 --memcpy(0,120,16320-120)
		--for i=0,5000 do
		 --pix(rand()*240, rand()*136,0)
		--end
		for y=0,135 do
		 for x=t%2,240,2 do
			 pix(x,y,max(0,pix(x,y)+rand()*2-1))
			end
		end
	--else
		--cls()
	--end
end

bt=0

function owl()
 -- now draw the rest of the fucking
 -- owl
  
 -- wings
 local y=sin(t/12+.1)*30+60
 local yo=cos(t/12)
 local yt=0
 for i=0,17 do
  --local sx=6-(i/17)*2
 	local x=36+i*4
  local yp=y-yt
  yt=i<10 and yt+yo or yt+yo*3
  local h=abs(i-10) --10..0..7
  h=(10-h)/20+.5
  for j=0,8 do
  	elli(120-x,yp+4-j*2*h,6,4,1+j*1.5)
  	elli(120+x,yp+4-j*2*h,6,4,1+j*1.5)
  end
 end
  
 -- body
 y=sin(t/12-.1)*30+60
 elli(120,y+5,36,23,10)
 
 -- head
 y=sin(t/12)*30+60
 elli(120,y,30,20,14)
 elli(120-10,y-5,5,5,15)
 elli(120+10,y-5,5,5,15)
 elli(120-10,y-5,3,3,0)
 elli(120+10,y-5,3,3,0)
 tri(120,y+10,120-4,y,120+4,y,5)
 tri(
 	120-10,y-15,
  120-15,y-13,
  120-27,y-30,
  12)
 tri(
 	120-15,y-13,
  120-19,y-12,
  120-28,y-30,
  10)
 tri(
 	120+10,y-15,
  120+15,y-13,
  120+27,y-30,
  12)
 tri(
 	120+15,y-13,
  120+19,y-12,
  120+28,y-30,
  10)
 --for i=0,15 do
  --rect(i*10,0,10,10,i)
 --end
end
vbank(0)
cls()

function TIC()
	vbank(0)
	memcpy(0,0x4000,16320)
 

	vbank(1) 
	local p0={x=sin(bt/25)*4,y=sin(bt/26)*4}
	local p1={x=240+sin(bt/27)*4,y=sin(bt/28)*4}
	local p2={x=sin(bt/29)*4,y=136+sin(bt/30)*4}
	local p3={x=240+sin(bt/31)*4,y=136+sin(bt/32)*4}
	ttri(
		0,0,
		240,0,
		0,136,
		p0.x,p0.y,
		p1.x,p1.y,
		p2.x,p2.y,
		2) 
	ttri(
		240,0,
		0,136,
		240,136,
		p1.x,p1.y,
		p2.x,p2.y,
		p3.x,p3.y,
		2)
	cl()
 local b=fft(0,10)
	--print("=^^=",5,50-b*30,12,0,10)
	owl()
	memcpy(0x4000,0,16320)
	t=t+1.5
	bt=bt+fft(5,10)
end

function SCN(y)
 --poke(0x3FF9,fft(y,y+10)*50)
end