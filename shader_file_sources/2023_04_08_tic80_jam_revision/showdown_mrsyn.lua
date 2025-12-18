-- pos: 0,0
t=0
s=math.sin 
function citrus(x,y,w,c) 
 circ(x,y,w,c)
 circ(x,y-10,w/3,c)
 circ(x,y+10,w/3,c)  
end 

function TIC()
cls()
c=2
_c=12
zf=10  
for x=0,239 do
 if(x%zf==0) then 
 	c,_c=_c,c  
 end
	for y=0,135 do
	 if(y%zf==0) then 
	 	c,_c = _c,c
		end
		pix(x,y,c)
	end 
end
  jf=s(t)*(s(t/5)*80)
  f1 = 5
  f2 = 4
  for xf=0,7 do 
   f1,f2 = f2,f1 
  	citrus(10+xf*30,140-jf-s(xf+t)*10,10+s(t/10)*xf,f1)
  end  
  
  
t=t+.1 
end
