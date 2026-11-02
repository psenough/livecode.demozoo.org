s=math.sin
str="SUBMIT"
cls()

function TIC()
t=time()/999
cls()
print(str,5,4,1,false,7)
print(str,5,44,1,false,7)
print(str,5,84,1,false,7)
print("TO",119,114,1,false,1)
print("LIVECODE.DEMOZOO.ORG",5,123,1,false,2)
for x=0,240 do
for y=0,136 do
 if pix(x,y)== 1 and y % 2 == 0 then
 col=s(x/50+t)+s(y/50+t*2)
 pix(x,y,col*8*s(t)+(x~y)/50)
 else
 pix(x,y,0)
 end
end
end
end
