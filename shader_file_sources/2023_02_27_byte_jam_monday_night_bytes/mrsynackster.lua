t=0
s=math.sin
function TIC()
cls()
t=t+.05 
for y=0,135 do
	for x=0,239 do 
  if(y%4==0) then 
			pix(x+s(t)*8,y+s(t)*2,s(x*y/((t*.5)+100+s(t)*3))*8+t)
	 end 
		if(y%13==0 and x%17==0) then 
		 pix(x+s(t)*4,y+s(t)*2,s(x*y/((t*.5)+100+s(t)*4))*8+t+1)
		end
		if(y%11==0 and x%13==0) then 
		 pix(x,y,x^y+8/t)
		end
		
		if(x%22==0 and y%11==0) then 
			circ(x+s(y+(t*2)),y+(t*2%68),s(t)*4,x/y)
		end 
		 		
	end
end 
	 
end
