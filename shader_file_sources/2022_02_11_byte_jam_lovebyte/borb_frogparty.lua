--[[
 borb here!!
 cheers to potato imaginator :)
 hope you can make it next time!
 
 let's go tobach,
 mantratronic and gasman!!!
]]
-- HMMMMMMM
-- let's make a frog????

sin=math.sin
cos=math.cos
atan2=math.atan2
pi=math.pi
to=table.insert
abs=math.abs

len=function(a,b)return math.sqrt(a^2+b^2)end
dist=function(a,b)return len(a.x-b.x,a.y-b.y)end
pal=function(c1,c2)
 if c1==nil and c2==nil then
     for i=0,15 do poke4(0x3ff0*2+i,i)end
    end
 poke4(0x3FF0*2+c1,c2)
end


x,y=0,0

cols={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
worldcol=0
--84
--124
frog=function(x,y,s)
    return{
    x=x,
    y=y,
    s=s,
    c=6,
    upd=function(E)
        -- it's easier to update something
        -- if you actually call the update function lol
        for i,f in ipairs(flys)do
            if abs(E.x-f.x)<4*E.s and abs(E.y-f.y)<4*E.s then
                cls(t//25%15)
                worldcol=(t//25)%16+1
                for i,c in ipairs(cols)do
                    pal(c,(c+t//25)%16+1)
                end
            end
        end
    end,
    drwEye=function(E,x,y,sx,sy)
            circ(E.x+x*E.s,E.y+y*E.s,2*E.s,12)
            circ(E.x+(x+sx)*E.s,E.y+(y+sy)*E.s,1*E.s,0)
    end,
    drw=function(E)
        circ(E.x,E.y,4*E.s,E.c)
        
        local theta=atan2(Y-E.y,X-E.x)
        
        E:drwEye(-3,-4,cos(theta),sin(theta))
        E:drwEye(3,-4,cos(theta),sin(theta))
    end
    }
end

frog1=frog(84,124,2)
frog2=frog(144,114,5)


function fly(x,y)
    
    return {
    x00=x,y00=y,s=1,
    theta=math.random()*12,
    --cols={},
    upd=function(E)
        E.x0=E.x00+50*sin(t*0.01)
        E.y0=E.y00-20*cos(t*0.01)
        E.x=E.x0+60*cos(t*.05)+10*sin(t*0.005+E.theta*2)
        E.y=E.y0+30*sin(t*.05+E.theta)-20*cos(t*.002+E.theta*.5)
    end,
    drw=function(E)
        pal(14,((8+(E.theta+t*0.1)%8)+worldcol)%16+1)
        if true then--t%2==0 then
            elli(E.x-6*E.s,E.y,4*E.s,1*E.s,14)
            elli(E.x+6*E.s,E.y,4*E.s,1*E.s,14)
        end
        circ(E.x,E.y,E.s*2,0)
    end,
    }
end

flys={}
flycoords={
{20,60},
{50,20},
{140,20},
{120,80},
}
for i,c in ipairs(flycoords)do
    to(flys,fly(c[1],c[2]))
end

function SCN(l)
    
end

function flower(x,y,s)
    return {
        x=x,y=y,s=s,
        drw=function(E)
            col=4+t//10%4
            --rect(E.x-14*E.s,E.y-4*E.s,30*E.s,130,0)
            for y=E.y,130,2*E.s do
                rect(E.x+E.s*1.5*sin(t*0.05+y/4),y,2*E.s,2*E.s,col)
            end
            elli(E.x+1.5*sin(t*0.05),E.y,8*E.s,2*E.s,col)
        end,
    }
end
flows={}
to(flows,flower(15,60,1))
to(flows,flower(30,90,3))
to(flows,flower(210,40,1))
to(flows,flower(230,80,1))
to(flows,flower(205,100,2))

t=0
cls(0)
function TIC()
    --cls(8)
    --X,Y=mouse()
    
    for i,f in ipairs(flys)do
        f:upd()
    end
    X,Y=flys[2].x,flys[2].y
    --flys[1].x,flys[1].y=X,Y
    frog1:upd()
    frog2:upd()
    for i,E in ipairs(flows)do
        E:drw()
    end
    
    frog1:drw()
    frog2:drw()
    for i,f in ipairs(flys)do
        f:drw()
    end
    
    for y=129,136 do for x=0,240 do
        pix(x,y,(x+y)%3+5)
    end end
    t=t+1
    print("borb",215,130,0)
    print("EMUUROM",1,130,0)
end