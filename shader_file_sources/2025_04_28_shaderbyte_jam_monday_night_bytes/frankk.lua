-- pos: 0,0
sin=math.sin
cos=math.cos
max=math.max

ciao="CIAO"


function PrintCiao(y,size,t)
	t=t*10
	for i=0,#ciao do
		c=string.sub(ciao,i,i)
		x=(240-t+i*20)%240
		print(c,x,y,t,true,size)
	end
end 

function TIC()
	t=time()/264
	clc=fft(0,1000)
	cls(clc%3)
	
	nb=100
	for i=0,nb,1 do
		f=fft(i,i+1)
		rect(i*240//nb,138-f*100,240//nb,f*138,i//10+1)
	end

	for i=0,nb,1 do
		f=fft(nb-i,nb-i+1)
		rect(i*240//nb,0,240//nb,f*100,(nb-i)//10+1)
	end
	
	cfft1=fft(0,100)
	for z=1,26 do
		for x=-440,440 do
			_z=(26-z)
			fft2=fft(x+440,(x+441))
			_y=20*sin(t*2+x/128)+20*sin(t)+fft2*300*sin(t)
			_x=x
			
			_x=_x/_z
			_y=_y/_z
			_x=_x+120
			_y=_y+68
			
			circ(_x,_y,max(z/10,1),_z+cfft1*3)
		end
	end
			
--		PrintCiao(18,1,t*4)
--		PrintCiao(18,2,t*10)
--		PrintCiao(12,3,t*2)
--		PrintCiao(100,2,t/1)
--		PrintCiao(48,4,t+100)									


end