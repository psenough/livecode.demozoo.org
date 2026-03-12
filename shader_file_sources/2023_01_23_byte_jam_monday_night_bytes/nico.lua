px=150
py=70
pw=46
ph=60
bump = 0
r=math.random
sin=math.sin
cos=math.cos
texts={
"It's ",
"not ",
"patarty\n",
"It's ", "drawn\n",
"from ","memory\n","yeah!"
}
-- hi from nico! (it/its)
-- It's not a party, it's.....
function TIC()t=time()/200
    cls(8)
    for x=0,240 do
        for y=0,138 do
            pix(x,y,(sin(y/16+t)+sin(x/16+t)+t)%3+8)
    end
end
end

    -- spud
function OVR()
if t%100<80 then
        current=""
        for x=1,#texts do
            count = t%20/2
            if x<count then
                current = current .. texts[x]
            end
        end
        print(current,5,20,3)
        bump = (bump*0.8) + (fft(1)+fft(2)+fft(3)+fft(4))
        py=70+(-bump*2)
        -- body
        elli(px,py,pw,ph,4)
        -- eye
        elli(px-15,py-30,10,10,15)
        elli(px+15,py-30,10,10,15)
        elli(px+20,py-32,3,3,12)
        elli(px-10,py-32,3,3,12)
        -- spots
        elli(px-20,py+6,5,8,3)
        elli(px+20,py+20,5,10,3)
        elli(px-10,py+40,5,4,3)
        -- shaping
        elli(px-50,py,10,40,0)
        elli(px+50,py,10,40,0)
    else
        ff=(fft(1)+fft(2)+fft(3)+fft(4))*16
        print("imagine",20,60+sin(t-1)*10,6)
        print("a",60,60+sin(t-2)*10,5) 
        print("twister",72,60+sin(t-3)*10,7) 
        print("here",120,60+sin(t-4)*10,2)
        print("apologies to Mrs. B\nand the rest of SLP",40,100,2)
        
        end
end