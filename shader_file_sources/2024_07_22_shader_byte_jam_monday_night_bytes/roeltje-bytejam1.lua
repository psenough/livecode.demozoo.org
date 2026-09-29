--hello this is Roeltje :D
--hyped for my first Byte Jam!
--shoutout to RaccoonViolet and
--all the other jammers!
W,H=240,136
W2,H2=120,68
sin,cos=math.sin,math.cos
rnd=math.random
min,max=math.min,math.max

function circle(x,y,r,c,face,mirror)
		circ(x,y,r,c)
		
		if face==true then
			circ(x,y+3,r/5,0)
			dy=ffts(0,100)*0.0+2
			circ(x,y+3-dy,r/5,c)
			if ffts(0,100)>7 then 
				circ(x,y+3,r/5,0)
			end
			
	
			eye=ffts(0,100)*0.15+1
			l=x-3
			r=x+3
			
			circ(l,y-3,eye,0)
			circ(r,y-3,eye,0)
			--rect(x-r/5,y+2-r/5,r/5*3,r/5,12)
		end
end

cls(1)
function TIC()
	t=time()/1000
	
	for y=0,136 do for x=0,240 do
		c=pix(x+rnd(-3,3),y+rnd(0,1))
		if rnd()<0.5 then c=max(0,c-1) end
		--if rnd()<0.1 then c=0 end
		
		
		pix(x,y,c)
	end end 
	
	n=24
	for i=0,n do
		--haha woops
		tt=t+(i*sin(t)*0.1)
		h=sin(tt*1.5)*sin(tt*0.325)
		
		size=900/(n+1)
		r=ffts(size*i+50,size*(i+1)+50)*10
		
		dx=sin(tt*0.5)*sin(tt*3.33)
		local x=i*2.5+dx*50
		--x=x*(i/n)
		
		circle(W2+x,H2+h*50,10+r,i+2+tt,i==n,false)
		circle(W2-x,H2+h*50,10+r,i+2+tt,i==n,true)
		--circ(W2+i*6+dx*50,H2+h*50,10+r,i+2)
		--circ(W2-i*6-dx*50,H2+h*50,10+r,i+2)
	end
	
	--circ(120,68,fft(0,100),3)
end
