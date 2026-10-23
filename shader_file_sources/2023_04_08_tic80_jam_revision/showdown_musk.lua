-- pos: 0,0

t=0;
t2=0;
lt=0;
sgt=0;



function TIC()gt=time()//32
	

	t=t+1
	t2=t2+1
 local	q=4-t;
 q2=16-t2;
	if q>=0 then cls(q); end
	if q2<0 then q2=0 end

	
	sin=math.sin
	cos=math.cos
	
 for i=0,10 do
 	circ(
 		64+cos(i*4+gt/14)*120+66,
   64+sin(i*9+gt/35)*41,
   sin(i+gt/44)*32,
   i
  )
 end
	
	
 for y=0,136,2 do for x=0,240,2 do
 	pix(x+(y/2&1),y,((x+y+t)>>5)+q2)
  
	

 if(key(1))then
		dt=gt-lt
		sgt=dt*.1+sgt
		lt=gt
		t=0
	end
	
	if (t>28*4) then t=0 end
	
	if(t2>28) then t2=0 end
	
	
 
end end end
