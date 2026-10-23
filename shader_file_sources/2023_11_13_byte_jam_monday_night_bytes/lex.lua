-- live coded Jam-o-matic jam factory
-- Monday night bytes anniversary byte jam 13th Nov 2023
-- Lex Bailey

function jar(x,y,s,fill)
 local s2 = s*0.8
 ellib(x,y+s2,s,s/3,12)
 line(x+(s*0.4),y+s2-(s*0.3),x+(s*0.4),y-s2-(s*0.3),12)
 line(x-(s*0.5),y+s2-(s*0.3),x-(s*0.5),y-s2-(s*0.3),12) 
 
 local s3 = s*1.5
 if fill>0 then
 for i=0,(fill*s3) do
  elli(x,y+s2-i-1,s,s/3,2)
 end
 end
 ellib(x,y+s2-1-(fill*s3),s,s/3,1)
 line(x-s,y+s2,x-s,y-s2,12)
 line(x+s,y+s2,x+s,y-s2,12)
 line(x+(s*0.5),y+s2+(s*0.3),x+(s*0.5),y-s2+(s*0.3),12)
 line(x-(s*0.4),y+s2+(s*0.3),x-(s*0.4),y-s2+(s*0.3),12)
 ellib(x,y-s2,s,s/3,12)
 ellib(x,y-s2-(s*0.03),s*0.95,(s/3)*0.95,12)
 ellib(x,y-s2-(s*0.1),s*0.9,(s/3)*0.9,12)

end

function filler(level)
 tri(120-15,20,120+15,20,120,40,13)
	rect(120-6,0,12,40,13)
	rect(120-15,0,30,20,8)
	if level > 0 then
 	rect(120-6,40,12,32,2)
	end
	rect(120-6,77,12,level-40,2)
	print("JAM", 111, 0, 12)
	print("-O-", 113, 7, 12)
	print("MATIC", 107, 14, 12)
end

function conveyor(o)
 rect(0,100,240,30,13)
 for i=-5,16 do
  local o2 = o + (i*20)
  tri(o2+0,100,o2+0,130,o2+10,115,14)
 end
end

function rear_conveyor(o)
 rect(0,55,240,15,13)
 for i=-5,16 do
  local o2 = -o + (i*25)
  tri(o2+0,55,o2+0,70,o2-10,62,14)
 end
end

function lid(o,p,q)
	elli(200+o,-38+p,30,10,9)
	local a = -50+p-q
	rect(195,0,10,7+a,13)
	rect(170,a,62,10,13)
	if p<100 then
 	tri(170,a,170,a+30,160,a+5,13)
 	tri(232,a,232,a+30,242,a+5,13)
 else
 	tri(170,a,160,a+30,160,a+5,13)
 	tri(232,a,242,a+30,242,a+5,13)
 end
end

function logo(x,y)
	tri(x-15,y,x,y+15,x+15,y-8,0)
	trib(x-11,y+1,x-1,y+12,x+10,y-5,1)
	trib(x-8,y+2,x-1,y+9,x+6,y-2,11)
	print("FX",x-6,y,4)
end

function labels(o,p,q)
  local a = p-q-100

	 if p == 100 then
   logo(40+o,90)  
  end
  logo(120+o,90)
  logo(200+o,90)
  
  circ(40,100-a,20,15)
  rect(35,100-a,10,40,15)
end

local t = 0
function TIC()
 t = t+1
 cls()
 p = math.min(100, t%200)
 q = math.max(100, t%200)-100
 r = t % 50
 offset = (q * (80/100))

 rear_conveyor(r)
 for i=-3,6 do
   jar(120-r+(i*50),50,15,0)
 end

 
 conveyor(offset)

 jar(-40+offset,90,30,0)
 jar(40+offset,90,30,0)
 jar(120+offset,90,30,p/100)
 jar(200+offset,90,30,1)
 
 local lvl = 0
 if p < 100 then
  lvl = 80-(p*0.6)
 end
 filler(lvl)
 
 lid(offset,p,q)
 
 labels(offset,p,q)
 
end

