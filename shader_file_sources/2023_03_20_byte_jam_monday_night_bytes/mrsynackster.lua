cls(0)
t=0
r=math.random 
s=math.sin 
h = 50 
w = 50 
sc = string.char
a = {} 
hs = "HELLO FROMTHE MATRIX! : )" 
hsl = string.len(hs) 
for z=0,1250 do
 chr = r(255) 
 ch = sc(chr)
 table.insert(a,ch) 
end

for zy=0,hsl do
 for zx=0,25,3 do -- half the rows  
 so = 51--r(10) 
 a[so+zy+(zx*50)]= hs:sub(zy,zy)
 end  
end

function TIC()
 cls(0) 
 for x=0,25 do
  for y=0,50 do  
         c=a[x+(y*50)] 
      hd=(((x*10)+t)+(y%10))%200
            yd = y*12   
            print(c,0+yd,0+hd,5,0,1)
        end
    end  
     t=t+.1 
end