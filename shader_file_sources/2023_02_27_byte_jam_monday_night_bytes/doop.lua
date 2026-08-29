
lissas = {
  { f1=6.28/2, f2=6.28/5.3, ph=0.123 },
  { f1=6.28/3.2, f2=6.28/3.7, ph=0.456 },
  { f1=6.28/1.5, f2=6.28/2.71, ph=0.142 },
  { f1=6.28/4.1, f2=6.28/3.1, ph=0.857 },
  { f1=6.28/3.1, f2=6.28/4.71, ph=0.428 },
  { f1=6.28/5.9, f2=6.28/1.3, ph=0.571 },


}
sin=math.sin
cos=math.cos

function shiftcol(colno,phase)
  local r = 128+128*(1+sin(phase))
  local g = 128+128*(1+sin(phase+6.28/3))
  local b = 128+128*(1+sin(phase+6.28*2/3))
  poke(0x3fc0+colno*3+0,r)
  poke(0x3fc0+colno*3+1,g)
  poke(0x3fc0+colno*3+2,b)
end

function BDR(sl)
  -- love me some horizontal blank
  phi = sl/120*1.5
  t=time()/1000
  local colno = 4
   
  local g = 128*(1+sin(phi+t*6.28/10))
  local b = 128*(1+sin(phi+t*6.28/7 ))
  poke(0x3fc0+colno*3+0,0)
  poke(0x3fc0+colno*3+1,g)
  poke(0x3fc0+colno*3+2,b)

  colno=5
  g = 128*(1+sin(phi+t*6.28/5))
  b = 128*(1+sin(phi+t*6.28/11 ))
  poke(0x3fc0+colno*3+0,0)
  poke(0x3fc0+colno*3+1,g)
  poke(0x3fc0+colno*3+2,b)


end

function TIC()
  t = time()/1000
  phase = 6.28*t/10
  shiftcol(2,phase*1.9)
  shiftcol(2,-phase*1.3+3.1)
  theta = phase*1.3
  ct = cos(theta)
  st = sin(theta)
  
  sound = (fft(0)+fft(1)+fft(2))/3
  for i,liss in pairs(lissas) do
    cx = 120*(1+sin(liss.f1*t+liss.ph))
    cy = 68* (1+sin(liss.f2*t))
    liss.x = cx
    liss.y = cy
  end
  for sy=0,136 do
    for sx=0,239 do

      circliss = { lissas[1], lissas[2] }
      cw = 5
      
      col = 3
      for i,liss in pairs(circliss) do
        dx = sx-liss.x
        dy = sy-liss.y
        r = math.sqrt(dx*dx+dy*dy)
        n = r//cw
        if (0==n%2) then
          col = 2
        end
      end
      
      blobliss = { lissas[3],lissas[4],lissas[5],lissas[6] }
      rsum = 0
      for i,liss in pairs(blobliss) do
        dx = sx-liss.x
        dy = sy-liss.y
        r2 = dx*dx+dy*dy
        rsum = rsum + 1/r2
      end      
      inblob = false
      if (rsum>0.0008) then inblob=true end
      
      if inblob then
      
		      patwidth = 5+1000*sound + 5*(1+sin(phase*0.8))
		      ox = 120*(1+sin(6.28*t/10))
		      oy = 68*(1+sin(6.28*t/10 + 2.13))
		      px = sx - ox
		      py = sy - oy
		      a0 = px * ct + py * st
		      a1 = px * st - py * ct
		      n0 = a0 // patwidth
		      n1 = a1 // patwidth
		      n = ( (n0~n1) ) %5
		      col=5
		      if (0==n) then
		        col=4
		      end
						end
						
      pix(sx,sy,col)

    end
  end
  
  shx = 120+ 100*sin(phase*1.3)
  shy = 68 + 50*sin(phase*4.3+2.5)
  for i,liss in pairs(lissas ) do
--      circ(liss.x,liss.y,5,14)
  end

  splay = 8+2*cos(27*phase)
  for dx=0,3 do
    line(shx-8+dx, shy, shx+dx-splay, shy+24,0)
    line(shx+8-dx, shy, shx-dx+splay, shy+24,0)
  end
  
  elli(shx,shy,18,16,12)
  elli(shx-12,shy-8,10,14,30)
  circ(shx-18,shy-10,4,12)
  circ(shx-8,shy-10,4,12)
  
  e1x = shx-18+3*cos(phase*8)
  e1y = shy-8 +3*sin(phase*8)
  circ(e1x,e1y,2,0)
  
  e2x = shx-8+3*cos(phase*8+1.2)
  e2y = shy-8 +3*sin(phase*8+1.2)
  circ(e2x,e2y,2,0)



end