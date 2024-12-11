--* FOR ADMIN
--   THIS IS TOTETMATT
-- Hello Everyone, It's holiday here 
-- Wheeeeee \o/
-- Mandatory : I'm not a bot
-- O wait, its STILL NOT BONZOMATIC
--*  
fftFactor=10
nb=255
fftX = {}    -- new array
for i=1,nb do
  fftX[i] = math.random(-10,10)/10
end
fftY = {}    -- new array
for i=1,nb do
  fftY[i] = math.random(-10,10)/10
end
function TIC()t=time()//32

--for y=0,136 do 
--for x=0,240 do
--pix(x,y,fft(y*.5+math.asin(math.sin(x*.1))*10)*fftFactor)
--end end
for i=1,nb do
  fftX[i]=fftX[i]+fft(i)
  fftY[i]=fftY[i]+fft(255-i)
  if i%2 ==0 then c = circ else c=circb end
  c(120+math.sin(fftX[i])*125,
        64+math.sin(fftY[i])*75,
        5+(fftX[i]+fftY[i])%10,
        (i%3+8)+(.1*(fftX[1+(i+t)%8]))%2)

end
--end end

end

function SCN(l)
zz=fft((l+t)%255)*100
poke(0x3FF9+1,zz)
s="Do you ARCHIVE ?"
cr=0
s:gsub(".", function(c)
print(c,
136+1+cr*26-(fftX[20]*10)%500,
64+math.cos(cr+fftY[2]*10)*10,
15+fftX[math.floor(1+l*.1)]+t//2,
false,5)
cr=cr+1
end)

if fft(40+l+t%255)> .01 then 
poke(0x3FC2, 255)

poke(0x3FC0, 12+l*50)
poke(0x3FC1, 128)
print("Because YOU SHOUlD !",5+math.sin(t//8)*10,120,1+fftX[4],false,2)
else
poke(0x3FC2, 0)
poke(0x3FC0, 0)
poke(0x3FC1, 0)
end


end
