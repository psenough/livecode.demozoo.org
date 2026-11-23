-- pos: 1,81
-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0

cls(4)

bo = {}

for y = 1, 136 do
 bo[y] = 0
end


function SCN(row)
	poke4(0x03FF8*2,bo[row])
	memcpy(row*120-1,row*120,120)
end

function OVR()


end

t = 0

function TIC()
for y = -32,136,8 do
 local s = 8+math.cos(y+t*0.01)*4
	circ(120+math.sin(s/2+t*0.1%64)*32,y+s/2+t%32,s,14)
	circb(120+math.sin(s/2+t*0.1%64)*32,y+s/2+t%32,s,15)

 line(120-math.sin(s/2+t*0.1%64)*32, y+s/2+t%32, 120+math.sin(s/2+t*0.1%32)*32,y+s/2+t%32,14)

end
	
	circ(120+math.cos(t*0.1)*40,136/2+136/2*math.sin(t*0.01),16,4)
	for y = t%136,t%136+136/2,4 do
	line(0,y,240,y,0)
	end
	memcpy(0,120,120*135)
	for y = 0,136 do
	 local v = vqtsw(y/2)
		local sc = 100
		local c = 7
		local o = 140+math.cos(t*0.01+y*0.01+vqtsw(y*0.1)*10)*40
		if v > 0.4 then c = 4 end
		if v > 0.6 then c = 2 end

		pix(o-v*sc,y,c+12)
		line(0,y,o,y,c+11)
		pix(o+v*sc,y,c+12)
		bo[y] = c+12
	end


 t=t+1
 
 for y = 0,136 do
	for x = 0,119 do
		pix(120-x,y,pix(x+120,y))
	end
 end


 local mm = "R0B0T"
 local xo = 110+math.cos(t*0.04)*80
 for i = 1, 5 do
 	local xx = math.cos(i+t*0.04)*24
  local l = string.sub(mm,i,i)
 	print(l,xo+xx,1+(i-1)*27,1,1,5)
 	print(l,xo+xx,2+(i-1)*27,i%2+2,1,5)
 end

end
