-- DaftShader's 2nd TIC-80 
-- MondayNightBytes 2025-12-22
-- 
-- Thanks: reality404 (host), iv (dj)         
-- Greets: aldroid, boris, canmom, marex         

-- Standard shortcut stuff:

sub=string.sub
rnd=math.random
min=math.min
frames=0
scale=(100/240)/15
mult=10

-- snowEQ stuff:

function updateTops()
 for i=0,240 do
  yold=tops[i]
  ynew=136-(fft(i)*136*(i*scale))*mult
  if ynew<=yold then 
   tops[i]=ynew  
  end
	end
end

function dropTops()
	for i=0,240 do
	 if tops[i]<=135 then
	  tops[i]=tops[i]+0.5
		end
		if tops[i]<0 then
		 tops[i]=137
		end
	end
end

function snowEQ()
 fcount=fcount+1
 if fcount%5 == 0 then
  updateTops()
	else
	 dropTops()
	end
	-- draw lines:
	for i=0,240 do
	 line(i,136,i,136-(ffts(i)*136*(i*scale))*mult/2,0)
	end
	-- draw tops:
	for i=0,240 do
	 pix(i,tops[i],12)
	end
end

-- Text scroller stuff:

text="FIELD-FX MONDAY NIGHT SNOW-E[Q] BYTES"
tt=16 --time before resetting scroller
st=0 --scroller time

function scroller()
 secs=time()//1000
 --print(secs,0,0);print("Looping every " .. tt,30,0) --show info
 if secs%tt == 0 then st=0 end --reset
 for i=1,#text do
  xpos=240+i*17-st
  ypos=70+math.sin(i+(st/10))*5
  if ypos < 241 then
   -- ypos is 0 to 240
   -- we want to add fft values up to what?
   -- depends on the audio really!
   yoff=ffts(ypos/100)*10
  else
   yoff=0
  end
  for c=0,3 do
   print(sub(text,i,i),
   xpos+(c),ypos-(yoff*(16+(c*4))),
   1+c,true,3)
  end
 end
 st=st+1
end

function lines()
 ct=(time()/1000)//1 -- cycle colours for lines
 --print(ct%16,0,0,10) -- check
 f=20 --fidelity of lines
 for j=5,220,f do
  line(j,tops[j],j+f,tops[j+f],ct)
  line(j+2,tops[j],j+f+2,tops[j+f],ct+1)
  line(j+4,tops[j],j+f+4,tops[j+f],ct+2)
 end
end

-- Do the things

function BOOT()
 -- set up our array for storing FFT values
 tops = {} -- new array to store values
 for i=0,240 do
  tops[i]=136-(ffts(i)*136)
 end
 fcount = 0
end

function TIC()
 cls(8)
 scroller()
 snowEQ()
 lines()
end