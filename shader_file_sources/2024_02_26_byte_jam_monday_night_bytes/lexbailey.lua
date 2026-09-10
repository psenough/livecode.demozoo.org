rects = {}
windows  = {}

num_cols = 8
colw=45

for i=1,num_cols do
	rects[i] = 20+(math.random() * 70)
	windows[i] = math.floor(math.random()*16)
end
f=0
t=0
th=0
th2=0

function draw_house(x,y,i)
		rect(x,y,colw-4,200,3)
		tri(x,y,x+colw-4,y,x+((colw-4)//2),y-15,1)
		local c = math.floor(windows[i]) % 16
		if c == 3 then
		  c = 4
		end
		rect(x+((colw-4)//2)-5,90,10,17, 1)
		rect(x+((colw-4)//2)-18,y+10,10,10, c)
		rect(x+((colw-4)//2)+8,y+10,10,10, c)
end

function draw_road(s)
	rect(0,105,240,136,0)
	for i=0,24 do
		rect(i*20-(s % 240),120,15,3,4)
	end
end

function draw_bus(x,y)
 local c = math.floor(windows[1]) % 16
	if c == 3 then
	  c = 4
	end
	circ(x,y,5,13)
	circ(x+50,y,5,13)
	rect(x-6,y-25,64,25,4)
	for i=0,4 do
  	rect(x-2+(i*10),y-20,8,8,c)
	end
	rect(x+47,y-20,8,16,c)
	circ(x+56,y-3,2,12)
	circ(x-5,y-3,2,2)
	print("FFX-MNB",x,y-10)
end

function draw_cloud(x,y,s)
	circ(x,y,s,12)
	circ(x+s+s,y-2,s,12)
	circ(x+s,y-s,s-2,12)	
	circ(x+s,y+4,s-2,12)	
end

function draw_clouds(ct)
 for i=0,4 do
 	draw_cloud(-30+((ct+(70*i))%340),40+(10*math.sin((ct/10)+i)),10)
 end
end

function draw_godzilla(x,y,f)
 -- lmao, if I can pull this off,
 -- then this will be my fave mnb
 -- so far :D

 --other arm/leg
 line(x-38,y-10,x-20,y-10+f,5)  
 line(x-40,y,x-40+f,y+10,5)  
 
 --tail
 circ(x-40,y,9,6)
 circ(x-43,y,7,6)
 circ(x-51,y,5,6)
 circ(x-56,y,3,6)
 
 --torso
 circ(x-40,y-4,12,6)
 circ(x-40,y-8,14,6)
 
 --neck/head
 circ(x-40,y-25,8,6)
 circ(x-40,y-30,10,6)
 circ(x-34,y-33,4,0)
 --mouth
 line(x-38,y-25,x-30,y-25,12)
 
 --arm/leg
 line(x-38,y-10,x-20,y-10-f,5)  
 line(x-40,y,x-40-f,y+10,5)  
end

function TIC()
	cls(10)
	t=t+(fft(1)*20)
	th=th+(fft(10)*20)
	th2=th2+(fft(5)*20)
	h = fft(30)
	s = (time()//40) % (num_cols*colw)
	draw_clouds(s)
	for x=1,num_cols+10 do
		local i = (x%num_cols)+1
		local y = rects[i]
		local rx = (x-1) * colw
		windows[i] = (windows[i] + (h*10))		
		y = y+ math.sin((t/100)+(x%num_cols))*7
		draw_house(rx-s,106-y,i)
	end
	draw_road(s)
	by = 120
	bx = 70
	bx2 = bx+(math.sin(th2/110)*100)
	bx = bx+(math.sin(th2/100)*100)
	by2 = by+(math.sin(1+(th/9))*8)
	by = by+(math.sin(th/10)*10)
	draw_bus(bx,by)
	f = f + 0.1
	draw_godzilla(bx2-20,by2,math.sin(f)*10)
end
