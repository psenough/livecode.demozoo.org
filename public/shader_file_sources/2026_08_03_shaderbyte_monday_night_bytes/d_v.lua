function TIC()
t=time()/100
cls()
        for y=0,136 do
                for x=0,240 do
                        pix(x+math.sin(y+y/t+t+x/10),y+math.sin(x+t+math.tan(x+t)),t+math.tan(x/t/math.sin(x/20)+t+math.sin(x/t+t+y/10+math.sin(t/t))))
                end
        end 
end

function OVR()
        print("you expected a cat didn't you? :3",0,0,t*2)
        print("\noh wait here is cat :3\noh no there is 2 cats now :O",0,0,t*2)
        spr(0,20,20,0,10)
        spr(0,110,20,0,10)
end