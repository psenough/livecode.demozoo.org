pi=math.pi
sin=math.sin
cos=math.cos


-- OPTIMISM

-- greetz from A SHED
-- hugs to you all
-- thank you aldroid for hosting!
-- thanks to g33kou, canmom, boris, littletheremin for jammin


function TIC()
	cls()
	t=time()//327
	t2=time()/987
	t3=time()/2987


	dots=bess(4,4)
	draw(60,28,30,90)
	draw(120,28,60,120)
	draw(180,28,120,180)
	draw(60,88,1,60)
	draw(120,88,10,170)
	draw(180,88,30,90)
	
end

function draw(cx,cy,r1,r2)
	ff=fft(r1,r1+20)*3
	ff =ff+fft(0,5)*2
	
--	rect(cx-20,cy-20,40,40,2+(t2+r1)%6)
	rectb(cx-20,cy-20,40,40,12)
	rectb(cx-24,cy-24,48,48,12)

	
	for s=18,30,3 do
	for d=r1,r2 do
		--argh
		i=dots[d][1]
		a=dots[d][2]
		
		-- did i mention i was VERY tired
		x=a*sin(i)*(s+ff)
		y=a*cos(i)*(s+ff)
		-- yay
		pix(cx+x,cy+y,12)
	end
	end
end

function bess(n,m)
	-- equation written down somewhere
	-- hmmm
	vals={}
	steps=180
	dt=pi/steps
	for i=0,steps do
		-- ???
		f=fft(i,i+10)
		di=i*dt
		val=cos(n*di-m*sin(di+f+t))
		table.insert(vals,{di, val})
	end
	return vals
end
	

