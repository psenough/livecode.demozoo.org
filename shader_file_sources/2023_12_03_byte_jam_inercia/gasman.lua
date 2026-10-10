-- good morning inercia!
-- gasman wishes you a happy party
-- and greets jtruk,^mantratronic,
--  drsoft, suule, tobach, nusan,
-- superogue, jeenio, aldroid and
-- everyone at inercia and on stream!

function TIC()
 t=time()

 for i=1,15 do
  tc=(t-i*32)/1834
  hue={
   4+4*math.sin(tc-math.pi),
   4+4*math.sin(tc+math.pi*0.1),
   4+4*math.sin(tc+math.pi*0.3)
  }
  poke(16320+i*3,i*hue[1])
  poke(16321+i*3,i*hue[2])
  poke(16322+i*3,i*hue[3])
 end


 cls()
 for ri=1,15 do
  r=ri*3+16
  tr=t-ri*50

  ra=tr/1234
  --rb=6*math.sin(tr/2345)
  rb=tr/2345

  for a=0.05,math.pi,0.2 do --rings
   rstp=(1-math.sin(a))*0.6+0.2
   for b=0,math.pi*2,rstp do -- ring step
    y0=math.cos(a)
    x0=math.sin(a)*math.cos(b)
    z0=math.sin(a)*math.sin(b)

    x1=x0
    y1=y0*math.cos(ra)+z0*math.sin(ra)
    z1=z0*math.cos(ra)-y0*math.sin(ra)

    x=x1*math.cos(rb)+y1*math.sin(rb)
    y=y1*math.cos(rb)-x1*math.sin(rb)
    z=z1
    --who needs z-sorting anyway
    if (z>-0.05) then
     --size=(z+1)/2+(15-ri)/15+1
     size=(15-ri)/4+.5
     circ(x*r+120,y*r+68,size,ri)
    end
   end
  end
 end
end
