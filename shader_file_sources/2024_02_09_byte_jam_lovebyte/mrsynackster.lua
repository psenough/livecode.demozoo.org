function TIC()t=time()//32
    for y=0,136 do 
        for x=0,240 do
            x1 = x ^ math.sin(t)*2+(t%240)
            y = y + math.cos(t)*4
            pix(x1,y,(x+t)>>2)
            bl = 50+math.sin(t)*2
            bu = 100+math.cos(t)*2
            if y>bl and y < 100 then  
             c = pix(x,y)
                yz = y+math.sin(t)*4 
                pix(x,yz,c+1%3)
            end
            if y<100 then
             c= pix(x,y)  
             if c==2 then 
                 c=4
                end 
            end
        end 
    end
        rect(0+(t%240),0+math.sin(t)*4,3,30,2)
        rect(100+(t%240),0,3,30,4) 
        rect(30+(t%240),100+math.cos(t),3,30,5)
        for qz=0,5 do
        for q=0,10 do
            circ(5+(t%240)+qz*20,1+q^math.sin(t)*qz+(t%160),5+math.cos(t)*2,4+q+qz)
         circ(20+(t%240)+qz*20,1+q^math.cos(t)*qz+(t%160),5+math.sin(t),4+q^qz)
        
        end
        end
end