s=math.sin
t=0 
function TIC()
cls(10)
for cx=0,10 do
  circ(10+cx*30,5,20,12)
  elli(10+cx*30,100,8,18,6)
  for c2=0,3 do
   fx=(240-(t%240)- cx*4-c2*50)%240
   fy= 10+cx*20+s(t/5+c2)
      elli(fx,fy,12,3,2)
   elli(fx-4,fy-1,2,2,12)
   elli(fx+10,fy,4,4,2)
   elli(fx-4,fy+s(t/5),1,1,0)
  end
end 
print("SQUID!",t%240,0)
rect(0,100,300,50,6)

xp=122+s(t/10)*10
yp=50 
circ(xp,yp,40,4)    
--LE
xle = xp+10
yle = yp - 8
circ(xle,yle,12,12) 
circ(xle+7-(s(t/10)*5),yle,6-(s(t)),0)
--RE 
xre = xp - 20 
yre = yp - 8
circ(xre,yre,12,12)
circ(xre+7-(s(t/10)*5),yre,6-(s(t)*2),0)
--m 
elli(xp,yp+16,16,12,0) 
t=t+1  
end