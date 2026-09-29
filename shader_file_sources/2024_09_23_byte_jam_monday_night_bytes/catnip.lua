sin=math.sin
cos=math.cos
abs=math.abs

t=0

-- greets to P3RC!, g33kou, enfys
-- aldroid and voilet!

function rac(x,y,b,s)
 elli(x-7*s,y-8*s-b*s,4*s,7*s,13)
 elli(x-7*s,y-8*s-b*s,3*s,5*s,15)
 elli(x+7*s,y-8*s-b*s,4*s,7*s,13)
 elli(x+7*s,y-8*s-b*s,3*s,5*s,15)
 elli(x,y-b*s,12*s,10*s,13)
 circ(x-7*s,y+5*s-b*s,6*s,13)
 circ(x+7*s,y+5*s-b*s,6*s,13)
 circ(x,y+5*s-b*s,5*s,12)
 
 elli(x,y+5*s-b*s,4*s,3*s,0)
 elli(x,y+3*s-b*s,4*s,3*s,12)
 line(x,y-b*s,x,y+8*s-b*s,0)
 
 rect(x-2*s,y-b*s,5*s,6*s,13)
 -- i's
 circ(x-5*s,y-b*s,3*s,12)
 circ(x-7*s,y+2*s-b*s,3*s,12)
 circ(x-4*s,y+1*s-b*s,2*s,15)
 circ(x-6*s,y+3*s-b*s,2*s,15)

 circ(x+5*s,y-b*s,3*s,12)
 circ(x+7*s,y+2*s-b*s,3*s,12)
 circ(x+4*s,y+1*s-b*s,2*s,15)
 circ(x+6*s,y+3*s-b*s,2*s,15)
 
 circ(x-5*s,y-b*s,2*s,0)
 circ(x-6*s,y-b*s-1*s,1*s,12)
 circ(x+5*s,y-b*s,2*s,0)
 circ(x+4*s,y-b*s-1*s,1*s,12)
 
 circ(x,y+3*s-b*s,2*s,0)
 
 line(x-8*s,y+6*s-b*s,x-20*s,y+10*s-b*s*2*s,0)
 line(x-6*s,y+7*s-b*s,x-22*s,y+14*s-b*s*2*s,0)
 line(x-5*s,y+8*s-b*s,x-20*s,y+18*s-b*s*2*s,0)
 line(x+8*s,y+6*s-b*s,x+20*s,y+10*s-b*s*2*s,0)
 line(x+6*s,y+7*s-b*s,x+22*s,y+14*s-b*s*2*s,0)
 line(x+5*s,y+8*s-b*s,x+20*s,y+18*s-b*s*2*s,0)
end

function pln(x,y)
 circ(x+20,y-1,2,13)
 local h=sin(t)*7
 line(x+22,y-h,x+22,y+h,12+t%2)
 rect(x,y-4,20,8,2)
 rect(x-20,y-4,20,7,2)
 rect(x-20,y-10,3,7,2)
 tri(x-17,y-10,x-17,y,x-12,y,2)
 elli(x+8,y-8,10,1,2)
 elli(x+8,y+6,10,1,2)
 rect(x+12,y-8,2,14,2)
 rect(x+3,y-8,2,14,2)
 
	rac(x-6,y-6,f[4]*4,.5)
 
 -- 161w
 local tx=x-25-163
 rect(tx,y-3,163,8,12)
 print("HAPPY BIRTHDAY RACCOONVIOLET!",
  tx+1,y-1,0)
end

f={0,0,0,0,0}

function TIC()

 cls(10)
 rect(0,100,240,36,6)
 rect(0,110,240,20,15)
	
	for i=0,20 do
	 local x=-t+i*18
		elli(x%360-60,sin(i)*1437%80,20,15,13)
		elli(x%360-60,sin(i)*1437%80-2,19,14,12)
	end
	
	local y=-abs(sin(t/8))*4
	
	rect(40,55+y,160,60,4)
	print("RACCOON PARTY BUS",73,95+y,12)
	clip(40,75+y,160,40)
	circ(60,115+y,12,15)
	circ(180,115+y,12,15)
	clip()
	
	circ(60,115,10,13)
	circ(180,115,10,13)
	
	for i=0,4 do
		f[i+1]=f[i+1]*.7+fft(i*5+5,(i+1)*5)
	end
	rect(45,60+y,30,30,0)
	rac(60,85+y,f[1]*8,1)
	rect(85,60+y,30,30,0)
	rac(100,85+y,f[2]*8,1)
	rect(125,60+y,30,30,0)
	rac(140,85+y,f[3]*8,1)
	
	rect(165,60+y,30,30,0)
	rac(180,85+y,f[4]*8,1)
	
	pln(t%480-30,30+sin(t/20)*5)
	--print("=^^=",5,42-y,0,0,10)
	--print("=^^=",5,40-y,12,0,10)

	t=t+1
end
