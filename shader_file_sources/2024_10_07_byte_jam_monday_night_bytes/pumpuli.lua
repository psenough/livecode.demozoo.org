W=240
H=136
STEP=2

m=math

function rot(xx,yy,r)
    local x,y=xx,yy
    x=m.cos(r)*xx-m.sin(r)*yy
    y=m.cos(r)*yy+m.sin(r)*xx
    return x,y
end

tt=0
ft=0
f=0
fr=0
BPM=130
ob=0
bt=0
b=0

txt={"FIVE","SONGS","AT","ONCE","IT'S"}

function TIC()
    fr=fr+1
    ob=b
    b=time()/60000*BPM
    bi=m.floor(b)
    t=b*10
    if m.floor(ob)~=m.floor(b) then
        vbank(1)
        cls(0)
        bt=1
    else
        vbank(1)
        for i=1,5000 do
            pix(m.random(W),m.random(H),0)
        end
        bt=bt*.8
    end
    tt=tt+fft(0,16)*2
    ft=ft+fft(0,1023)*.3
    vbank(0)
    for y=0,H do
     for x=0,W,STEP do
            X=(x+fr%STEP)/W-0.5
            Y=y/H-0.5
            X,Y=rot(X,Y,tt*.01+m.cos(Y+tt*.011)+m.sin(X+tt*.012))
            X=m.abs(X)*240
            Y=m.abs(Y)*240
            X=X//1
            Y=Y//1
            X=m.max(0,m.min(1024,X))
            Y=m.max(0,m.min(1024,Y))
            MI=m.min(Y,X)
            MA=m.max(Y,X)
            f=fft(MI,MA)*10
            c=(((X*Y*.01)//1+f//1-ft//2)*.03)%15//1*(12*2)%16
            pix(x+fr%STEP,y,c+(bt*3*bt))
        end 
    end 
    vbank(1)
    for x=0,W do
        X=x/W-0.5
        X=m.abs(X*150*X-2)
        f=fft(X*2)*100
        line(x,H,x,H-f,1+f/10)
    end
    tx=txt[bi%5+1]
    w=print(tx,0,-80,0,1,5)
    print(tx,W/2-w/2,H/2-(b-bi)*30,12+(b%3*3%4),1,5)

end

function BDR(i)
    vbank(1)
    bf=fft(i)*100
    if i%2==0 then 
        poke(0x3FF9,bf*bt)
    else
        poke(0x3FF9,-bf*bt)
    end
end