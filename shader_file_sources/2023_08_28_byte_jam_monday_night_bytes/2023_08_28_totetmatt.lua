-- Hello folks !
-- It's still not bonzomatic ! :D 
-- Cheers to the viewers and participants !

-- Today, FFT and tsoding codes inspiration !

cx=240/2
cy=136/2
grav= 0.1
inercia = 1 -- <<< Don't forget 
cxdir=1
fftv={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
fftc={}
cc=1
csize=6
function sign(x)
 if x == 0 then
 	return 1
 end
	return x / math.abs(x)
end
function leFFT(x,o)
		v = 0
		for z=1,o do
		v = fft(x+z)/o
		end
		return v
		
end
function TIC()t=time()//32
cls()
size=16
for x=0,size do

	u = x*240/size
	val=math.sqrt(leFFT(u,size)*5)
	fftv[x]=136-val*500
	rect(u,
	136-val*500,
	size,
	136,
	8+x/2+t/4
	)
	fftc[x]=	8+x+val*50
	line(u,
	136-leFFT(u,5)*500,
	u+size,
	136-leFFT(u+1,5)*500,
	12)
	
end
ni = inercia+grav
inercia=sign(ni)*math.min(4,math.abs(ni))


cy=cy+inercia
cx=cx+cxdir
if cx+csize >= 240 or cx-csize <= 0 then
cxdir = cxdir*-1
end
if cy+csize> 136 or cy+8>= fftv[cx//16]   then
	inercia= -inercia- fftv[cx//16]*.005
	cc=fftc[cx//16]
  cy=fftv[cx//16]-5
  csize = 6+fftv[cx//16]*.05
  
end

circ(cx,cy,csize,cc)

circ(cx,cy,csize-5,cc+1)

--for y=0,136 do for x=0,240 do
--pix(x,y,(x+y+t)>>3)
end



function OVR()
strs={"ASKS FOR MORE SHOWDOWNS <3!","DONT FORGET TO ARCHIVE <3!"}
str=strs[1+(t//32)%2]
cc=0
str:gsub(".", function(c)
  cc=cc+1
  x=(-cx+cc*15-t)%450
print(c,x,
-15+.2*fftv[1+x%16]+math.tanh(cc+math.sin(cc*.3+t/8)*5)*50,t+7+cc%5+math.sin(cc+t),false,3)
end)
end