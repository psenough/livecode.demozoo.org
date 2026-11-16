function TIC()
t=time()/100
        for y=0,136 do
                for x=0,240 do
                        pix(x,y+math.sin(x*y/t/t),math.sin(x+y*t-2)+y+math.sin(x)+t+math.sin(x/y))
                end
        end 
end