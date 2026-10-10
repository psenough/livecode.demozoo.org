lbt = time()

function plotfft()
  for x =0,240 do
    line(x,0,x,fft(x)*100,5)
  end
end

window={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
wintot=0
windex=0
function beat()
 p=0
 for x=0,10 do
   p=p+math.floor(fft(x)*100)
 end

 wintot = wintot + p - window[windex+1]
 window[windex+1] = p
 windex = (windex + 1)%#window
 local p2 = wintot/#window
 if p2==0 then
  p2=0.01
 end
 if (time()-lbt) < 300 then
  return false, p/p2
 end

 b = p>(p2*1.3)
 if b then
   lbt = time()
 end

 return b, p/p2
end
sin=math.sin

a=true

grid={}
textgrid={}
width=11
height=6
col=1
for x=1,width do
 grid[x]={}
 textgrid[x]={}
 for y=1,height do
  col=1+math.floor(math.random()*15)
  grid[x][y]=col
  textgrid[x][y]=" "
 end
end

str1="REVISION"
str2="HYPE"
function str_at(dx,dy,str)
 for i=1,#str do
  x=dx+i
  textgrid[x][dy]=str:sub(i,i)
 end
end
function newtext()
 for x=1,width do
  for y=1,height do
   textgrid[x][y]=" "
  end 
 end
 str_at(2,1,str1)
 str_at(4,2,str2) 

 str_at(2,4,str1)
 str_at(4,5,str2) 
 --this next part just for enfys...
 textgrid[1][1]="F"
end
newtext()

ox=0
oy=0
sp=30

mstate=0
mdelta=0
mindex=3
init_speed=0.2
speed=0.2

beat_count=0
function TIC()
 cls()
 --plotfft()
 b,p=beat()
 ox=ox+speed
 oy=oy+speed

 if ox>=sp*width then
   ox=0
 end
 if oy>=sp*height then
   oy=0
 end
 for x=1,width*2 do
  local oy2=0
  local ix=((x-1)%width)+1
  if mstate==1 and mindex==ix then
    oy2=mdelta
  end
  for y=1,height*2 do
   local ox2=0
   local iy=((y-1)%height)+1
   if mstate==2 and mindex==iy then
    ox2=mdelta
   end   
   col = grid[ix][iy]
   local tx=-20
   local ty=-20
   tx=tx-ox-ox2+(x*sp)
   ty=ty-oy-oy2+(y*sp)
   d=math.min(p*4,10)
   text = textgrid[ix][iy]
   rect(tx-(sp/2),ty-(sp/2),sp,sp,(x+(y%2))%2)
   circ(tx,ty,5+d,col)
   print(text,tx-4,ty-4,((col+5)%16),false,2)
  
  end
 end

	if b then
		a = not a
	end

 if mstate>=3 then
  if mstate==3 then
    speed=speed+0.1
    if speed > 5 then
     mstate=4
    end
  end
  if mstate==4 then
 		 newtext()
    speed=speed-0.1
    if speed <= init_speed then
     mstate=0
     speed=init_speed
    end
  end
 else
	if mstate==0 and b then
	 beat_count = beat_count+1
		if beat_count > 30 then
		 beat_count=0
			mstate=3
		else

	 mstate=math.floor(math.random()*2)+1
		local max_val=height
		if mstate==1 then
		 max_val=width
		end
 	mindex=math.floor(math.random()*max_val)+1
  end
	else
	 mdelta=mdelta+2
		if mdelta >= sp then

				--update colours
				if mstate==1 then
      c1=grid[mindex][1]
      t1=textgrid[mindex][1]
      for y=1,height-1 do       
       grid[mindex][y] = grid[mindex][y+1]
       textgrid[mindex][y] = textgrid[mindex][y+1]
      end
      grid[mindex][height]=c1
      textgrid[mindex][height]=t1
    end
				if mstate==2 then

      c1=grid[1][mindex]
      t1=textgrid[1][mindex]
      for x=1,width-1 do
       grid[x][mindex] = grid[x+1][mindex]
       textgrid[x][mindex] = textgrid[x+1][mindex]
      end
      grid[width][mindex]=c1
      textgrid[width][mindex]=t1
    end
		  mstate=0
				mdelta=0
		end
	end
 end
end
