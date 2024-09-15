function SCN(l)
    vbank(0)
    mg=l/135
    mg=mg^2
    for c1=0,3 do
     o = 40
     for c2=0,3 do
      c=o+c1+c2*40
      c = c* mg
      poke(0x3fc0+c1*4*3+c2*3,c)
      poke(0x3fc1+c1*4*3+c2*3,c)
      poke(0x3fc2+c1*4*3+c2*3,c)
     end
    end
    end
    
    function r(x,y,a)
     ca=C(a)
     sa=S(a)
     return (x*ca-y*sa),(y*ca+x*sa)
    end
    
    function pt(x,y,z)
     tr=time()/500
     dst=8
     scl=400
     x=x-5
     y=y+2
     x,z=r(x,z,0.15+S(tr/13)*0.04)
     y,z=r(y,z,0.5)
     z = z + C(tr/7)
     X=x*scl/(dst+z)
     Y=y*scl/(dst+z)
     return 120+X,68+Y
    end
    
    S=math.sin
    C=math.cos
    
    hf=2
    
    function drawcube(x,y,h,c)
    x1,y1=pt(x  ,h,y)
    x2,y2=pt(x+1,h,y)
    x3,y3=pt(x+1,h,y+1)
    x4,y4=pt(x,  h,y+1)
    tri(x1,y1,x2,y2,x3,y3,c+2)
    tri(x4,y4,x1,y1,x3,y3,c+2)
    x5,y5=pt(x  ,hf,y)
    x6,y6=pt(x  ,hf,y+1)
    tri(x4,y4,x1,y1,x5,y5,c+0)
    tri(x4,y4,x6,y6,x5,y5,c+0)
    x7,y7=pt(x+1,hf,y)
    tri(x1,y1,x2,y2,x7,y7,c+1)
    tri(x5,y5,x1,y1,x7,y7,c+1)
    end
    
    
    function TIC()
     vbank(0)
     t=time()/429
     cls()
     
     x,y=pt(C(t),1,S(t))
     for y=22,0,-1 do
     for x=22,0,-1 do 
       drawcube(x,y,S((x+t/120)+C(y+t))/2,x*4+1)
     end
     end
     vbank(1)
      print("Skrolli",40,19,15,false,4)
      print("PARTY 2024",130,40,15)
      for x=19,190 do for y=10,80 do
       fz=fft(((x-15)*2//8))*100
       yz=60-y
       if pix(x,y)==15 and fz > yz then
         pix(x,y,p)
       end
      end end
    end