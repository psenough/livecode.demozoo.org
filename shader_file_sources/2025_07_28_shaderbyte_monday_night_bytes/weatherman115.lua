-- pos: 0,0
sin=math.sin
cos=math.cos
max=math.max
min=math.min
rnd=math.random
atan2=math.atan2

function newBox(fx,fy,w,h,form)
	
	local boxOut = {}
	
	boxOut['fx']=fx
	boxOut['fy']=fy
	boxOut['w']=w
	boxOut['h']=h
	boxOut['form']=form
	
	table.insert(boxes, boxOut)
	
end

function shiftRed(v)
	for i=0,15 do
		poke(16320+i*3,i*v)
	end
end

box = {}
box["fx"]=function(ti) return sin(ti/32) end
box["fy"]=function(ti) return cos(ti/44) end
box["w"]=64
box["h"]=64
box["form"]='asdfasdfasdf'
shiftRed(17)

formList = {
	function(xi,yi,ti) return (sin(xi/yi+ti/32)) end,
	function(xi,yi,ti) return vqts((xi~yi+ti//1)%240) end,
	function(xi,yi,ti) return atan2(
		sin(yi/32*(1+sin(t/17)/4)),
		sin(xi/32*(1+cos(t/27)/4))
	)/2 end
}

function TIC()
	
	t=time()*60/1000
	
	box.form=formList[1+(3 + t//300)%#formList]
	
	cls()
	
		x0 = (120-box.w/2)*(1+box.fx(t))//1
		y0 = (68-box.h/2)*(1+box.fy(t))//1
		
		for i=0,3 do
			rectb(x0-1-i,y0-1-i,box.w+2+2*i,box.h+2+2*i,8+i)
		end
		
		for y=y0,y0+box.h-1 do
			for x=x0,x0+box.w-1 do
				local val=math.abs(box.form(x,y,t))%1
				line(x,y,x,y-val*15.99,
					1+val*14.99
					)
			end
		end
		
	
end
