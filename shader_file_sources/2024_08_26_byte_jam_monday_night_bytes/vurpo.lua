-- pos: 0,0
-- greetings to
-- jtruk henearxn g33kou catnip
-- lynn stormcaller enfys
-- aldroid pumpuli
-- and everyone watching

-- from vurpo
-- this is a jumalauta demo victory lap!!!

m=math
int=m.floor

function BOOT()
	cls(0)
end

n=20
s=32

f=0
fm=30

tx=0
ty=0
ti=1

text={"too late","too late","it's not","too late"}

function TIC()
	t=time()
	for x=0,240 do for y=0,136 do
		if m.random() > 0.8 then
			pix(x,y,0)
		end
	end end
	
	for i=0,n do
	 z=(i+(0.007*t%1))/(n/1.5707)
		d=20*m.tan(z)
		wx=(d*0.5+20)*0.55*m.sin(2*z-0.006*t)
		wy=(d*0.5+20)*0.55*m.cos(3*z-0.004*t)
		for j=0,s do
			a=j*(6.2832/s)+3*z
			circ(120+wx+d*m.cos(a), 68+wy+d*m.sin(a), d/20, d/7+j%16)
		end
	end
	f=(f+1)%fm
	if f==0 then
		tx=m.random()*40-85
		ty=m.random()*40-30
		ti=ti+1
		if ti>4 then ti=1 end
	end
	if f<5 then
		for x=-1,1 do for y=-1,1 do
			print(text[ti],120+tx+x,68+ty+y,0,false,3)
		end end
		print(text[ti],120+tx,68+ty,12,false,3)
	end
end
