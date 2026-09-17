--
-- Hello Inercia!
--
-- Greetz to:
--   gasman, jtruk, mantronic, suule
--   nusan, superogue and tobach!
--

m=math
s=m.sin
f=m.floor
r=m.random

function text(txt,x,y)
    local t=time()//64
    
    local width=print(txt,0,0,15)
    for test_x=0,width do
        for test_y=0,7 do
            if pix(test_x,test_y)==15 then
                sine=s(-t/33+y/3+math.pi*1/100*test_x+-t/3+y/4+math.pi*1/200*test_y)
                size=3+sine*3
             x_pos=(x-f(size/2))+6*test_x
                y_pos=(y-f(size/2))+6*test_y

             rect(x_pos,y_pos,size,size,15)
            end
        end
    end
 rect(0,0,width,7,0)
end

function TIC()
    local t=time()//32
    
    red=7+4*s(time()/128)
    green=7+4*s(time()/128+math.pi*2/3)
    blue=7+4*s(time()/128+math.pi*4/3)
    for i=1,14 do
        poke(0x3fc0+(i*3),i*red)
        poke(0x3fc0+(i*3)+1,i*green)
        poke(0x3fc0+(i*3)+2,i*blue)
    end
    
    poke(0x3fc0+(15*3),250)
    poke(0x3fc0+(15*3)+1,250)
    poke(0x3fc0+(15*3)+2,250)
    
    vbank(0)
    for y=0,136 do
     offset=10+f(s(y/30+math.pi*4/3)*20*s(t/23))
        for x=0,240 do
         offset2=5+f(s(x/5)*10*s(t/40+math.pi*2/3))
            pix(x,y,1+(x+(offset+offset2)>>3)%14)
        end
    end
    
    vbank(1)
    cls()
 text('Hello',30,10)
 text('Inercia',10,55)
 text('!!!',100,100)
end