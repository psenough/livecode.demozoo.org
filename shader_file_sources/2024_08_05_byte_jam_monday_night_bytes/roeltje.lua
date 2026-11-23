--Hello this is Roeltje!
W,H=240,136
W2,H2=120,68
sin,cos=math.sin,math.cos
min,max=math.min,math.max
rnd=math.random

stars={}
function BOOT()
	for i=0,50 do
		table.insert(stars,v2(rnd(0,W),rnd(0,H2)))
	end
end

cls(0)
function TIC()
	cls(0)
	t=time()/1000
	local m=H2
	
	for i=1,#stars do
		--stars[i].x=(stars[i].x+1)%W
		pix(stars[i].x,stars[i].y,12)
	end
	
	for y=0,H do for x=0,W do
		--c=pix(x+rnd(-1,1),y+rnd(-1,1))
		--c=max(c-1,0)
		--if(rnd()<0.8) then c=0 end		
		--pix(x,y,c)
	end end
	
	for i=0,70 do
		tt=t+i*(0.05+sin(t*.4)*0.05)
		local x=sin(tt*0.22)*sin(tt*.33)*80
		local y=sin(tt*0.44)*sin(tt*.55)*50
		local r=tt--sin(tt*0.1)*10
		local s=sin(tt*0.33)*10+20
		local c=(i*0.1+tt)%5+7
		box(W2+x,H2+y,s,r,c)
	end
	
	for y=m,H do for x=0,W do
		dx=sin(y*1+t*5)*1
		scale=(y-m)
		--dx=dx*scale*0.01
		c=pix(x+dx,m-(y-m))
		c2=pix(x+rnd(-1,1),y)
		--if rnd()<0.5 then
			pix(x,y,c)
		--end
	end end	
end

function box(x,y,s,r,c)
	p1=v2(-0.5,-0.5)
	p2=v2(-0.5,0.5)
	p3=v2(0.5,0.5)
	p4=v2(0.5,-0.5)
	
	p1=TRS(p1,x,y,r,s)
	p2=TRS(p2,x,y,r,s)
	p3=TRS(p3,x,y,r,s)
	p4=TRS(p4,x,y,r,s)
	
	line(p1.x,p1.y,p2.x,p2.y,c)
	line(p2.x,p2.y,p3.x,p3.y,c)
	line(p3.x,p3.y,p4.x,p4.y,c)
	line(p4.x,p4.y,p1.x,p1.y,c)
end

function v2(vx,vy)
	return {x=vx,y=vy}
end

function rot2(v,a)
	local r=v2()
	r.x=v.x*cos(a)-v.y*sin(a)
	r.y=v.x*sin(a)+v.y*cos(a)
	return r
end

function TRS(v,x,y,r,s)
	local vec=rot2(v,r)
	vec.x=vec.x*s+x
	vec.y=vec.y*s+y
	return vec
end
