xc=240/2
yc=136/2
bai=0
function TIC()
	t=time()//32
	-- hi
	ba=0
	for i=60,70 do
 	ba=ba+fft(i)
	end
	bai=bai+ba*15
	ycd=136/2+5*math.cos(bai/5)
 yc=136/2+5*math.sin(bai/5)
	vbank(1)
	cls(0)
	w=70
	r=15
	h=35
	circ(xc-w,yc-h,r,13)
	circ(xc+w,yc-h,r,13)
 circ(xc-w,yc+h,r,13)
	circ(xc+w,yc+h,r,13)
	rect(xc-w,yc-h-r,2*w,2*h+2*r+1,13)
	rect(xc-w-r,yc-h,2*w+2*r+1,2*h,13)

	circ(xc-w*0.75,yc-h+10,r,12+ba)
	circ(xc+w*0.75,yc-h+10,r,13-ba*ba*300)

 er=3+ba*4
 rect(xc-w*0.75-er,yc-h+10-er,2*er+1,2*er+1,1)
 rect(xc-w*0.75-er,yc-h+10-er,2*er,2*er,14)
 rect(xc+w*0.75-er,ycd-h+10-er,2*er+1,2*er+1,1)
 rect(xc+w*0.75-er,ycd-h+10-er,2*er,2*er,14)

	ml=yc +(90-136/2)+math.cos(bai)
	rect(xc-60+15,ml-15,120-28,30,0)
	circ(xc-60+15,ml,14,0)
	circ(xc+60-15,ml,14,0)



	vbank(0)
 cls(0)
	for x=0,120 do
	 f=(fft(x)+fft(x+1))*30

		x=60+x*0.5*(-1)^(x%2)
  f=f*1/math.cos(x/50)
		if f>10 then
		 line(xc-60+x,0,xc-60+x,136,14)
		end
		if f>15 then f=15 end
		line(xc-60+x,ml+f,xc-60+x,ml-f,x+t)
	end

	line(xc-60,ml-14,xc+60,ml-14,0)
	line(xc-60,ml-12,xc+60,ml-12,0)
		line(xc-60,ml-10,xc+60,ml-10,0)
	line(xc-60,ml+14,xc+60,ml+14,0)
	line(xc-60,ml+12,xc+60,ml+12,0)
		line(xc-60,ml+10,xc+60,ml+10,0)

end
