-- so this idea is probably too ambitious...
-- greets to everybody!!

sin = math.sin
cos = math.cos
pi = math.pi
-- uhh rotation, yes
-- how the heck do I do this
-- right
function lrot(x,y,l,rot,c)
    line(x,y,x+(sin(rot/pi)*l),y+cos(rot/pi)*l,c)
end


function dancer(x,y,c)
    -- lol I can't do dance animation
    circ(x,y+sin(t/2)*2,8,c)
    -- body
    lrot(x,y,40,0,c)
    -- legs
    lrot(x,y+40,30,-1,c)
    lrot(x,y+40,30,1,c)
    -- arms
    lrot(x,y+20,30,8+sin(t/2),c)
    lrot(x,y+20,30,-8+sin(t/2),c)
end

function TIC()t=time()/35
    x = 0
    kick = fft(0)+fft(1)+fft(2)+fft(3)+fft(4)
    cls(0)
    
    rect(45,5,140,80,15)
    
    for x=50,180 do
        for y=10,80 do
            pix(x,y,sin(x)+sin(y)*t)
        end
    end
    
    rect(85,60,60,30,15)

    circ(98,75,10,0)
    lrot(98,75,8,-t/4,12)
        
    circ(130,75,10,0)
    lrot(130,75,8,t/4,12)
    
    circ(110,40+sin(t/2)*2,8,5)
    lrot(110,40,20,0,5)
    
    lrot(110,50,25,2+(sin(t/2)/2),5)
    lrot(110,50,25,12+(sin(t/2)/2),5)
    
    for y=100,120,4 do
        for x=-40,50,1 do
        if x+y == 0 then
            c = 2
        else
            c = x+y
        end
            boing = sin(t/2)*10
        dancer(x*30+y,y+boing,c)
        end
    end
    

end