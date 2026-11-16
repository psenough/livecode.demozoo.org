-- Inercia 23 / jtruk
-- Greetz: Aldroid, Jeenio
-- Gasman, Mantratronic, Dr Soft
-- Suule, Nusan, Superogue, Tobach
-- and U <3

T=0
PI=math.pi
TAU=PI*2
SIN=math.sin
COS=math.cos

function BDR(y)
    for vb=0,1 do
     vbank(vb)
        for i=0,15 do
      local o=y*.01+T*.01+i*.04+vb*2
         local a=16320+i*3
      local r=128+SIN(o)*128
      local g=128+SIN(o*1.2)*128
      local b=128+SIN(o*1.4)*128
         poke(a,r)
         poke(a+1,g)
         poke(a+2,b)
        end
    end
end

function TIC()
    nSnakes=10
    nTris=15
    baseT=T*.05
    for vb=0,1 do
     vbank(vb)
     cls()
        for s=1,nSnakes do
            for i=1,nTris do
             local t=baseT+i*.02+s*2+vb*8
                local x=SIN(t*.7)*15
                local y=SIN(t)*8
                c=1+(i%15)
             drawTri(x,y,t,c)
            end
        end
    end
    
    local sz=3
    for vb=0,1 do
     vbank(vb)
        local tx="INERCIA23"
        local w=print(tx,0,150,0,false,sz)
        for i=0,10 do
         local o=i*.1+T*.1+vb*4
            local x=120-w/2+SIN(o)*10
            local y=60+COS(o*.8)*10
            print(tx,x,y,1+((i*4)%15),false,sz)
        end
    end
        
    T=T+1
end

function drawTri(x,y,t,c)
    d=7
 a1=t
 a2=t+TAU*.33
 a3=t+TAU*.66
    z1=6+SIN(t)*2
    z2=6+SIN(t+.1)*2
    z3=6+SIN(t+.2)*2
    x1,y1=getP(x,y,d,a1)
    x2,y2=getP(x,y,d,a2)
    x3,y3=getP(x,y,d,a3)
    p1=proj(x1,y1,z1)
    p2=proj(x2,y2,z2)
    p3=proj(x3,y3,z3)
    tri(p1.x,p1.y, p2.x,p2.y, p3.x,p3.y, c)
end

function getP(x,y,d,a)
    return x+COS(a)*d,y+SIN(a)*d
end

function proj(x,y,z)
 local zT=z-7
 zT=(zT==0) and .0001 or zT 
 local zF=1/zT
 local xm,ym=5,5
 return {x=120+xm*x/zF,y=32+ym*y/zF,z=z/zF}
end