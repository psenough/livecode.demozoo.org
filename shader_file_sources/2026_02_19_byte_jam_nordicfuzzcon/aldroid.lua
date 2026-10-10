function projpt(x,y,z)
 mag = 300/z
 smag = 50
 X=smag*x/mag + 120
 Y=-smag*y/mag + 68
 return X,Y
end

poke(0x3fc3,233)
poke(0x3fc4,233)
poke(0x3fc5,233)


for i=2,15 do
 poke(0x3fc0+3*i,i*255/15)
 poke(0x3fc1+3*i,0)
 poke(0x3fc2+3*i,0)
end

a=0

function TIC()
 t=time()/1000
 cls(0)
 pts = {}
 for i=-7,7 do 
 pts[i]={}
 for j=-7-t//1,5-t//1 do
 h=(1-math.cos(i))*math.abs(math.sin(math.sin(i)+j))*20*(.4+fft((i*10+j*30)%200))
 pts[i][j]={projpt(20*i,-40+h,10+1*j+t)}
 end end
 for i=-7,6 do 
 for j=-7-t//1,4-t//1 do
 
 --x1,y1 = projpt(20*i,-40,10+1*j)
 --x2,y2 = projpt(20*(i+1),-40+h,10+1*j)
 --x3,y3 = projpt(20*i,-40+h,10+1*(j+1))
 
 x1 = pts[i][j][1]
 y1 = pts[i][j][2]
 x2 = pts[i+1][j][1]
 y2 = pts[i+1][j][2]
 x3 = pts[i][j+1][1]
 y3 = pts[i][j+1][2]
 c=math.max(2,math.min(8+j+t//1,15))
 line(x1,y1,x2,y2,c)
 line(x1,y1,x3,y3,c)
 line(x1,135-y1,x2,135-y2,c)
 line(x1,135-y1,x3,135-y3,c)
 end end
 
 a=print("NFC",120-a/2,66,1)

end