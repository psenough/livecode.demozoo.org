sin=math.sin
cos=math.cos
floor=math.floor

function TIC()
    t=time()/1024
    cls(16)
    for y=0,136 do
        for x=0,240 do
            f=floor(fft(x*2)*50)
            x1 = floor(x*cos(t)-y*sin(t))
            y1 = floor(x*sin(t)+y*cos(t))
            col =1+(0.1*(x1~y1))            
                for a=0,f do                
                    pix(x,y,col)
            end 
        end
    end
end