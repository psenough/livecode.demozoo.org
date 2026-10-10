-- muffintrap for
-- monday night bytes
-- 08/06/2026
S=math.sin
C=math.cos
SW=320
SH=128

cloud_ys={0,0,0,0,0,0,0}
cloud_xs={0,0,0,0,0,0,0}

for i=1,8 do
	cloud_ys[i]=i*20
	cloud_xs[i]=math.random(SW)
end

function vec2(x,y)
	return {x=x,y=y}
end

--Parameters are Vec2
function bezier4(p0,p1,p2,p3,t)
	local x=(1-t)^3*p0.x + 3*(1-t)^2*t*p1.x + 3*(1-t)*t^2*p2.x + t^3*p3.x
	local y=(1-t)^3*p0.y + 3*(1-t)^2*t*p1.y + 3*(1-t)*t^2*p2.y + t^3*p3.y
	return vec2(x,y)
end

function petals(t,size,color)
	local pulse=fft(0,512)/100
	local step=1/40
	local p0=vec2(0+S(t/60)*60,SH/2+S(t/60)*SH/2)
	local p3=vec2(SW,SH/2+C(t/60)*SH/2)
	local p1=vec2(SW/4+S(t/100)*120,SH/2+S(t/50)*100)
	local p2=vec2(SW/2+50+C(t/100)*120,SH/2+C(t/60)*100)
	for i=1,40 do
		local p = bezier4(p0,p1,p2,p3,i*step)
		circ((p.x + t)%SW,p.y,size,color)
	end
end

function cloud(t,x,y,rad,speed,color)
	local n=4
	local width=n*rad
	local limit =SW+width
	for i=0,4 do
	circ((x+i*(rad/1.5)+t*speed)%limit, y, rad, color)
	end
	circ((x+rad+t*speed)%limit, y-6, rad, color)
end

moonx=SW/2+SW/4
moony=SH/2+SH/4

function TIC()
	t=time()//32	
	cls(0)
	moony=moony-1/50
	moonx=moonx-2/30
	if moony<30 then moony=SH/2+SH/4 end
	if moonx<30 then moonx=SW/2+SW/4 end
	circ(moonx,moony,65,4)
	circ(moonx-8,moony-8,60,0)
	print("muffins on the moon",SW/6,SH/2,12)
	for i=1,#cloud_ys do
		cloud(t, (cloud_xs[i]+160)%SW,(cloud_ys[i]+120)%SH,4,0.15,8)
	end
	petals(t+SW,1,2)
	petals(t,2,3)
	for i=1,#cloud_ys do
		cloud(t, cloud_xs[i]+60,(cloud_ys[i]+80)%SH,5,0.5,13)
	end
	petals(t+SW/2,3,7)
	for i=1,#cloud_ys do
		cloud(t, cloud_xs[i],cloud_ys[i],10,1.0,12)
	end
end
