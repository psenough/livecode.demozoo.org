-- superogue bytejammin' here 
-- lets join this hypetrain!!!!
function SCN(l)
    ll=(l*l)/32-112+(l%5)*8
    poke(16320+12,192-ll)
    poke(16320+13,160-ll)
    poke(16320+14,128-ll)
    end
    
    t=1m=math
    function TIC()
    t=t+.5
    for y=0,136 do for x=0,240 do
    X=x-120
    z=m.abs(y-64)+.1
    tc=(X*2/z+t/2)//1 % 2 -- 399//z)%3
    rc=((y>80) and (y<96)) and 14 or (399//z)%2
    c=(y>64) and (rc+tc+y%2) or (((y-64)/16)+12+y/2%2)
    pix(x,y,c)
    end end
    
    tx=(2*t)%960-72+m.sin(t/30)*64
    ty=50 
    tw=64
    lx=tx-(72*3)
    elli(tx-72*6+48+232,ty+38,470/2+t%4,4+t%2,0)
    for r=8,2,-1 do
    wx1=tx+16
    wx2=tx+56
    wy=ty+33+m.sin(t)
    wc=14+r%3
    circ(wx1,wy,r,wc)
    circ(wx2,wy,r,wc)
    circ(wx1-80,wy,r,wc)
    circ(wx2-80,wy,r,wc)
    circ(wx1-200,wy,r,wc)
    circ(wx2-200,wy,r,wc)
    circ(wx1-290,wy,r,wc)
    circ(wx2-290,wy,r,wc)
    circ(wx1-365,wy,r,wc)
    circ(wx2-365,wy,r,wc)
    end
    rect(tx-72*6+52,ty+25,460,6,0)
    rect(tx,ty,tw,32,4)
    rect(tx+28,ty+6,8,12,15)
    rect(tx+44,ty+6,8,12,15)
    rect(lx,ty,212,32,4)
    
    rect(tx-(72*4),ty,tw,32,4)
    rect(tx+20-(72*4),ty+6,8,12,15)
    rect(tx+36-(72*4),ty+6,8,12,15)
    
    rect(tx-(72*5),ty,tw,32,4)
    rect(tx+8-(72*5),ty+6,8,12,15)
    rect(tx+24-(72*5),ty+6,8,12,15)
    tri(tx+64,ty,tx+64+16,ty+32,tx+64,ty+32,4)
    tri(lx-144,ty,lx-160,ty+32,lx-144,ty+32,4)
    rect(tx-72*6+52,ty+28,460,1,15)
    
    for i=1,5 do 
    print(logo[i],lx+4,ty-4+i*5,12,1,1,1)
    end
    
    end
    
    -- thx mantra for the logo :p
    logo={"  `___//  __//_ __//___//_---//___;---//__;--\\\\__.",
    "  /  //--Y     \\   _/   _/        Y       Y      |",
    " /       |  // |   _/   _/   /    |   a   |   // |",
    "/   //   |     |  |/|  |/|  // // |   /   |  //  |",
    "\\--//____/-//-_/\\-/  \\-/ |-//_//_mtr-//--|/-//___|"}