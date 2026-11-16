-- greets to vurpo, violet, tobach,
-- jtruk, HeNeArXn and u
ot=0
sin=math.sin
cos=math.cos
abs=math.cos

function b(x,y,h,t) -- 13-15
 local w=h/2
 --rectb(x-w/2,y-h/2,w,h,12)
 -- body
 elli(x,y+h/4,w/3,h/4,14)
 elli(x,y+h/4-1,w/3-1,h/4-1,13)
 -- legs
 elli(x-h/8,y+h/2.2,w/10,w/12,14)
 elli(x-h/8,y+h/2.2,w/10-1,w/12-1,13)
 elli(x+h/8,y+h/2.2,w/10,w/12,14)
 elli(x+h/8,y+h/2.2,w/10-1,w/12-1,13)
 
 
 local hx=x+sin(t/10)^3*w/8
 local hy=y-h/12+abs(sin(t/10))*4
 -- ears
 elli(hx-w/8,hy-h/6,w/12,h/8,14)
 elli(hx+w/8,hy-h/6,w/12,h/8,14)
 elli(hx-w/8,hy-h/6,w/12-1,h/8-1,13)
 elli(hx+w/8,hy-h/6,w/12-1,h/8-1,13)
 --head
 elli(hx,hy,w/4,h/8,14)
 elli(hx,hy-1,w/4-1,h/8-1,13)
 circ(hx-w/8,hy-h/32,h/40,15)
 circ(hx+w/8,hy-h/32,h/40,15)
 circ(hx-w/8,hy-h/32-1,h/160,12)
 circ(hx+w/8,hy-h/32-1,h/160,12)
end

function bb(x,y,h,t)
 local w=h/2
 --rectb(x-w/2,y-h/2,w,h,12)
 -- legs
 elli(x-h/8,y+h/2.2,w/10,w/12,14)
 elli(x-h/8,y+h/2.2,w/10-1,w/12-1,13)
 elli(x+h/8,y+h/2.2,w/10,w/12,14)
 elli(x+h/8,y+h/2.2,w/10-1,w/12-1,13)
 
 local hx=x+sin(t/10)^3*w/8
 local hy=y-h/12+abs(sin(t/10))*4
 -- ears
 elli(hx-w/8,hy-h/6,w/12,h/8,14)
 elli(hx+w/8,hy-h/6,w/12,h/8,14)
 elli(hx-w/8,hy-h/6,w/12-1,h/8-1,13)
 elli(hx+w/8,hy-h/6,w/12-1,h/8-1,13)
 --head
 elli(hx,hy,w/4,h/8,14)
 elli(hx,hy-1,w/4-1,h/8-1,13)
 
 -- body
 elli(x,y+h/4,w/3,h/4,14)
 elli(x,y+h/4-1,w/3-1,h/4-1,13)
 local bx=x-sin(t/10)^5*w/18
 local by=y+h/2.6-abs(cos(t/10))*w/32
 elli(bx,by,w/3,h/7,14)
 elli(bx,by-1,w/3-1,h/7,13)
 
 circ(bx,by+h/30,w/8,12)
end

function TIC()
	vbank(0)
 cls(10)
 
 if ot/60%8<4 then
 	rect(0,100,240,36,6)
  for j=0,3 do
  	local y=40+j*10
	 	for i=0,5 do
	   local x=(i*60-ot*2+y*2.5)%360-60
	  	bb(x,y,120,ot+i*3+j*4)
			end
  end
 else
 	rect(0,50,240,136-50,6)
  for j=0,8 do
   local y=0+j*20
 		for i=0,9 do
  		x=(i*30-ot+y/2)%300-30
	 		b(x,y,60+j*4,ot+i*3+j*4)
			end
	 end
	end
	
	vbank(1)
	cls()
	for i=1,15 do
		print("bnuy multiplier",
			30+sin(ot/20+i/10+sin(ot/37+i/10))*20,
			50+cos(ot/30+i/10+cos(ot/33+i/10))*20,
			(i+ot/4)%15+1,0,2)
 end
 ot=ot+1
end
