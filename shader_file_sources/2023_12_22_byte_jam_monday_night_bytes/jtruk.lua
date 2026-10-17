M=math
S=M.sin
C=M.cos
PI=M.pi
TAU=M.pi*2
T=0
facc=0

function BDR(y)
	vbank(0)
	for i=1,15 do
		local a=16320+i*3
		local r=i/15
		local g=.5+S(T*.012)*.5
		local b=.5+S(y*.01+T*.05)*.5
		poke(a,r*255)
		poke(a+1,g*255)
		poke(a+2,b*255)
	end
	vbank(1)
	for i=1,15 do
		local a=16320+i*3
		local o=(((y+T*2)//20)%2==0)and 0 or 1
		local r=1
		local g=o
		local b=o
		poke(a,r*255)
		poke(a+1,g*255)
		poke(a+2,b*255)
	end
end

function TIC()
	vbank(0)
	local f=fft(0)
	facc=facc+f

	for y=0,136 do
		for x=0,240 do
		 c=S(((x+(S(y)*2)//1)~(y+(S(x)*2)//1)+(S(T*.05)*20)//1)*.05)*(S(T*.02)*15)
			cd=((120-x)^2+(68-y)^2)^.5
			cd=S(cd*.05)*3
			pix(x,y,1+(c+cd)%15)
		end
	end
	local y=30
	local txts={"Team","Monday","Night","Bytes"}
	local s=3
	local sh=1
	for i,txt in ipairs(txts) do
		w=print(txt,0,140,0,false,s)
		local x=120-w/2+S(i+T*.04)*10
		print(txt,x+sh,y+sh,0,false,s)
		print(txt,x,y,12,false,s)
		y=y+24
	end
	facc=facc*.95

	vbank(1)
	cls(1)
	local ps=5
	local io=.1
	for i=-1,1,io do
	 local w=math.abs(1+(i*10))
	 a={}
		local o=T*.1+i
		for p=0,ps do
			a[p]=S(o+p)
		end

		for p=0,ps do
		 local zs=S(T*.1+i)
		 local po=(p+1)%ps
		 if a[po]>a[p] then
				x1,y1,z1=P(a[p]*w,i,zs)
				x2,y2,z2=P(a[po]*w,i+io,zs)
				rect(x1,y1,(x2-x1),y2-y1,p%2)
			end
		end
	end
	
	for y=0,135 do
	 if math.random()<.1 then
			rect(0,y,240,3,0)
		end
	end
	
	T=T+1
end

function P(x,y,z)
	local zF=1/(5+z)
	local m=10
	return 120+m*x/zF,68+m*y/zF,zF
end