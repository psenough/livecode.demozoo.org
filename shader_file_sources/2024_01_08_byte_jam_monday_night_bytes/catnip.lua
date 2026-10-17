mf={}
t=0

min=math.min
max=math.max
sin=math.sin
cos=math.cos

function clamp(x,a,b)
 return max(a,min(x,b))
end

ro={}
go={}
bo={}
for i=0,47 do
  ro[i+1]=peek(0x03FC0+i*3)
  go[i+1]=peek(0x03FC0+i*3+1)
  bo[i+1]=peek(0x03FC0+i*3+2)
end

h={}

function TIC()
 local f={}
 for i=1,240 do
  mf[i]=math.max(mf[i] or 0, fft(i))
  f[i]=fft(i)/mf[i]
 end
 table.insert(h,1,f)
 if #h>68 then
  table.remove(h,#h)
 end
 vbank(0)
 cls()
 print("=^^=",5,30,12,0,10)
 vbank(1)
 cls()
 for i=1,#h,1 do
  l=h[i]
  trace(i..":"..l[1])
 	for x=0,239,4 do
   v=l[x+1]
   v2=l[x+5]or 0
   line(
    x,
    i*2-v*16,
    x+4,
    i*2-v2*16,
    (v2+v)*4)
  end
 end
 
 t=t+1
end

function SCN(y)
 vbank(0)
 x=h[1][y+1]*8-4
 poke(0x03FF9,x)
 poke(0x03FFa,x)
 vbank(1)
 x=h[1][136-y]*8-4
 poke(0x03FF9,x)
 poke(0x03FFa,x)
 if y+t%136<1 then
 	poke(0x03FF0+y%8,(x+4)*8)
 end
 
end