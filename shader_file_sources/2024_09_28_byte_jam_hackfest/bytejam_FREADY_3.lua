-- F#READY
-- tryout day #3
-- prepared code
-- byte jam, hackfest 2024

cls()
print("HACK",30,20,1,true,8)
print("FEST",30,70,2,true,8)
grid={}
for x=0,239 do
 grid[x]={}
 for y=0,135 do
  grid[x][y]=pix(x,y)
	end
end

function TIC()
 t=time()/1000
 for x=0,239 do
  for y=0,135 do
   xc=x
   yc=y-68
   u=(math.cos(t)*xc-math.sin(t)*yc)//1
   v=(math.sin(t)*xc+math.cos(t)*yc)//1
   c=grid[u%239][v%135]
   pix(x,y,c)
  end
 end
end
