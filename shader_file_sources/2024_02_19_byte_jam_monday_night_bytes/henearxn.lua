-- HeNeArXn here
-- not quite sure what to do today,
-- idea I had would be very boring to
-- watch
-- greets to Tobach, vurpo and aldroid!

amp=60
cnt=15
data={}
data2={}
for i=0,cnt do
 data[i]={}
 data2[i]={}
 for x=0,240 do
  data[i][x]=0
  data2[i][x]=0
 end
end

sl=(60*0.5)//1
datas={}
for i=1,sl do
 datas[i]=0
end

d=8

st=0

lc=5
bc=0
x=0
y=0
xd=1
yd=1


function TIC()
 t=time()//32
-- st=(t//50+1)%2
 for y=0,136 do
  for x=0,240 do
--   pix(x,y,(x+y+t)>>3)
  end
 end
if st==0 then
-- cls(t/8)
cls(bc)
 for i=0,cnt-1 do
	 for x=0,240 do
		 data[i][x]=data[i+1][x]
  	line(x,i*d-data[i][x],x,i*d+data[i][x],i)
	 end
	end
 for x=0,240 do
 	 f=fft(x)*1.002^x*amp
   data[cnt][x]=f
  	line(x,cnt*d-f,x,cnt*d+f,5)
	 end
	s=0
	for i=0,7 do
 	s=s+fft(i)
	end
	m=0
	for i=1,sl-1 do
 	datas[i]=datas[i+1]
  m=math.max(m,datas[i])
	end
	datas[sl]=s
	b=5
	if s>m then  bc=bc+1 end
--	rect(240-s*10,0,100,136,b)
--else
st=0--st-1
--if fft(2)*1.002^2*amp/3>15 then
-- cls(15)
--else
-- cls()
--end
end
vbank(1)
if lc==0 then lc=1 end
cls()
 x=x+.8*xd
 y=y+.8*yd
 for i=0,49 do
 	 f=fft(i)*1.002^i*amp/3
   data[cnt][i]=f
  	line(x+2+i,30-3+y-f,x+2+i,30-3+y+f,lc)
	end
 rectb(x,y+7,54,40,3)
 line(x,y+7,
      x+7,y,   3)
 line(x+54,y+7,
      x+54+7,y,  3)
 line(x+54,49-3+y,
      x+54+7,42-3+y,  3)
 line(x+7,y,x+54+7,y+1,3)
 line(x+54+7,42-3+y,x+54+7,y+1,3)
 if x+57+7>240 then xd=-1 lc=lc+1  end
 if x<1 then xd=1 lc=lc+1 end
 if y+42-3>136 then yd=-1 lc=lc+1 end
 if y<1 then yd=1 lc=lc+1 end
vbank(0)
end
