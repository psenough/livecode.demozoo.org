ti=0
s=math.sin 
function TIC()
cls()
t = "better late than never"  
for x=0, #t do 
 print(string.sub(t,x,x),
  (10*x+ti)%240,0,5,true,1)  
end
sf = 60 
for c=0,3 do  
for z=0,3 do
	for q=0,5 do  
		circ((75+ti+5*q+c*sf)%240,75+s(ti)*2*fft(q),10,6)
	end 
	 circ((75+ti+26+c*sf)%240,73+s(ti)*4,3,12)
	 circ((75+ti+26+c*sf)%240,71+s(ti)*4,1,0)
		
end

end  
ti=ti+.5
end 
