--i'm 3 and what is this
--shoutout to the cat sanctuary massiv
function TIC()t=time()//32
    --vic20 palette rulez cuz it has pink.
    --c64 sux, cope harder lmao
    r={0x00,0xff,0xa8,0xe9,0x77,0xb6,0x85,0xc5,0xa8,0xe9,0x55,0x92,0x42,0x7e,0xbd,0xff}
    g={0x00,0xff,0x73,0xb2,0x2d,0x68,0xd4,0xff,0x5f,0x9d,0x9e,0xdf,0x34,0x70,0xcc,0xff}
    b={0x00,0xff,0x4a,0x87,0x26,0x62,0xdc,0xff,0xb4,0xf5,0x4a,0x87,0x8b,0xca,0x71,0xb0}
    
    q=math.random(8,32)
    
    for i=0,15 do
    poke(0x3fc0+3*i,r[i+1])
    poke(0x3fc0+3*i+1,g[i+1])
    poke(0x3fc0+3*i+2,b[i+1])
    end
    
    s=136/5
    k={7,9,1,9,7}
    for i=0,4 do
    rect(0,s*i,240,s,k[i+1])
    end
    
    blobs()
    kefrens(8)
    
    -- what is math i'm baby
    x=(math.cos(t/24)*64)+30
    y=(math.sin(t/20)*24)+68
    
    -- uwu no politics pwease v.v
    print("trans rights",x+2,y+2,0,false,3)
    print("trans rights",x,y,8,false,3)
    s=(math.sin(t/16)*16)+30
    print("fuckings to transphobes",(x-47)+s,y+25,0,false,2)
    print("fuckings to transphobes",(x-46)+s,y+24,8,false,2)
    
    
    -- holy shit ny'all are so much better
    -- i am die
    
    end
    
    -- yes theyre kefrens bars
    -- not alcatraz bars
    -- suck it photon
    function kefrens(p)
    
    x=(math.sin(t/8)*32)+120
    k={0,12,13,6,7,1,7,6,13,12,0}
    for i=0,96 do
    for j=1,11 do
    s=(math.cos(t/6+(i/p))*32)
    line((x+j)+s,i+10,(x+j)+s,136,k[j])
    end
    end
    end
    
    function blobs()
    
    for i=0,32 do
    
    x=(math.cos(t/16+i)*64)+120+i
    y=(math.sin(t/i)*8)+68+i
    r=(math.cos(t/8-i)*8)+16
    
    circ(x,y,r,i/6)
    
    end
    
    end