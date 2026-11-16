function slc(x,y,w,h,c)
	elli(x,y,w,10,c)
	elli(x,y-h,w,10,c)
	rect(x-w,y-h,w+w+1,h,c)
end
function wax(x,y,c,r)
	rect(x-2,y-22,3,20,c)
	rect(x-1,y-24,1,2,12)
	spr(r,x-4,y-33,0)
	spr(4,x-2,y-20,0)
	spr(4,x-2,y-12,0)
end

function TIC()
	local t=time()
	local x=120
	local y=95
	cls()
	elli(x,y,70,12,13)
	slc(x,y-4,60,10,4)
	slc(x,y-14,60,10,2)
	slc(x,y-24,60,10,4)
	slc(x,y-34,60,1,2)

 local wc={10,6,1,8}
	local ox,oy,r
	for i=0,5 do	
		ox=math.cos((i-.1)*math.pi/3)*30
		oy=math.sin((i-.1)*math.pi/3)*5
		r=1+2*math.abs(math.sin(t+ox+oy))
  wax(120+ox,65+oy,wc[1+(i%4)],r)
	end
	for i=0,10 do	
		ox=math.cos((i+.2)*math.pi/5)*50
		oy=math.sin((i+.2)*math.pi/5)*10
		r=4*math.abs(math.sin(t*1.1+ox+oy))
  wax(120+ox,64+oy,wc[1+(i%4)],r)
	end
 wax(120,65,10,r)

	local txt="Happy Birthday"
	for i=1,#txt do
 x=i*16
	y=120-math.abs(math.sin((i*100+t)*.003)*30)
 print(txt:sub(i,i),x+2,y+2,15,true,3)
	print(txt:sub(i,i),x,y,12,true,3)
	end
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>