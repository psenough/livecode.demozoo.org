-- title:   Monday Night jam
-- author:  MutzBuny
balls = 50
speed={}
dotY={}
dotX={}
dotC={}
xdir={}
ydir={}
image={}
for a=0,balls do
dotY[a]=math.random(10,126)
dotX[a]=math.random(10,220)
dotC[a]=math.random(1,7)
speed[a]=math.random(1,5)
xdir[a]=1
ydir[a]=1
end


function TIC()
    for a=0,balls do
        dotX[a]=dotX[a]+(speed[a]/5)*xdir[a]
        dotY[a]=dotY[a]+(speed[a]/5)*ydir[a]
        if dotX[a] > 220 then
        xdir[a]=-1
        elseif dotX[a] < 0 then
        xdir[a]=1
        end
        if dotY[a] > 126 then
        ydir[a]=-1
        elseif dotY[a] < 0 then
        ydir[a]=1
        end
    end

    cls(30)
    
    for a=0,balls do
    circ(dotX[a],dotY[a],fft(0,80),dotC[a])
    end
    for a=0,160 do
    res=2
    offset=40
    line(a+offset,fft(a*res)*-50+100,a+1+offset,fft(a*res+res)*-50+100,6)
    end
    
end