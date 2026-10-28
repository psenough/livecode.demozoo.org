for i=0,15 do
    poke(0x3fc0+i*3,i*255/3)
    poke(0x3fc1+i*3,0)
    poke(0x3fc2+i*3,0)
    end
    
    function SCN(l)
    l=math.abs(l*2-136)
    wub=fft(0)+fft(1)+fft(2)+fft(3)
    for i=0,15 do
    poke(0x3fc0+i*3,peek(0xfc0+i*3)*l/136)
    poke(0x3fc2+i*3,fft(l*1.5)*10000)
    poke(0x3fc1+i*3,fft(l*1.5)*100*(136-l))
    end
    end
    
    function TIC()t=time()//32
    wub=fft(0)+fft(1)+fft(2)+fft(3)
    for y=0,136 do for x=0,240 do
    cx=x-120
    cy=y-68
    a=1
    r=math.sqrt(cx*cx+cy*cy)//1
    if math.sin(r+t+x) > 0 then
    pix(x,y,(a+r+t+wub*200//4)>>4)
    end
    end end end