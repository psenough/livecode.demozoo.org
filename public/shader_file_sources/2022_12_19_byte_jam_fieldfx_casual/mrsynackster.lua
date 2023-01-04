t=0 
s=math.sin
atan = math.atan2 
cos = math.cos
pi = math.pi
r = math.random 
function TIC() 
t=t+.1 
 
    for y=-68,67 do
     for x=-120,119 do 
         X=(atan(y,x)+pi)*2.546+s(t) 
            Y=2/(x*x+y*y+1)^0.5+s(t/20)
            c=(X//1)/(Y//1)+(y/x/1)
            pix(120+x,68+y,c+((s(t/4)*12)//1))
            end
        end
        for i=1,5 do
            print("Greetz",(i*40),(50+t+s(i)*10)%50,6+s(t/2))
        end 
        for i=0,8 do 
            circ(120,90+i*5+(t*2%50),(t*2%18)-i,6+i)
     end     
end