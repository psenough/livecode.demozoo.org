-- pos: 0,0
ADDR = 0x3FC0
palette = 0

function addLight(a)
 for i=0, 15 do
  for j=0, 2 do
   poke(ADDR+(i*3)+j, palette+(1-j)*a)
  end
  palette = palette + 8
 end
end
addLight(50)
W=240
H=136
abs=math.abs
sin=math.sin
cos=math.cos
inst="INSTANSSI"
ti={"I","N","S","T","A","N","S","S","I"}
cls(0)
function TIC()
	t=time()//32
	for y=0,H do 
		for x=0,W do
			uv={x/W,y/H}
			uv[1]=uv[1]-.5
			uv[2]=uv[2]-.5
			
			
		 uv[1]=uv[1]*10
			uv2=uv
			uv[2]=(uv[2]+t*.01)%1
			for i=0,3 do
				uv[1]=abs(uv[1])-.8
				uv[2]=abs(uv[2])
			end
			uv[1]=(uv[1]+t*.04)%1
			--uv[1] = uv[1]*sin(t*0.1) + uv[2]*cos(t*0.1)
			--uv[2] = uv[2]*-sin(t*0.1) + cos(t*0.1)*uv[1]
			ff=fft(abs(uv[1]*uv[2]-abs(uv2[2]))*1000)*50
			if ff>1 then
				circ(x,y,ff,ff)
			end
			if x%2==t%2 and y%2==t%2 then 
				pix(x,y,1)
			end
		end 
	end
	
	rect(0,0,20,6,1)
	print(t%16,0,0,15)
	if t%16==0 then 
		addLight(50+t%50)
	end
	boing=fft(.00)*100
	
	w=print("INSTANSSI",0,-8)
	for i=1,9 do
		c=0
		bPrint(ti[i],sin(t*0.1)*40+(W/2+w/9*i*2+i-w-10),sin(t*0.1)*-sin(t*0.2)*10+(H/2-sin(i)*(4+fft(i+t)*100)),boing)
	end
	
	--bPrint("INSTANSSI",W/2-w,H/2,boing)
end

function bPrint(t,x,y,b)
	print(t,x,y-b+2,15,0,2)
	print(t,x,y-b,2,0,2)	
end
