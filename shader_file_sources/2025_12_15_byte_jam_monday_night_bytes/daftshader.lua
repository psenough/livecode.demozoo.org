-- DaftShader's 1st TIC-80 MondayNightBytes 2025-12-15
-- Thanks: Aldroid (host!), archydragon (choons!)
--         jtruk (idea to add these comments up top!),
-- Greets: enfys, littletheremin, g33kou
-- 

-- Standard shortcut stuff:

sub=string.sub
rnd=math.random
min=math.min


-- Code for the scroller:

text="HELLO FIELD-FX MONDAY NIGHT BYTES"
--l=#text//1 --text length as an int
tt=16 --time before resetting scroller
st=0 --scroller time

function scroller()
 secs=time()//1000
 --print(secs,0,0);print("Looping every " .. tt,30,0) --show info
 if secs%tt == 0 then st=0 end --reset
 for i=1,#text do
  yoff=fft(i)*26
  for c=0,3 do
   print(sub(text,i,i),
   240+i*17-st+c,
   60+math.sin(i+(c/3)+(st/10))*5-yoff*c,
   1+c,true,3)
  end
 end
 st=st+1
end


-- Code for the equaliser:

function equaliser()
 gap=40
 for i=0,240 do
  h=136-ffts(i/2)*136
		line(i,136,i,h-gap*3,15)
		pix(i,h-gap*3-1,14)
		line(i,136,i,h-gap*2,14)
		pix(i,h-gap*2-1,13)
		line(i,136,i,h-gap*1,13)		
		pix(i,h-gap-1,12)
		line(i,136,i,h,12)
		pix(i,h,14)
	end
end


-- Code for the cubey thing

sin=math.sin
cos=math.cos
angle=0
twopi=6.28318

function rotatex(p,angle)
 xt = p.x
 yt = p.y*cos(angle) - p.z*sin(angle)
 zt = p.y*sin(angle) + p.z*cos(angle)
 return {x=xt,y=yt,z=zt}
end

function rotatey(p,angle)
 xt = p.x*cos(angle) - p.z*sin(angle)
 yt = p.y
 zt = p.x*sin(angle) + p.z*cos(angle)
 return {x=xt,y=yt,z=zt}
end

function rotatez(p,angle)
 xt = p.x*cos(angle) - p.y*sin(angle)
 yt = p.x*sin(angle) + p.y*cos(angle)
 zt = p.z
 return {x=xt,y=yt,z=zt}
end

function cube()
 t=time()/500
 angle = angle + 0.02
 if angle >= twopi then angle = 0 end
 points = {}
 
 for x=-24,24,6 do
  for y=-24,24,6 do
   for z=-24,24,6 do
    p=rotatex({x=x,y=y,z=z},angle)
    p=rotatey(p,angle)
    p=rotatez(p,angle)
    table.insert(
     points,{x=p.x,y=p.y,z=p.z+60})
     --larger added num = further away
   end
  end
 end
 
 table.sort(points,
  function (a,b) return a.z>b.z end
  )
 
 for i=1,#points do
  for j=0,2 do
   circ(120+80*points[i].x/points[i].z-j/2,
        68+80*points[i].y/points[i].z-j/2,
        3-j,
        8+j) --2+j=orangey
  end
 end
end


-- Do the things

function TIC()
 --cls(14+math.random(2)) --flickery!
 cls(0)
 equaliser()
 scroller()
 cube()
end