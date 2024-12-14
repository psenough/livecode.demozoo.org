sin=math.sin
cos=math.cos
rand=math.random
abs=math.abs

t=0
p={}
for i=1,256 do
 p[i]={x=rand()*4-2,y=rand()*4-2,z=rand()*4-2}
end

function BOOT()
 cls(0)
 circ(8,8,7,12)
 for y=0,16 do
  for x=0,16 do
   if pix(x,y)==12 then
    pix(x,y,(y/16)*3+5)
   end
  end
 end
 
 circ(8+32,8,7,12)
 for y=0,16 do
  for x=32,48 do
   if pix(x,y)==12 then
    pix(x,y,5-(y/16)*3)
   end
  end
 end
 
 circ(24,8,1,12)
 circ(28,8,1,12)
 circ(20,8,1,12)
 circ(24,4,1,12)
 circ(24,12,1,12)
 rect(24,4,1,8,12)
 rect(20,8,8,1,12)
end

function bob(x,y,z,id)
 local x=x*68+120
 local y=y*68+68
 local r=(z*4+5)/3
 local z=-z*.5+1
 local u=id*16
 local v=(id+1)*16
 ttri(
  x-r,y-r,
  x+r,y-r,
  x-r,y+r,
  u,0,
  v,0,
  u,16,
  2,0,
  z,z,z
 ) 
 ttri(
  x+r,y-r,
  x-r,y+r,
  x+r,y+r,
  v,0,
  u,16,
  v,16,
  2,0,
  z,z,z
 )
end

function TIC()
 vbank(1)
 clip(0,0,240,100)
 cls(8)
	clip(0,100,240,136)
 cls(6)
 clip()
 
	rect(80,105,15,20,2)
	rect(105,103,12,15,3)
	rect(90,110,17,15,4)
	rect(80+40,105,15,20,2)
	rect(105+40,103,12,15,3)
	rect(90+40,110,17,15,4)
 
 elli(200,110,20,10,3)
 local f=fft(150)*100
 local y=99-f
 local x=sin(t/2)^7*4
 elli(210-5+x,y-5,2,4,4)
 elli(210+5+x,y-5,2,4,4)
 elli(210+x,y+2,9,6,1)
 elli(210+x,y,9,6,3)
 
 elli(210-4+x,y-2,2,2,12)
 elli(210+4+x,y-2,2,2,12)
 elli(210-4+x+sin(t)*1.1,y-2,1,2,15)
 elli(210+4+x+sin(t)*1.1,y-2,1,2,15)
 
 for i=0,15 do
  local y=math.max(0,sin(t*4+i/4))*f*i/4
  circ(185+i*2,110+7-y,3,3+i%2)
 end
 
	for i=0,24 do
	 for j=0,8 do
		 local x=sin(t/8+i/4)*j/12
			local y=cos(t/8+i/4)*j/32+j/8-.75
			local z=cos(t/8+i/4)*j/8
			local s=.05
			local id=(i*8+j)%19==0 and 2 or 0
			bob(x+s,y,z,id)
			bob(x-s,y,z,id)
			bob(x,y+s,z+.001,id)
			bob(x,y-s,z-.001,id)
		end
	end
	
	for i=1,#p do
	 bob(p[i].x,p[i].y,p[i].z,1)
		p[i].x=p[i].x+sin(t/3+i)/100*(p[i].z*.25+.5)
		p[i].z=p[i].z+sin(t/4+i)/100
		p[i].y=p[i].y+.01
		p[i].y=p[i].y>2 and -2 or p[i].y
	end
	
 local y=fft(100)*200
 --print("tiny cat christmas",10,90,15,0,2)
 if t//8%2==0 then
 	print("tiny cat christmas",10,10-y,12,0,2)
 else
 	print("tiny code christmas",7,10-y,12,0,2)
 end
 t=t+.1
end
