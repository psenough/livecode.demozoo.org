-- pos: 4,85
sin=math.sin
cos=math.cos
t=0

h={0,0,0,0,0,0,0,0}
cls(0)
function BOOT()
	for i=-255,255 do
--		line(i,bl,i,bl-fft(i)*100,0)
  h[math.floor(i)]=0.
	end
end
c=0
t=0
 x=1
 y=1
 
 xd=1
 yd=1
function TIC()
 vbank(1)
 cls(0)
 if t%100<80 then
 cprint("BYTEJAM",120,136/2,8,5)
 end
 
 vbank(0)


--	cls(13)
--	spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
	t=t+1
	bl=y
	for i=0,47 do
		poke(16320+i,sin(i)^2*255)
	end
	for i=0,150 do
	xx=math.random(0,240)
	yy=math.random(0,136)
	pix(xx,yy,0)
	end
	scale=50
	for i=0,240 do
	 f=fft((i-x)%240)
		if f>0.01 then
		line(i,bl+f*scale,
		i,bl-f*scale,t)
		end
--  h[i]=0.
	end
	if y>136 then	yd=-1 	end
	if y<0 then 	yd=1 	end
	if x>240 then	xd=-1 	end
	if x<0 then 	xd=1 	end
 --circ(x,y,5,0)
 x=x+xd
 y=y+yd
end

function b()
 x0=120
 y0=140--(140-t)%(136+50)
 steps=41
 div=(20+math.sin(t/100)*10)
 r=40
 vbank(1)
 for i=-steps/2,steps/2 do
  id=i/div
  ip=i+steps//2
  f=fft(255/steps*ip,255/steps*(ip+1))
  f=f+1

--  print(diff)
  c=7
 	line(x0+sin(id)*r,y0-cos(id)*r,
  x0+sin(id)*(r+f*30),y0-cos(id)*(r+f*30)
  ,t//10)
--  h[ip]=p
 end 
end

function cprint(text,x,y,c,s)
 width=print(text,0,-200,c,false,s)
 print(text,x-width/2,y,c,false,s)
end